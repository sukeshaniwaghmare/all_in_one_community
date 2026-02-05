import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../../../../core/supabase_service.dart';

class ChatDataSource {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// =========================
  /// GET CHATS
  /// =========================
  Future<List<Chat>> getChats() async {
    try {
      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('user_profiles')
          .select(
              'id, full_name, username, avatar_url, bio, phone, email, created_at')
          .neq('id', currentUserId);

      return response.map<Chat>((json) {
        return Chat.fromUserProfile(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load chats: $e');
    }
  }

  /// =========================
  /// GET MESSAGES
  /// =========================
  Future<List<ChatMessage>> getMessages(String chatId) async {
    try {
      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('messages')
          .select('*')
          .or(
              'and(sender_id.eq.$currentUserId,receiver_id.eq.$chatId),and(sender_id.eq.$chatId,receiver_id.eq.$currentUserId)')
          .order('created_at', ascending: true);

      return response
          .map<ChatMessage>((json) =>
              ChatMessage.fromJson(json, currentUserId))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// =========================
  /// SEND MESSAGE (TEXT / IMAGE)
  /// =========================
  Future<void> sendMessage(ChatMessage message) async {
    try {
      final supabase = _supabaseService.client;

      String finalMessageText = message.text;
      String messageType = 'text';

      /// -------- IMAGE HANDLING --------
      if (message.text.startsWith('IMAGE:')) {
        messageType = 'image';

        final localPath = message.text.substring(6);
        final file = File(localPath);

        if (!file.existsSync()) {
          throw Exception('Image file not found');
        }

        final fileName =
            'chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload image to Supabase Storage
        await supabase.storage
            .from('chat-media')
            .upload(fileName, file);

        // Get public URL
        final imageUrl = supabase.storage
            .from('chat-media')
            .getPublicUrl(fileName);

        finalMessageText = 'IMAGE:$imageUrl';
      }

      /// -------- VIDEO / FILE (future ready) --------
      if (message.type == MessageType.video) {
        messageType = 'video';
      } else if (message.type == MessageType.audio) {
        messageType = 'audio';
      } else if (message.type == MessageType.file) {
        messageType = 'file';
      }

      /// -------- INSERT MESSAGE --------
      print('About to insert: sender=${message.senderId}, receiver=${message.receiverId}, message=$finalMessageText, type=$messageType');
      
      await supabase.from('messages').insert([
        {
          'sender_id': message.senderId,
          'receiver_id': message.receiverId,
          'message': finalMessageText,
          'message_type': messageType,
          'is_read': false,      
          'status': 'sent',   
        }
      ]);
      
      print('Message inserted successfully');
    } catch (e) {
      print('Detailed error: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Failed to send message: $e');
    }
  }


  Future<void> markMessagesAsDelivered(String chatUserId) async {
  final myId = _supabaseService.currentUserId;
  if (myId == null) return;

  await _supabaseService.client
      .from('messages')
      .update({'status': 'delivered'})
      .eq('sender_id', chatUserId)
      .eq('receiver_id', myId)
      .eq('status', 'sent');
}


Future<void> markMessagesAsRead(String chatUserId) async {
  final myId = _supabaseService.currentUserId;
  if (myId == null) return;

  await _supabaseService.client
      .from('messages')
      .update({
        'is_read': true,
        'status': 'read', // ✔✔ blue
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('sender_id', chatUserId)
      .eq('receiver_id', myId)
      .eq('is_read', false);
}

}
