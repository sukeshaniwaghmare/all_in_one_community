import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatItem> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;

  List<ChatItem> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void loadChats() {
    print('🔵 loadChats called, current chats count: ${_chats.length}');
    
    _isLoading = true;
    notifyListeners();
    
    // Only load default chats if empty
    if (_chats.isEmpty) {
      _chats = [
        ChatItem(
          id: '1',
          name: 'Society Management',
          lastMessage: 'Monthly maintenance due tomorrow',
          time: '10:30 AM',
          unreadCount: 3,
          isGroup: true,
          lastMessageSender: 'Admin',
          memberCount: 156,
        ),
        ChatItem(
          id: '2',
          name: 'John Doe',
          lastMessage: 'Thanks for the help!',
          time: '9:45 AM',
          unreadCount: 1,
          isOnline: true,
        ),
      ];
    }
    
    _isLoading = false;
    print('🔵 loadChats completed, chats count: ${_chats.length}');
    notifyListeners();
  }

  void loadMessages(String chatId) {
    Future.microtask(() {
      _messages = [
        Message(
          id: '1',
          text: 'Hello everyone! 👋',
          isMe: false,
          time: '10:30 AM',
          sender: 'John',
        ),
        Message(
          id: '2',
          text: 'Hi John! How are you doing?',
          isMe: true,
          time: '10:32 AM',
        ),
      ];
      notifyListeners();
    });
  }

  void sendMessage(String text) {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      time: timeString,
    );
    _messages.add(message);
    notifyListeners();
  }

  void markAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void createGroup(String groupName, List<String> memberNames) {
    print('🟢 createGroup called: $groupName with ${memberNames.length} members');
    print('🟢 Before insert - chats count: ${_chats.length}');
    
    final newGroup = ChatItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: groupName,
      lastMessage: 'Group created',
      time: 'Just now',
      unreadCount: 0,
      isGroup: true,
      memberCount: memberNames.length + 1,
    );
    _chats.insert(0, newGroup);
    
    print('🟢 After insert - chats count: ${_chats.length}');
    print('🟢 First chat name: ${_chats.first.name}');
    notifyListeners();
    print('🟢 notifyListeners called');
  }

  void deleteGroup(String groupName) {
    _chats.removeWhere((chat) => chat.name == groupName && chat.isGroup);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
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