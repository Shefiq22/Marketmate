import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';

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
      _registerToken(token);
    }

    messaging.onTokenRefresh.listen((newToken) {
      ref.read(fcmTokenProvider.notifier).setToken(newToken);
      _registerToken(newToken);
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

void _registerToken(String token) async {
  try {
    await ApiClient().post(
      ApiEndpoints.devicesRegister,
      body: {'token': token, 'platform': 'android'},
    );
    debugPrint('[FCM] Token registered');
  } catch (e) {
    debugPrint('[FCM] Token registration failed: $e');
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
