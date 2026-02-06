import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  Future<void> sendMessage(String receiverId, String content) async {
    await _supabase.from('messages').insert({
      'sender_id': _supabase.auth.currentUser!.id,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  Future<int> getTotalUnreadCount() async {
    final response = await _supabase
        .from('unread_counts')
        .select('unread_count')
        .eq('user_id', _supabase.auth.currentUser!.id);
    
    return (response as List).fold<int>(0, (sum, item) => sum + (item['unread_count'] as int));
  }

  Future<int> getUnreadCountForSender(String senderId) async {
    final response = await _supabase
        .from('unread_counts')
        .select('unread_count')
        .eq('user_id', _supabase.auth.currentUser!.id)
        .eq('sender_id', senderId)
        .maybeSingle();
    
    return response?['unread_count'] ?? 0;
  }

  Future<void> markMessagesAsRead(String senderId) async {
    final userId = _supabase.auth.currentUser!.id;
    
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', userId)
        .eq('sender_id', senderId)
        .eq('is_read', false);
    
    await _supabase
        .from('unread_counts')
        .update({'unread_count': 0})
        .eq('user_id', userId)
        .eq('sender_id', senderId);
  }

  RealtimeChannel subscribeToUnreadCounts(Function(int) onCountChanged) {
    return _supabase
        .channel('unread_counts_${_supabase.auth.currentUser!.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'unread_counts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _supabase.auth.currentUser!.id,
          ),
          callback: (payload) async {
            final count = await getTotalUnreadCount();
            onCountChanged(count);
          },
        )
        .subscribe();
  }

  Stream<List<Map<String, dynamic>>> getMessages(String otherUserId) {
    final userId = _supabase.auth.currentUser!.id;
    
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id']).order('created_at');
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String otherUserId) async {
    final userId = _supabase.auth.currentUser!.id;
    
    final response = await _supabase
        .from('messages')
        .select()
        .or('and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)')
        .order('created_at');
    
    return List<Map<String, dynamic>>.from(response);
  }
}
