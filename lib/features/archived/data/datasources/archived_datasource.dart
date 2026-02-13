import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/archived_chat_model.dart';

class ArchivedDataSource {
  final _supabase = Supabase.instance.client;

  Future<List<ArchivedChat>> getArchivedChats(String userId) async {
    final response = await _supabase
        .from('archived_chats')
        .select()
        .eq('user_id', userId)
        .order('archived_at', ascending: false);
    
    return (response as List).map((json) => ArchivedChat.fromJson(json)).toList();
  }

  Future<void> archiveChat(String chatId, String userId) async {
    await _supabase.from('archived_chats').insert({
      'chat_id': chatId,
      'user_id': userId,
      'archived_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unarchiveChat(String chatId, String userId) async {
    await _supabase
        .from('archived_chats')
        .delete()
        .eq('chat_id', chatId)
        .eq('user_id', userId);
  }

  Stream<List<ArchivedChat>> watchArchivedChats(String userId) {
    return _supabase
        .from('archived_chats')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('archived_at', ascending: false)
        .map((data) => data.map((json) => ArchivedChat.fromJson(json)).toList());
  }
}
