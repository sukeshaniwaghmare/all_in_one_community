import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static int _badgeCount = 0;
  static String? _currentChatUserId;

  static void setCurrentChat(String? userId) {
    _currentChatUserId = userId;
  }

  static Future<void> initialize() async {
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    const androidChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      final token = await _messaging.getToken();
      if (token != null) {
        print('📱 FCM Token: ${token.substring(0, 20)}...');
        await _storeFCMToken(token);
      }
      
      _messaging.onTokenRefresh.listen(_storeFCMToken);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } catch (e) {
    }
    
    await _loadBadgeCount();
    
  }

  static Future<void> _updateFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _storeFCMToken(token);
      }
    } catch (e) {
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
      } else {
      
      }
    } catch (e) {
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
  
    final data = message.data;
    final senderId = data['sender_id'];
    final senderName = data['sender_name'] ?? 'Someone';
    final messageText = data['message'] ?? 'New message';
    
 
    
    // Don't show if chat is open with this sender
    if (_currentChatUserId == senderId) {
      return;
    }
    
    if (senderId != _supabase.auth.currentUser?.id) {
      await _showLocalNotification(senderName, messageText, senderId);
      await _incrementBadgeCount();
    } else {
    }
  }

  static Future<void> _handleNotificationTap(RemoteMessage message) async {

  }

  static void _onNotificationTap(NotificationResponse response) {
  }

  static Future<void> _showLocalNotification(String title, String body, String senderId) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_messages',
          'Chat Messages',
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          number: _badgeCount,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: _badgeCount,
        ),
      ),
      payload: senderId,
    );
  }

  static Future<void> _incrementBadgeCount() async {
    _badgeCount++;
    await _saveBadgeCount();
  }

  static Future<void> clearBadgeCount() async {
    _badgeCount = 0;
    await _saveBadgeCount();
  }

  static Future<void> _saveBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('badge_count', _badgeCount);
  }

  static Future<void> _loadBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    _badgeCount = prefs.getInt('badge_count') ?? 0;
  }

  static int get badgeCount => _badgeCount;

  static Future<void> showNotification(String title, String body, String senderId) async {
    if (_currentChatUserId == senderId) {
      return;
    }
    
    await _showLocalNotification(title, body, senderId);
    await _incrementBadgeCount();
  }
}