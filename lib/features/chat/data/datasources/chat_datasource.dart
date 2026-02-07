import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      
      // Get all users
      final usersResponse = await _supabaseService.client
          .from('user_profiles')
          .select('id, full_name, avatar_url, bio, phone, email, created_at');

      print('Found ${usersResponse.length} users');
      
      // Get last message for each user
      final chats = <Chat>[];
      
      for (var user in usersResponse) {
        final userId = user['id'];
        
        // Get last message between current user and this user
        final lastMessageResponse = await _supabaseService.client
            .from('messages')
            .select('message, created_at')
            .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$userId),and(sender_id.eq.$userId,receiver_id.eq.$currentUserId)')
            .order('created_at', ascending: false)
            .limit(1);
        
        final chat = Chat.fromUserProfile(user);
        
        // Update with last message info if exists
        if (lastMessageResponse.isNotEmpty) {
          final lastMsg = lastMessageResponse.first;
          chats.add(chat.copyWith(
            lastMessage: lastMsg['message'] ?? '',
            lastMessageTime: DateTime.parse(lastMsg['created_at']),
          ));
        } else {
          chats.add(chat);
        }
      }
      
      // Get user's groups
      try {
        final groupMembersResponse = await _supabaseService.client
            .from('group_members')
            .select('group_id')
            .eq('user_id', currentUserId);
        
        for (var groupMember in groupMembersResponse) {
          final groupId = groupMember['group_id'];
          
          // Get group details
          final groupResponse = await _supabaseService.client
              .from('groups')
              .select('id, name, avatar_url, created_at')
              .eq('id', groupId)
              .single();
          
          // Get last message for this group
          final lastGroupMessage = await _supabaseService.client
              .from('group_messages')
              .select('message, created_at')
              .eq('group_id', groupId)
              .order('created_at', ascending: false)
              .limit(1);
          
          final groupChat = Chat(
            id: groupId,
            name: groupResponse['name'] ?? 'Group',
            lastMessage: lastGroupMessage.isNotEmpty ? lastGroupMessage.first['message'] : 'No messages yet',
            lastMessageTime: lastGroupMessage.isNotEmpty 
                ? DateTime.parse(lastGroupMessage.first['created_at'])
                : DateTime.parse(groupResponse['created_at']),
            unreadCount: 0,
            isGroup: true,
            receiverUserId: groupId,
          );
          
          chats.add(groupChat);
        }
      } catch (e) {
        print('Error loading groups: $e');
      }
      
      // Sort by last message time (most recent first)
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      return chats;
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

      print('Getting messages for chatId: $chatId');
      
      // Check if this is a group by checking group_members table
      final groupCheck = await _supabaseService.client
          .from('group_members')
          .select('group_id')
          .eq('group_id', chatId)
          .limit(1);
      
      final isGroup = groupCheck.isNotEmpty;
      
      if (isGroup) {
        // Fetch group messages
        final response = await _supabaseService.client
            .from('group_messages')
            .select('*')
            .eq('group_id', chatId)
            .order('created_at', ascending: true);
        
        print('Got ${response.length} messages');
        
        // Fetch sender names
        final senderIds = response.map((m) => m['sender_id']).toSet().toList();
        final senderNames = <String, String>{};
        
        for (final senderId in senderIds) {
          try {
            final user = await _supabaseService.client
                .from('user_profiles')
                .select('full_name')
                .eq('id', senderId)
                .single();
            senderNames[senderId] = user['full_name'] ?? 'Unknown User';
          } catch (e) {
            senderNames[senderId] = 'Unknown User';
          }
        }
        
        return response.map<ChatMessage>((json) {
          return ChatMessage(
            id: json['id'].toString(),
            text: json['message'] ?? '',
            senderId: json['sender_id'],
            receiverId: chatId,
            senderName: senderNames[json['sender_id']] ?? 'Unknown User',
            timestamp: DateTime.parse(json['created_at']),
            type: _getMessageTypeFromString(json['message_type']),
            mediaUrl: json['media_url'],
            isMe: json['sender_id'] == currentUserId,
          );
        }).toList();
      } else {
        // Fetch regular messages
        final response = await _supabaseService.client
            .from('messages')
            .select('*')
            .or(
                'and(sender_id.eq.$currentUserId,receiver_id.eq.$chatId),and(sender_id.eq.$chatId,receiver_id.eq.$currentUserId)')
            .order('created_at', ascending: true);

        print('Got ${response.length} messages');

        // Fetch sender names for all unique sender IDs
        final senderIds = response.map((m) => m['sender_id']).toSet().toList();
        final senderNames = <String, String>{};
        
        for (final senderId in senderIds) {
          try {
            final user = await _supabaseService.client
                .from('user_profiles')
                .select('full_name')
                .eq('id', senderId)
                .single();
            senderNames[senderId] = user['full_name'] ?? 'Unknown User';
          } catch (e) {
            senderNames[senderId] = 'Unknown User';
          }
        }

        return response.map<ChatMessage>((json) {
          json['sender_name'] = senderNames[json['sender_id']] ?? 'Unknown User';
          return ChatMessage.fromJson(json, currentUserId);
        }).toList();
      }
    } catch (e) {
      print('Error getting messages: $e');
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
      if (message.text.startsWith('IMAGES:')) {
        messageType = 'image';
        final imagePaths = message.text.substring(7).split('|||');
        final uploadedUrls = <String>[];
        
        for (int i = 0; i < imagePaths.length; i++) {
          final url = await uploadImageToStorage(imagePaths[i]);
          if (url != null) uploadedUrls.add(url);
        }
        
        mediaUrl = uploadedUrls.join('|||');
        finalMessageText = '${imagePaths.length} Images';
      } else if (message.text.startsWith('IMAGE:')) {
        messageType = 'image';
        final imagePath = message.text.substring(6);
        
        // Upload image to Supabase Storage
        mediaUrl = await uploadImageToStorage(imagePath);
        finalMessageText = 'Image';
      } else if (message.text.startsWith('VIDEO:')) {
        messageType = 'video';
        final videoPath = message.text.substring(6);
        
        // Upload video to Supabase Storage
        mediaUrl = await uploadVideoToStorage(videoPath);
        finalMessageText = 'Video';
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
      
      // Send FCM notification directly
      try {
        await _sendFcmNotification(message.senderId, message.receiverId, finalMessageText);
      } catch (e) {
      }
    } catch (e) {
     
      throw Exception('Failed to send message: $e');
    }
  }

  /// Upload image to Supabase Storage
  Future<String?> uploadImageToStorage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
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
  Future<String?> uploadVideoToStorage(String videoPath) async {
    try {
      print('📹 Starting video upload: $videoPath');
      final file = File(videoPath);
      if (!file.existsSync()) {
        print('❌ Video file does not exist: $videoPath');
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

      print('✅ Video uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading video: $e');
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

  /// Send notification using HTTP call to FCM
  Future<void> _sendFcmNotification(String senderId, String receiverId, String message) async {
    try {
      final supabase = _supabaseService.client;
      
      final receiver = await supabase
          .from('user_profiles')
          .select('fcm_token')
          .eq('id', receiverId)
          .single();
      
      final fcmToken = receiver['fcm_token'];
      if (fcmToken == null) return;
      
      final sender = await supabase
          .from('user_profiles')
          .select('full_name')
          .eq('id', senderId)
          .single();
      
      final senderName = sender['full_name'] ?? 'Someone';
      
      // Send via FCM
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${dotenv.env['FCM_SERVER_KEY'] ?? ''}',
        },
        body: jsonEncode({
          'to': fcmToken,
          'priority': 'high',
          'notification': {
            'title': senderName,
            'body': message,
            'sound': 'default',
          },
          'data': {
            'sender_id': senderId,
            'sender_name': senderName,
            'message': message,
          },
        }),
      );
    } catch (e) {
    }
  }

  MessageType _getMessageTypeFromString(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

}
