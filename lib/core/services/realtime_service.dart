import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'auth_service.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _chatsChannel;

  // Message listeners
  final StreamController<Map<String, dynamic>> _messageStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  // Chat list listeners  
  final StreamController<Map<String, dynamic>> _chatStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get chatStream => _chatStreamController.stream;

  void subscribeToMessages(String chatId) {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) return;
    
    print('📡 Subscribing to messages for chat: $chatId');
    
    _messagesChannel?.unsubscribe();
    
    _messagesChannel = _supabase
        .channel('messages_$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final data = payload.newRecord;
            final senderId = data['sender_id'];
            final receiverId = data['receiver_id'];
            
            print('📨 New message received:');
            print('   Sender: $senderId');
            print('   Receiver: $receiverId');
            print('   Current User: $currentUserId');
            print('   Chat ID: $chatId');
            
            // Only process messages between current user and chat partner
            if ((senderId == currentUserId && receiverId == chatId) ||
                (senderId == chatId && receiverId == currentUserId)) {
              print('   ✅ Message is for this chat - adding to stream');
              _messageStreamController.add(data);
            } else {
              print('   ❌ Message not for this chat - ignoring');
            }
          },
        )
        .subscribe();
  }

  void subscribeToChats(String userId) {
    if (!_authService.isAuthenticated) return;
    
    print('📡 Subscribing to chat updates for user: $userId');
    
    _chatsChannel?.unsubscribe();
    
    _chatsChannel = _supabase
        .channel('chats_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public', 
          table: 'messages',
          callback: (payload) {
            final data = payload.newRecord;
            print('💬 Chat update received:');
            print('   Sender: ${data['sender_id']}');
            print('   Receiver: ${data['receiver_id']}');
            print('   Message: ${data['message']}');
            
            // Only process if current user is sender or receiver
            if (data['sender_id'] == userId || data['receiver_id'] == userId) {
              print('   ✅ Adding to chat stream');
              _chatStreamController.add(data);
            } else {
              print('   ❌ Not for this user - ignoring');
            }
          },
        )
        .subscribe();
  }

  void unsubscribeFromMessages() {
    _messagesChannel?.unsubscribe();
    _messagesChannel = null;
  }

  void unsubscribeFromChats() {
    _chatsChannel?.unsubscribe();
    _chatsChannel = null;
  }

  void dispose() {
    unsubscribeFromMessages();
    unsubscribeFromChats();
    _messageStreamController.close();
    _chatStreamController.close();
  }
}