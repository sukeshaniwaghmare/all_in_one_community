import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class RealtimeChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Stream controllers for real-time updates
  final StreamController<List<ChatRoom>> _roomsController = StreamController<List<ChatRoom>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController = StreamController<List<ChatMessage>>.broadcast();
  
  // Subscriptions
  RealtimeChannel? _roomsSubscription;
  RealtimeChannel? _messagesSubscription;
  
  // Getters for streams
  Stream<List<ChatRoom>> get roomsStream => _roomsController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  // Initialize real-time subscriptions
  Future<void> initialize() async {
    await _subscribeToRooms();
    await _subscribeToMessages();
  }

  // Subscribe to room changes
  Future<void> _subscribeToRooms() async {
    _roomsSubscription = _supabase
        .channel('chat_rooms')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_rooms',
          callback: (payload) => _handleRoomChange(payload),
        )
        .subscribe();
  }

  // Subscribe to message changes
  Future<void> _subscribeToMessages() async {
    _messagesSubscription = _supabase
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) => _handleMessageChange(payload),
        )
        .subscribe();
  }

  // Handle room changes
  void _handleRoomChange(PostgresChangePayload payload) async {
    await loadUserRooms();
  }

  // Handle message changes
  void _handleMessageChange(PostgresChangePayload payload) async {
    if (payload.eventType == PostgresChangeEvent.insert) {
      final messageData = payload.newRecord;
      final message = ChatMessage.fromJson(messageData);
      
      // Add to current messages if it's for the current room
      final currentMessages = await getCurrentMessages();
      if (currentMessages.any((m) => m.roomId == message.roomId)) {
        currentMessages.add(message);
        _messagesController.add(currentMessages);
      }
    }
  }

  // Load user's chat rooms
  Future<void> loadUserRooms() async {
    try {
      final response = await _supabase
          .from('chat_rooms')
          .select('''
            *,
            chat_room_members!inner(user_id),
            messages(content, created_at)
          ''')
          .eq('chat_room_members.user_id', _supabase.auth.currentUser!.id)
          .order('updated_at', ascending: false);

      final rooms = (response as List)
          .map((room) => ChatRoom.fromJson(room))
          .toList();

      _roomsController.add(rooms);
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  // Create new chat room
  Future<ChatRoom?> createRoom({
    required String name,
    String? description,
    bool isGroup = false,
    List<String>? memberIds,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Create room
      final roomResponse = await _supabase
          .from('chat_rooms')
          .insert({
            'name': name,
            'description': description,
            'is_group': isGroup,
            'created_by': userId,
          })
          .select()
          .single();

      final roomId = roomResponse['id'];

      // Add creator as admin member
      await _supabase.from('chat_room_members').insert({
        'room_id': roomId,
        'user_id': userId,
        'is_admin': true,
      });

      // Add other members if provided
      if (memberIds != null && memberIds.isNotEmpty) {
        final memberInserts = memberIds.map((memberId) => {
          'room_id': roomId,
          'user_id': memberId,
          'is_admin': false,
        }).toList();

        await _supabase.from('chat_room_members').insert(memberInserts);
      }

      return ChatRoom.fromJson(roomResponse);
    } catch (e) {
      print('Error creating room: $e');
      return null;
    }
  }

  // Send message
  Future<bool> sendMessage({
    required String roomId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      await _supabase.from('messages').insert({
        'room_id': roomId,
        'sender_id': userId,
        'content': content,
        'message_type': messageType,
      });

      // Update room's updated_at
      await _supabase
          .from('chat_rooms')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', roomId);

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Load messages for a room
  Future<void> loadMessages(String roomId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('''
            *,
            profiles(name)
          ''')
          .eq('room_id', roomId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((message) => ChatMessage.fromJson(message))
          .toList();

      _messagesController.add(messages);
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // Get current messages
  Future<List<ChatMessage>> getCurrentMessages() async {
    return _messagesController.hasListener 
        ? await _messagesController.stream.first 
        : [];
  }

  // Join room
  Future<bool> joinRoom(String roomId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      await _supabase.from('chat_room_members').insert({
        'room_id': roomId,
        'user_id': userId,
        'is_admin': false,
      });

      return true;
    } catch (e) {
      print('Error joining room: $e');
      return false;
    }
  }

  // Leave room
  Future<bool> leaveRoom(String roomId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      await _supabase
          .from('chat_room_members')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error leaving room: $e');
      return false;
    }
  }

  // Dispose
  void dispose() {
    _roomsSubscription?.unsubscribe();
    _messagesSubscription?.unsubscribe();
    _roomsController.close();
    _messagesController.close();
  }
}

// Models
class ChatRoom {
  final String id;
  final String name;
  final String? description;
  final bool isGroup;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatRoom({
    required this.id,
    required this.name,
    this.description,
    required this.isGroup,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] as List?;
    String? lastMessage;
    DateTime? lastMessageTime;
    
    if (messages != null && messages.isNotEmpty) {
      final lastMsg = messages.last;
      lastMessage = lastMsg['content'];
      lastMessageTime = DateTime.parse(lastMsg['created_at']);
    }

    return ChatRoom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isGroup: json['is_group'] ?? false,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final bool isDeleted;
  final String? senderName;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    required this.isDeleted,
    this.senderName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      createdAt: DateTime.parse(json['created_at']),
      isDeleted: json['is_deleted'] ?? false,
      senderName: json['profiles']?['name'],
    );
  }

  bool get isMe => senderId == Supabase.instance.client.auth.currentUser?.id;
}