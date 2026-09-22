import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

/// Wraps [FlutterLocalNotificationsPlugin] so foreground FCM messages can
/// show a heads-up alert. Rich images render with a big-picture style on
/// Android (and a notification attachment on iOS) when `image_url` is present.
class LocalNotifications {
  LocalNotifications._();
  static final LocalNotifications instance = LocalNotifications._();

  static const String channelId = 'marketmate_high_importance';
  static const String channelName = 'High Importance';
  static const String channelDescription =
      'Important order and promotion notifications';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
    );
    _initialized = true;

    // Android 13+ requires the POST_NOTIFICATIONS runtime permission.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> requestDarwinPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    if (!_initialized) return;

    Uint8List? imageBytes;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageBytes = await _downloadImage(imageUrl);
    }

    final androidDetails = _buildAndroidDetails(title, body, imageBytes);
    final darwinDetails = _buildDarwinDetails(id, imageBytes);

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: darwinDetails),
    );
  }

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) return res.bodyBytes;
    } catch (e) {
      debugPrint('[LocalNotifications] Image download failed: $e');
    }
    return null;
  }

  AndroidNotificationDetails _buildAndroidDetails(
    String title,
    String body,
    Uint8List? imageBytes,
  ) {
    final base = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    if (imageBytes == null) return base;

    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigPictureStyleInformation(
        ByteArrayAndroidBitmap(imageBytes),
        largeIcon: ByteArrayAndroidBitmap(imageBytes),
        contentTitle: title,
        summaryText: body,
      ),
    );
  }

  DarwinNotificationDetails _buildDarwinDetails(
    int id,
    Uint8List? imageBytes,
  ) {
    if (imageBytes == null) return const DarwinNotificationDetails();

    try {
      final file =
          File('${Directory.systemTemp.path}/mm_notif_$id.jpg');
      file.writeAsBytesSync(imageBytes);
      return DarwinNotificationDetails(
        attachments: [DarwinNotificationAttachment(file.path)],
      );
    } catch (e) {
      debugPrint('[LocalNotifications] iOS attachment failed: $e');
      return const DarwinNotificationDetails();
    }
  }
}