import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FCMService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static int _badgeCount = 0;

  static Future<void> initialize() async {
    // Initialize local notifications
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
    
    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    // Request FCM permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get and store FCM token
    await _updateFCMToken();
    
    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_storeFCMToken);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Load initial badge count
    await _loadBadgeCount();
    
    print('FCM Service initialized');
  }

  static Future<void> _updateFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _storeFCMToken(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  static Future<void> _storeFCMToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase
            .from('user_profiles')
            .update({'fcm_token': token})
            .eq('id', userId);
        print('FCM token stored: $token');
      }
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.data}');
    
    final data = message.data;
    final senderId = data['sender_id'];
    final senderName = data['sender_name'] ?? 'Someone';
    final messageText = data['message'] ?? 'New message';
    
    // Don't show notification for own messages
    if (senderId != _supabase.auth.currentUser?.id) {
      await _showLocalNotification(
        senderName,
        messageText,
        senderId,
      );
      await _incrementBadgeCount();
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background message received: ${message.data}');
    await _incrementBadgeCount();
  }

  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.data}');
    // Navigate to chat screen
  }

  static void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Navigate to chat screen using the payload (sender_id)
  }

  static Future<void> _showLocalNotification(String title, String body, String senderId) async {
    final androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      autoCancel: true,
      category: AndroidNotificationCategory.message,
      number: _badgeCount,
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: _badgeCount,
      interruptionLevel: InterruptionLevel.active,
    );
    
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: senderId,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> _incrementBadgeCount() async {
    _badgeCount++;
    await _saveBadgeCount();
    await _updateAppBadge();
  }

  static Future<void> clearBadgeCount() async {
    _badgeCount = 0;
    await _saveBadgeCount();
    await _updateAppBadge();
  }

  static Future<void> _updateAppBadge() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              'badge_update',
              'Badge Update',
              importance: Importance.low,
            ),
          );
    } catch (e) {
      print('Error updating app badge: $e');
    }
  }

  static Future<void> _saveBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('badge_count', _badgeCount);
  }

  static Future<void> _loadBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    _badgeCount = prefs.getInt('badge_count') ?? 0;
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase
            .from('user_profiles')
            .update({
              'is_online': isOnline,
              'last_seen': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  static int get badgeCount => _badgeCount;
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Background message: ${message.data}');
}