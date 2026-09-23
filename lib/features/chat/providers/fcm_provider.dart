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
///
/// Token acquisition runs FIRST and is isolated from the optional extras
/// (permissions, local-notification setup, listeners) so an exception in any
/// of those can never stop the token from being registered. If `getToken()`
/// still returns empty (e.g. Firebase not configured on the platform yet),
/// the token is retried a few seconds later — one failed attempt should never
/// leave the user without push for the rest of the session.
final fcmInitializationProvider = FutureProvider<void>((ref) async {
  final messaging = FirebaseMessaging.instance;

  // 1) Token: get it, cache it, register it. Nothing else is allowed to
  //    prevent this — a banner can still be sent even without permissions.
  await _acquireAndRegisterFcmToken(ref, messaging);

  // 2) Permission + local-notifications (optional; never fatal).
  try {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint('[FCM] requestPermission failed: $e');
  }
  try {
    await LocalNotifications.instance.init();
    await LocalNotifications.instance.requestDarwinPermissions();
  } catch (e) {
    debugPrint('[FCM] Local notifications setup failed: $e');
  }

  // 3) Listeners (token refresh, tapping in all app states).
  try {
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
    debugPrint('[FCM] Listener setup error: $e');
  }
});

/// Fetches the FCM token and registers it with every backend surface that
/// stores it. Loudly logs each outcome so a missing/empty token is easy to
/// see in the device logs (`[FCM] Token=...`, `[FCM] register=...`).
Future<void> _acquireAndRegisterFcmToken(
  Ref ref,
  FirebaseMessaging messaging,
) async {
  String? token = await _safeGetToken(messaging);

  if (token == null || token.isEmpty) {
    debugPrint('[FCM] Token=EMPTY|null — Firebase not ready. Retrying '
        'registerFcmTokenToken in 5s.');
    await Future<void>.delayed(const Duration(seconds: 5));
    token = await _safeGetToken(messaging);
    if (token == null || token.isEmpty) {
      debugPrint('[FCM] Token=EMPTY after retry. Check google-services.json '
          'and device Play-Services/APNs config.');
      return;
    }
  }

  ref.read(fcmTokenProvider.notifier).setToken(token);
  debugPrint('[FCM] Token=${token.substring(0, 10)}…${token.length} chars');
  await registerFcmToken(token);
}

Future<String?> _safeGetToken(FirebaseMessaging messaging) async {
  try {
    return await messaging.getToken();
  } catch (e) {
    debugPrint('[FCM] getToken() threw: $e');
    return null;
  }
}

/// Resolves the device's FCM push token, initializing Firebase Messaging
/// first if needed. Returns `null` when the token is unavailable. Reading
/// this also triggers token registration on every app launch/login.
Future<String?> getCurrentFcmToken(Ref ref) async {
  await ref.read(fcmInitializationProvider.future);
  return ref.read(fcmTokenProvider);
}

/// Registers this device's FCM token with the backend on every surface the
/// server stores tokens on:
///  - `POST   /api/v1/notifications/tokens` `{token}`  (push-token registry)
///  - `PATCH  /api/v1/users/me`             `{fcmToken}` (user profile)
///
/// Registering via both is a belt-and-braces measure: whichever route the
/// notification worker reads (`user.fcmTokens` vs the token endpoint) ends up
/// populated. Both are non-fatal and loudly log the outcome.
Future<void> registerFcmToken(String fcmToken) async {
  try {
    final res = await ApiClient().post(
      ApiEndpoints.notificationTokens,
      body: {'token': fcmToken},
    );
    debugPrint(
      '[FCM] register tokens endpoint: ${res.success} '
      '(${res.statusCode}) ${res.message}',
    );
  } catch (e) {
    debugPrint('[FCM] register tokens endpoint failed: $e');
  }

  try {
    final res = await ApiClient().patch(
      ApiEndpoints.myProfile,
      body: {'fcmToken': fcmToken},
    );
    debugPrint(
      '[FCM] register profile endpoint: ${res.success} '
      '(${res.statusCode}) ${res.message}',
    );
  } catch (e) {
    debugPrint('[FCM] register profile endpoint failed: $e');
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
    debugPrint(
      '[FCM] Token removed (${res.success}) '
      '(${res.statusCode}) ${res.message}',
    );
  } catch (e) {
    debugPrint('[FCM] Token removal failed: $e');
  }
}

int _notificationIdFor(Map<String, dynamic> data) {
  final id = data['orderId'] ?? data['order_id'] ?? data['notificationId'];
  return (id is String && id.isNotEmpty) ? id.hashCode : DateTime.now().millisecondsSinceEpoch;
}