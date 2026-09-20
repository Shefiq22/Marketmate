import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/core/utils/prefs_cache.dart';

const _deviceIdKey = 'fcm_device_id';

/// Stable per-install identifier used when registering this device with the
/// backend for push notifications. Generated once and persisted locally.
String _getDeviceId() {
  final cached = PrefsCache().getString(_deviceIdKey);
  if (cached != null && cached.isNotEmpty) return cached;

  final random = Random.secure();
  final id = List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  PrefsCache().setString(_deviceIdKey, id);
  return id;
}

String _devicePlatform() {
  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
  }
  return 'web';
}

class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String token) => state = token;
}

final fcmTokenProvider = NotifierProvider<FcmTokenNotifier, String?>(
  () => FcmTokenNotifier(),
);

final fcmInitializationProvider = FutureProvider<void>((ref) async {
  try {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null) {
      ref.read(fcmTokenProvider.notifier).setToken(token);
    }

    messaging.onTokenRefresh.listen((newToken) {
      ref.read(fcmTokenProvider.notifier).setToken(newToken);
      syncFcmTokenWithBackend(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  } catch (e) {
    debugPrint('[FCM] Initialization error: $e');
  }
});

/// Resolves the device's FCM push token, initializing Firebase Messaging
/// first if needed. Returns `null` when the token is unavailable.
Future<String?> getCurrentFcmToken(Ref ref) async {
  await ref.read(fcmInitializationProvider.future);
  return ref.read(fcmTokenProvider);
}

/// Saves the device's FCM push token so the backend (a) stores it on the
/// user's profile via `PATCH /api/v1/users/me` and (b) registers this device
/// via `POST /api/v1/devices/register`. Non-fatal on failure so push setup
/// never breaks the surrounding flow.
Future<void> syncFcmTokenWithBackend(String fcmToken) async {
  try {
    await ApiClient().patch(
      ApiEndpoints.myProfile,
      body: {'fcmToken': fcmToken},
    );
    debugPrint('[FCM] Token synced to profile');
  } catch (e) {
    debugPrint('[FCM] Token sync to profile failed: $e');
  }

  await registerFcmDevice(fcmToken);
}

/// Registers this device with the backend (`POST /api/v1/devices/register`)
/// so it can receive push notifications. Non-fatal on failure.
Future<void> registerFcmDevice(String fcmToken) async {
  try {
    await ApiClient().post(
      ApiEndpoints.devicesRegister,
      body: {
        'fcmToken': fcmToken,
        'platform': _devicePlatform(),
        'deviceId': _getDeviceId(),
      },
    );
    debugPrint('[FCM] Device registered for notifications');
  } catch (e) {
    debugPrint('[FCM] Device registration failed: $e');
  }
}

void _handleForegroundMessage(RemoteMessage message) {
  final data = message.data;
  debugPrint('[FCM] Foreground message: $data');
}

void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  final orderId = data['orderId'] ?? data['order_id'];
  debugPrint('[FCM] Notification tap for order: $orderId');
}
