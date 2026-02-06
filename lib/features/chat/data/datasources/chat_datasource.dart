import 'dart:io';
import 'dart:convert';
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

      print('Current user ID: $currentUserId');
      
      final response = await _supabaseService.client
          .from('user_profiles')
          .select(
              'id, full_name, avatar_url, bio, phone, email, created_at');

      print('Found ${response.length} users');
      if (response.isNotEmpty) {
        print('First user: ${response.first}');
      }

      return response.map<Chat>((json) {
        return Chat.fromUserProfile(json);
      }).toList();
    } catch (e) {
      print('getChats error: $e');
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
      String? mediaUrl;

      /// -------- IMAGE/VIDEO HANDLING --------
      if (message.text.startsWith('IMAGE:')) {
        messageType = 'image';
        final imagePath = message.text.substring(6);
        print('Image path: $imagePath');
        
        // Upload image to Supabase Storage
        mediaUrl = await _uploadImageToStorage(imagePath);
        finalMessageText = 'Image';
        print('Uploaded image URL: $mediaUrl');
      } else if (message.text.startsWith('VIDEO:')) {
        messageType = 'video';
        final videoPath = message.text.substring(6);
        
        // Upload video to Supabase Storage
        mediaUrl = await _uploadVideoToStorage(videoPath);
        finalMessageText = 'Video';
        print('Uploaded video URL: $mediaUrl');
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
          'media_url': mediaUrl,
        }
      ]);
      
      print('Message sent successfully');
    } catch (e) {
      print('Detailed error: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Failed to send message: $e');
    }
  }

  /// Upload image to Supabase Storage
  Future<String?> _uploadImageToStorage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        print('Image file does not exist: $imagePath');
        return null;
      }

      final fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final imageBytes = await file.readAsBytes();
      
      await _supabaseService.client.storage
          .from('chat-media')
          .uploadBinary(fileName, imageBytes);

      final publicUrl = _supabaseService.client.storage
          .from('chat-media')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload video to Supabase Storage
  Future<String?> _uploadVideoToStorage(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!file.existsSync()) {
        print('Video file does not exist: $videoPath');
        return null;
      }

      final fileName = 'videos/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final videoBytes = await file.readAsBytes();
      
      await _supabaseService.client.storage
          .from('chat-media')
          .uploadBinary(fileName, videoBytes);

      final publicUrl = _supabaseService.client.storage
          .from('chat-media')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
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
