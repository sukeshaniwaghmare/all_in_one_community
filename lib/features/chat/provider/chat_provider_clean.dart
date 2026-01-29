import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentChatId;
  
  List<Chat> get chats => _chats;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentChatId => _currentChatId;
  
  ChatProvider() {
    _loadDemoChats();
  }
  
  void _loadDemoChats() {
    _chats = [
      Chat(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hey, how are you?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      Chat(
        id: '2',
        name: 'Jane Smith',
        lastMessage: 'See you tomorrow!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
      Chat(
        id: '3',
        name: 'Mike Johnson',
        lastMessage: 'Thanks for the help',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 1,
      ),
    ];
    notifyListeners();
  }
  
  void loadMessages(String chatId) {
    _currentChatId = chatId;
    final chat = _chats.firstWhere((c) => c.id == chatId);
    
    _messages = [
      ChatMessage(
        id: '1',
        text: 'Hello!',
        senderId: chatId,
        senderName: chat.name,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        text: 'Hi there! How are you?',
        senderId: 'me',
        senderName: 'Me',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isMe: true,
      ),
      ChatMessage(
        id: '3',
        text: chat.lastMessage,
        senderId: chatId,
        senderName: chat.name,
        timestamp: chat.lastMessageTime,
        isMe: false,
      ),
    ];
    notifyListeners();
  }
  
  void sendMessage(String text) {
    if (_currentChatId == null || text.trim().isEmpty) return;
    
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      senderId: 'me',
      senderName: 'Me',
      timestamp: DateTime.now(),
      isMe: true,
    );
    
    _messages.add(message);
    
    // Update chat's last message
    final chatIndex = _chats.indexWhere((c) => c.id == _currentChatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = Chat(
        id: _chats[chatIndex].id,
        name: _chats[chatIndex].name,
        lastMessage: text.trim(),
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        profileImage: _chats[chatIndex].profileImage,
      );
    }
    
    notifyListeners();
  }
}