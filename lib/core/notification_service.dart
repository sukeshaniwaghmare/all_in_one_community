import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission();
    
    // Initialize local notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios)
    );

    // Listen to messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Get FCM token
    String? token = await _messaging.getToken();
    print('🔥 FCM Token: $token');
    
    _listenToSupabaseMessages();
  }

  void _listenToSupabaseMessages() {
    Supabase.instance.client
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final message = payload.newRecord;
            final currentUserId = Supabase.instance.client.auth.currentUser?.id;
            
            if (message['receiver_id'] == currentUserId) {
              _showLocalNotification(message);
            }
          },
        )
        .subscribe();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Foreground message: ${message.notification?.title}');
    await _showLocalNotification({
      'message': message.notification?.body ?? '',
      'id': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _showLocalNotification(Map<String, dynamic> message) async {
    String messageText = message['message'] ?? '';
    if (messageText.startsWith('IMAGE:')) {
      messageText = '📷 Photo';
    }

    await _localNotifications.show(
      message['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'New Message',
      messageText,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          'Chat Messages',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  void clearBadge() {
    print('🔔 Badge cleared');
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('📱 Background message: ${message.notification?.title}');
}