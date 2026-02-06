import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackgroundMessageHandler {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static String? _currentChatUserId;
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(settings);
    await _requestPermissions();
    
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    
    Supabase.instance.client
        .channel('messages_background')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) async {
            await _handleNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }

  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void setCurrentChat(String? userId) {
    _currentChatUserId = userId;
  }

  static Future<void> _handleNewMessage(Map<String, dynamic> message) async {
    // Don't show notification if chat is open with this sender
    if (_currentChatUserId == message['sender_id']) return;
    
    final unreadCount = await _getUnreadCount();

    await _notifications.show(
      message['id'].hashCode,
      'New Message',
      message['content'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          'Chat Messages',
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.high,
          priority: Priority.high,
          number: unreadCount,
        ),
        iOS: DarwinNotificationDetails(
          badgeNumber: unreadCount,
        ),
      ),
    );
  }

  static Future<int> _getUnreadCount() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;
    
    final response = await Supabase.instance.client
        .from('unread_counts')
        .select('unread_count')
        .eq('user_id', userId)
        .maybeSingle();
    
    return response?['unread_count'] ?? 0;
  }
}
