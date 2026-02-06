import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/chat_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UnreadCountProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  int _totalUnreadCount = 0;
  RealtimeChannel? _subscription;

  int get totalUnreadCount => _totalUnreadCount;

  Future<void> initialize() async {
    await _loadUnreadCount();
    _subscribeToUpdates();
  }

  Future<void> _loadUnreadCount() async {
    _totalUnreadCount = await _chatService.getTotalUnreadCount();
    _updateBadge();
    notifyListeners();
  }

  void _subscribeToUpdates() {
    _subscription = _chatService.subscribeToUnreadCounts((count) {
      _totalUnreadCount = count;
      _updateBadge();
      notifyListeners();
    });
  }

  Future<void> markAsRead(String senderId) async {
    await _chatService.markMessagesAsRead(senderId);
    await _loadUnreadCount();
  }

  void _updateBadge() {
    if (_totalUnreadCount > 0) {
      _notifications.show(
        0,
        '',
        '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'badge_channel',
            'Badge',
            importance: Importance.low,
            priority: Priority.low,
            number: _totalUnreadCount,
            playSound: false,
            enableVibration: false,
          ),
        ),
      );
    } else {
      _notifications.cancel(0);
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
