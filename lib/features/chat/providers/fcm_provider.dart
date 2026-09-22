import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/core/notifications/deep_link_handler.dart';
import 'package:market_mate/core/notifications/local_notifications.dart';

class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String token) => state = token;
}

final fcmTokenProvider = NotifierProvider<FcmTokenNotifier, String?>(
  () => FcmTokenNotifier(),
);

/// Initializes Firebase Messaging and wires up all three notification states:
///
///  - Terminated:  `getInitialMessage()` routes the tap once the app is up.
///  - Background:  `onMessageOpenedApp` routes the tap immediately.
///  - Foreground:  `onMessage` shows a heads-up via [LocalNotifications].
///
/// Also registers the device token with the backend on launch/login so push
/// delivery is always configured. Reading this provider waits for completion.
final fcmInitializationProvider = FutureProvider<void>((ref) async {
  try {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await LocalNotifications.instance.init();
    await LocalNotifications.instance.requestDarwinPermissions();

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      ref.read(fcmTokenProvider.notifier).setToken(token);
      unawaited(registerFcmToken(token));
    }

    messaging.onTokenRefresh.listen((newToken) {
      ref.read(fcmTokenProvider.notifier).setToken(newToken);
      unawaited(registerFcmToken(newToken));
    });

    // Foreground: present the message as a heads-up alert.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      LocalNotifications.instance.show(
        id: _notificationIdFor(data),
        title:
            message.notification?.title ??
            data['title'] ??
            'MarketMate',
        body: message.notification?.body ?? data['body'] ?? '',
        imageUrl: data['image_url'],
      );
    });

    // Background (minimized): tap routes the user into the target screen.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationDeepLink(message.data, ref: ref);
    });

    // Terminated (app closed): route the initial notification if one exists.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationDeepLink(initialMessage.data, ref: ref);
    }
  } catch (e) {
    debugPrint('[FCM] Initialization error: $e');
  }
});

/// Resolves the device's FCM push token, initializing Firebase Messaging
/// first if needed. Returns `null` when the token is unavailable. Reading
/// this also triggers token registration on every app launch/login.
Future<String?> getCurrentFcmToken(Ref ref) async {
  await ref.read(fcmInitializationProvider.future);
  return ref.read(fcmTokenProvider);
}

/// Registers this device's FCM token with the backend
/// (`POST /api/v1/notifications/tokens`). Non-fatal on failure so push setup
/// never breaks the surrounding flow.
Future<void> registerFcmToken(String fcmToken) async {
  try {
    final res = await ApiClient().post(
      ApiEndpoints.notificationTokens,
      body: {'token': fcmToken},
    );
    debugPrint('[FCM] Token registered (${res.success})');
  } catch (e) {
    debugPrint('[FCM] Token registration failed: $e');
  }
}

/// Removes this device's FCM token on logout
/// (`DELETE /api/v1/notifications/tokens`). Non-fatal on failure.
Future<void> removeFcmToken(String fcmToken) async {
  try {
    final res = await ApiClient().delete(
      ApiEndpoints.notificationTokens,
      body: {'token': fcmToken},
    );
    debugPrint('[FCM] Token removed (${res.success})');
  } catch (e) {
    debugPrint('[FCM] Token removal failed: $e');
  }
}

int _notificationIdFor(Map<String, dynamic> data) {
  final id = data['orderId'] ?? data['order_id'] ?? data['notificationId'];
  return (id is String && id.isNotEmpty) ? id.hashCode : DateTime.now().millisecondsSinceEpoch;
}