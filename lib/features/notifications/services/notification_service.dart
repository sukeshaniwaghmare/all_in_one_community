import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static int _badgeCount = 0;
  static Function(String)? onChatTap;
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    await _loadBadgeCount();
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.startsWith('chat_')) {
      final chatId = response.payload!.replaceFirst('chat_', '');
      onChatTap?.call(chatId);
    }
    clearBadge();
  }

  static Future<void> _loadBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    _badgeCount = prefs.getInt('badge_count') ?? 0;
  }

  static Future<void> _saveBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('badge_count', _badgeCount);
  }

  static Future<void> incrementBadge() async {
    _badgeCount++;
    await _saveBadgeCount();
  }

  static Future<void> clearBadge() async {
    _badgeCount = 0;
    await _saveBadgeCount();
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifications for chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: _badgeCount,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> showChatNotification({
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    await incrementBadge();
    
    await _showLocalNotification(
      title: senderName,
      body: message.startsWith('IMAGE:') ? '📷 Photo' : 
            message.startsWith('VIDEO:') ? '🎥 Video' : message,
      payload: 'chat_$chatId',
    );
  }

  static int get badgeCount => _badgeCount;
}
