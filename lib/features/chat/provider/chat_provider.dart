import 'package:flutter/material.dart';
import '../data/models/chat_model.dart';
import '../domain/usecases/get_chats_usecase.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/services/auth_service.dart';
import '../data/datasources/chat_datasource.dart';
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
      debugPrint('Error loading chats: $e');
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
        print('Invalid UUID format: $receiverUserId. Skipping database call.');
        _messages = [];
        return;
      }

      if (_currentReceiverUserId != receiverUserId) {
        _messages = [];
        _currentReceiverUserId = receiverUserId;
      }

      final newMessages = await getMessagesUseCase(receiverUserId);
      _messages = newMessages;
      print('Loaded ${_messages.length} messages for receiver: $receiverUserId');

      _subscribeToMessages(receiverUserId);
    } catch (e) {
      debugPrint('Error loading messages: $e');
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
      debugPrint('No authenticated user');
      return;
    }

    // Check if receiverUserId is a valid UUID format
    if (!_isValidUUID(receiverUserId)) {
      print('Invalid UUID format: $receiverUserId. Skipping database call.');
      return;
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: currentUserId,     // ✅ UUID
      receiverId: receiverUserId,  // ✅ UUID
      senderName: 'Me',
      timestamp: DateTime.now(),
      isMe: true,
    );

    // optimistic UI
    _messages.add(message);
    
    // Update chat list
    final chatIndex = _chats.indexWhere((chat) => chat.receiverUserId == receiverUserId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: text,
        lastMessageTime: DateTime.now(),
      );
      _sortChatsByRecent();
    }
    
    notifyListeners();

    try {
      await sendMessageUseCase(message);
      print('Message sent successfully');
    } catch (e) {
      debugPrint('Error sending message: $e');
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
    final newGroup = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: groupName,
      lastMessage: 'Group created',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isGroup: true,
      receiverUserId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    
    _chats.insert(0, newGroup);
    notifyListeners();
  }

  // -------------------- MESSAGE STATUS --------------------

  Future<void> markMessagesAsDelivered(String receiverUserId) async {
    try {
      await _chatDataSource.markMessagesAsDelivered(receiverUserId);
    } catch (e) {
      debugPrint('Error marking messages as delivered: $e');
    }
  }

  Future<void> markMessagesAsRead(String receiverUserId) async {
    try {
      await _chatDataSource.markMessagesAsRead(receiverUserId);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
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

  void _handleNewMessage(Map<String, dynamic> data) {
    final currentUserId = _authService.currentUserId;
    print('Handling new realtime message: $data');

    final message = ChatMessage(
      id: data['id'].toString(),
      text: data['message'] ?? '',
      senderId: data['sender_id'],
      receiverId: data['receiver_id'],
      senderName: 'User',
      timestamp: DateTime.parse(data['created_at']),
      type: _getMessageTypeFromString(data['message_type']),
      mediaUrl: data['media_url'], // This will now contain the Supabase Storage URL
      isMe: data['sender_id'] == currentUserId,
    );

    // avoid duplicates
    if (_messages.any((m) => m.id == message.id)) {
      print('Duplicate message ignored: ${message.id}');
      return;
    }

    print('Adding new message to list: ${message.text}');
    _messages.add(message);
    notifyListeners();
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
