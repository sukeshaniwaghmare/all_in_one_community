import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../core/services/realtime_chat_service.dart';
import 'dart:async';

class ChatProvider extends ChangeNotifier {
  List<ChatItem> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  
  final RealtimeChatService _chatService = RealtimeChatService();
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _messagesSubscription;
  String? _currentRoomId;

  List<ChatItem> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _initializeRealtime();
    _loadSavedChats();
  }

  Future<void> _initializeRealtime() async {
    await _chatService.initialize();
    
    // Listen to room updates
    _roomsSubscription = _chatService.roomsStream.listen((rooms) {
      _chats = rooms.map((room) => ChatItem(
        id: room.id,
        name: room.name,
        lastMessage: room.lastMessage ?? 'No messages yet',
        time: _formatTime(room.lastMessageTime ?? room.updatedAt),
        isGroup: room.isGroup,
      )).toList();
      notifyListeners();
    });
    
    // Listen to message updates
    _messagesSubscription = _chatService.messagesStream.listen((messages) {
      _messages = messages.map((msg) => Message(
        id: msg.id,
        text: msg.content,
        isMe: msg.isMe,
        time: _formatTime(msg.createdAt),
        sender: msg.senderName,
      )).toList();
      notifyListeners();
    });
    
    // Load initial data
    await _chatService.loadUserRooms();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void loadChats() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _chatService.loadUserRooms();
    } catch (e) {
      print('Error loading chats: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSavedChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedChats = prefs.getString('saved_chats');
      if (savedChats != null) {
        final List<dynamic> chatList = jsonDecode(savedChats);
        _chats = chatList.map((c) => ChatItem(
          id: c['id'],
          name: c['name'],
          lastMessage: c['lastMessage'],
          time: c['time'],
          unreadCount: c['unreadCount'] ?? 0,
          isGroup: c['isGroup'] ?? false,
          isOnline: c['isOnline'] ?? false,
          memberCount: c['memberCount'] ?? 0,
          phoneNumber: c['phoneNumber'],
        )).toList();
      }
    } catch (e) {
      // Error loading saved chats
    }
  }

  Future<void> _saveChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatList = _chats.map((c) => {
        'id': c.id,
        'name': c.name,
        'lastMessage': c.lastMessage,
        'time': c.time,
        'unreadCount': c.unreadCount,
        'isGroup': c.isGroup,
        'isOnline': c.isOnline,
        'memberCount': c.memberCount,
        'phoneNumber': c.phoneNumber,
      }).toList();
      await prefs.setString('saved_chats', jsonEncode(chatList));
    } catch (e) {
      // Error saving chats
    }
  }

  void loadMessages(String chatId) async {
    _currentRoomId = chatId;
    _isLoading = true;
    notifyListeners();
    
    try {
      await _chatService.loadMessages(chatId);
    } catch (e) {
      print('Error loading messages: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSavedMessages(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMessages = prefs.getString('messages_$chatId');
      if (savedMessages != null) {
        final List<dynamic> messageList = jsonDecode(savedMessages);
        _messages = messageList.map((m) => Message(
          id: m['id'],
          text: m['text'],
          isMe: m['isMe'],
          time: m['time'],
          sender: m['sender'],
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      // Error loading messages
    }
  }

  Future<void> sendMessage(String text, [String? chatId]) async {
    if (chatId == null) return;
    
    try {
      await _chatService.sendMessage(
        roomId: chatId,
        content: text,
      );
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _saveMessages(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messageList = _messages.map((m) => {
        'id': m.id,
        'text': m.text,
        'isMe': m.isMe,
        'time': m.time,
        'sender': m.sender,
      }).toList();
      await prefs.setString('messages_$chatId', jsonEncode(messageList));
    } catch (e) {
      // Error saving messages
    }
  }

  void markAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  Future<void> createGroup(String groupName, List<String> memberIds) async {
    try {
      await _chatService.createRoom(
        name: groupName,
        isGroup: true,
        memberIds: memberIds,
      );
    } catch (e) {
      print('Error creating group: $e');
    }
  }
  
  Future<void> createDirectChat(String userId, String userName) async {
    try {
      await _chatService.createRoom(
        name: userName,
        isGroup: false,
        memberIds: [userId],
      );
    } catch (e) {
      print('Error creating direct chat: $e');
    }
  }

  void deleteGroup(String groupName) {
    _chats.removeWhere((chat) => chat.name == groupName && chat.isGroup);
    notifyListeners();
  }

  void addNewChat(ChatItem newChat) {
    // Check if chat already exists
    final existingIndex = _chats.indexWhere((chat) => chat.id == newChat.id);
    
    if (existingIndex == -1) {
      // Add new chat to the beginning of the list
      _chats.insert(0, newChat);
    } else {
      // Update existing chat
      _chats[existingIndex] = newChat;
    }
    
    // Save chats to persistence
    _saveChats();
    
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _roomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _chatService.dispose();
    super.dispose();
  }

  void updateContactName(String oldName, String newName) async {
    final index = _chats.indexWhere((chat) => chat.name == oldName);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(name: newName);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      Map<String, String> contactNames = {};
      final saved = prefs.getString('contact_names');
      if (saved != null) {
        contactNames = Map<String, String>.from(jsonDecode(saved));
      }
      contactNames[_chats[index].id] = newName;
      await prefs.setString('contact_names', jsonEncode(contactNames));
      
      notifyListeners();
    }
  }
}

class ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isGroup;
  final bool isOnline;
  final String? lastMessageSender;
  final int memberCount;
  final String? phoneNumber;

  ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isGroup = false,
    this.isOnline = false,
    this.lastMessageSender,
    this.memberCount = 0,
    this.phoneNumber,
  });

  ChatItem copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? time,
    int? unreadCount,
    bool? isGroup,
    bool? isOnline,
    String? lastMessageSender,
    int? memberCount,
    String? phoneNumber,
  }) {
    return ChatItem(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      isOnline: isOnline ?? this.isOnline,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      memberCount: memberCount ?? this.memberCount,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class Message {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final String? sender;
  final bool isRead;

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.sender,
    this.isRead = true,
  });
}