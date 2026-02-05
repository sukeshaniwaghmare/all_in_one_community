import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:isolate';
import 'dart:ui';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _isolateName = 'notification_isolate';

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    // Request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Setup background isolate
    IsolateNameServer.registerPortWithName(
      ReceivePort().sendPort,
      _isolateName,
    );
    
    print('Setting up realtime listener for messages...');
    
    // Listen to new messages with better error handling
    try {
      _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .listen(
            _handleNewMessage,
            onError: (error) {
              print('Realtime stream error: $error');
            },
          );
      print('Realtime listener setup complete');
    } catch (e) {
      print('Error setting up realtime listener: $e');
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Navigate to chat screen using the payload (chat_id)
  }

  static void _handleNewMessage(List<Map<String, dynamic>> data) {
    print('=== REALTIME EVENT RECEIVED ===');
    print('Received ${data.length} messages');
    final currentUserId = _supabase.auth.currentUser?.id;
    print('Current user ID: $currentUserId');
    
    for (final message in data) {
      print('Message data: $message');
      print('Message: ${message['sender_id']} -> ${message['message']}');
      // Don't notify for own messages
      if (message['sender_id'] != currentUserId) {
        print('Showing notification for message from ${message['sender_id']}');
        _showNotification(
          'New Message',
          message['message']?.toString() ?? 'You have a new message',
          message['receiver_id']?.toString() ?? '0',
        );
      } else {
        print('Skipping own message');
      }
    }
    print('=== END REALTIME EVENT ===');
  }

  // Test function to manually show notification
  static Future<void> testNotification() async {
    print('Testing notification...');
    await _showNotification('Test', 'This is a test notification', '123');
  }

  static Future<void> _showNotification(String title, String body, String chatId) async {
    print('Attempting to show notification: $title - $body');
    
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      autoCancel: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: chatId,
      );
      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}