import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/chat_model.dart';
import '../domain/usecases/get_chats_usecase.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/services/auth_service.dart';
import '../data/datasources/chat_datasource.dart';
import '../../notifications/services/services/fcm_service.dart';
import 'dart:async';

class ChatProvider extends ChangeNotifier {
  final GetChatsUseCase getChatsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final RealtimeService _realtimeService = RealtimeService();
  final AuthService _authService = AuthService();
  final ChatDataSource _chatDataSource = ChatDataSource();

  ChatProvider({
    required this.getChatsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  }) {
    _initializeRealtimeListeners();
  }

  List<Chat> _chats = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  /// ✅ This is RECEIVER USER ID (UUID)
  String? _currentReceiverUserId;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _chatSubscription;

  List<Chat> get chats => _chats;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // -------------------- LOAD CHATS --------------------

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _chats = await getChatsUseCase();
      _sortChatsByRecent();
    } catch (e) {
      _chats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------- LOAD MESSAGES --------------------

  /// receiverUserId = UUID
  Future<void> loadMessages(String receiverUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if receiverUserId is a valid UUID format
      if (!_isValidUUID(receiverUserId)) {
        _messages = [];
        return;
      }

      if (_currentReceiverUserId != receiverUserId) {
        _messages = [];
        _currentReceiverUserId = receiverUserId;
      }

      final newMessages = await getMessagesUseCase(receiverUserId);
      _messages = newMessages;

      _subscribeToMessages(receiverUserId);
    } catch (e) {
     
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual refresh for receiver - DISABLED
  Future<void> refreshMessages() async {
    // Disabled to prevent constant reloading
    return;
  }

  bool _isValidUUID(String uuid) {
    // More strict validation - only allow proper UUID format
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    final isValid = uuidRegex.hasMatch(uuid);
    
    // Also reject any UUID that starts with 'local_' or contains non-hex characters
    if (uuid.startsWith('local_') || uuid.contains('_')) {
      return false;
    }
    
    return isValid;
  }

  // -------------------- SEND MESSAGE --------------------

  Future<void> sendMessage(String text, String receiverUserId) async {
    final currentUserId = _authService.currentUserId;

    if (currentUserId == null) {
      return;
    }

    if (!_isValidUUID(receiverUserId)) {
      return;
    }

    // Check if this is a group chat
    final isGroup = _chats.firstWhere(
      (chat) => chat.receiverUserId == receiverUserId,
      orElse: () => Chat(id: '', name: '', lastMessage: '', lastMessageTime: DateTime.now(), unreadCount: 0, isGroup: false, receiverUserId: ''),
    ).isGroup;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: currentUserId,
      receiverId: receiverUserId,
      senderName: 'Me',
      timestamp: DateTime.now(),
      isMe: true,
    );

    _messages.add(message);
    
    // Update chat list
    final chatIndex = _chats.indexWhere((chat) => chat.receiverUserId == receiverUserId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: text.startsWith('IMAGES:') ? '${text.split('|||').length} Images' : 
                     text.startsWith('VIDEO:') ? 'Video' : text,
        lastMessageTime: DateTime.now(),
      );
      _sortChatsByRecent();
    }
    
    notifyListeners();

    try {
      if (isGroup) {
        // Handle video/image for groups
        String finalMessage = text;
        String? mediaUrl;
        
        if (text.startsWith('VIDEO:')) {
          print('📹 Group video upload starting...');
          final videoPath = text.substring(6);
          mediaUrl = await _chatDataSource.uploadVideoToStorage(videoPath);
          finalMessage = 'Video';
          print('📹 Group video uploaded: $mediaUrl');
        } else if (text.startsWith('IMAGE:')) {
          final imagePath = text.substring(6);
          mediaUrl = await _chatDataSource.uploadImageToStorage(imagePath);
          finalMessage = 'Image';
        }
        
        // Insert into group_messages table
        await Supabase.instance.client.from('group_messages').insert({
          'group_id': receiverUserId,
          'sender_id': currentUserId,
          'message': finalMessage,
          'message_type': text.startsWith('VIDEO:') ? 'video' : text.startsWith('IMAGE:') ? 'image' : 'text',
          'media_url': mediaUrl,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await sendMessageUseCase(message);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // -------------------- UPDATE CONTACT NAME --------------------

  void updateContactName(String oldName, String newName) {
    final index = _chats.indexWhere((chat) => chat.name == oldName);
    if (index != -1) {
      final oldChat = _chats[index];
      _chats[index] = Chat(
        id: oldChat.id,
        name: newName,
        lastMessage: oldChat.lastMessage,
        lastMessageTime: oldChat.lastMessageTime,
        unreadCount: oldChat.unreadCount,
        profileImage: oldChat.profileImage,
        bio: oldChat.bio,
        phone: oldChat.phone,
        email: oldChat.email,
        username: oldChat.username,
        isGroup: oldChat.isGroup,
        receiverUserId: oldChat.receiverUserId,
      );
      notifyListeners();
    }
  }

  // -------------------- DELETE GROUP --------------------

  void deleteGroup(String groupName) {
    _chats.removeWhere((chat) => chat.name == groupName && chat.isGroup);
    notifyListeners();
  }

  // -------------------- CREATE GROUP --------------------

  Future<void> createGroup(String groupName, List<String> memberIds) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) return;

      // Create group in database
      final response = await Supabase.instance.client
          .from('groups')
          .insert({
            'name': groupName,
            'created_by': currentUserId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final groupId = response['id'];

      // Add members to group
      final members = memberIds.map((memberId) => {
        'group_id': groupId,
        'user_id': memberId,
        'joined_at': DateTime.now().toIso8601String(),
      }).toList();

      // Add creator as member
      members.add({
        'group_id': groupId,
        'user_id': currentUserId,
        'joined_at': DateTime.now().toIso8601String(),
      });

      await Supabase.instance.client.from('group_members').insert(members);

      // Create local chat entry
      final newGroup = Chat(
        id: groupId,
        name: groupName,
        lastMessage: 'Group created',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isGroup: true,
        receiverUserId: groupId,
      );
      
      _chats.insert(0, newGroup);
      notifyListeners();
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  // -------------------- MESSAGE STATUS --------------------

  Future<void> markMessagesAsDelivered(String receiverUserId) async {
    try {
      await _chatDataSource.markMessagesAsDelivered(receiverUserId);
    } catch (e) {
    }
  }

  Future<void> markMessagesAsRead(String receiverUserId) async {
    try {
      await _chatDataSource.markMessagesAsRead(receiverUserId);
    } catch (e) {
    }
  }

  // -------------------- DELETE MESSAGE --------------------

  Future<void> deleteMessage(String messageId) async {
    try {
      print('🗑️ Deleting message ID: $messageId');
      
      // Delete from database using UUID string directly
      final response = await Supabase.instance.client
          .from('messages')
          .delete()
          .eq('id', messageId)
          .select();
      
      print('✅ Database response: $response');
      
      // Remove from local list
      final beforeCount = _messages.length;
      _messages.removeWhere((msg) => msg.id == messageId);
      final afterCount = _messages.length;
      
      print('✅ Removed from list. Before: $beforeCount, After: $afterCount');
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting message: $e');
      throw Exception('Failed to delete message: $e');
    }
  }

  // -------------------- REALTIME --------------------

  void _initializeRealtimeListeners() {
    _messageSubscription =
        _realtimeService.messageStream.listen(_handleNewMessage);

    _chatSubscription =
        _realtimeService.chatStream.listen(_handleChatUpdate);
  }

  void _subscribeToMessages(String receiverUserId) {
    _realtimeService.subscribeToMessages(receiverUserId);
  }

  void _handleNewMessage(Map<String, dynamic> data) async {
    final currentUserId = _authService.currentUserId;

    // Fetch sender name
    String senderName = 'User';
    try {
      final sender = await Supabase.instance.client
          .from('user_profiles')
          .select('full_name')
          .eq('id', data['sender_id'])
          .single();
      senderName = sender['full_name'] ?? 'User';
    } catch (e) {
      print('Error fetching sender name: $e');
    }

    final message = ChatMessage(
      id: data['id'].toString(),
      text: data['message'] ?? '',
      senderId: data['sender_id'],
      receiverId: data['receiver_id'],
      senderName: senderName,
      timestamp: DateTime.parse(data['created_at']),
      type: _getMessageTypeFromString(data['message_type']),
      mediaUrl: data['media_url'],
      isMe: data['sender_id'] == currentUserId,
    );

    // avoid duplicates
    if (_messages.any((m) => m.id == message.id)) {
      return;
    }

    print('Adding new message to list: ${message.text}');
    _messages.add(message);
    
    // Show notification if not own message
    if (!message.isMe) {
      _showLocalNotification(message.text, data['sender_id']);
    }
    
    notifyListeners();
  }

  Future<void> _showLocalNotification(String message, String senderId) async {
    try {
      final sender = await Supabase.instance.client
          .from('user_profiles')
          .select('full_name')
          .eq('id', senderId)
          .single();
      
      final senderName = sender['full_name'] ?? 'Someone';
      await FCMService.showNotification(senderName, message, senderId);
    } catch (e) {
      print('Error showing notification: $e');
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

  void _handleChatUpdate(Map<String, dynamic> data) {
    final currentUserId = _authService.currentUserId;

    final index = _chats.indexWhere(
      (chat) => chat.receiverUserId == data['sender_id'] ||
                chat.receiverUserId == data['receiver_id'],
    );

    if (index == -1) return;

    final chat = _chats[index];

    _chats[index] = chat.copyWith(
      lastMessage: data['message'],
      lastMessageTime: DateTime.parse(data['created_at']),
      unreadCount:
          chat.unreadCount + (data['sender_id'] != currentUserId ? 1 : 0),
    );

    _sortChatsByRecent();
    notifyListeners();
  }

  void _sortChatsByRecent() {
    _chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _chatSubscription?.cancel();
    _realtimeService.dispose();
    super.dispose();
  }
}
