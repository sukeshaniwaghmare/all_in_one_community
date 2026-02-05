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
    _messagesChannel?.unsubscribe();
    
    _messagesChannel = _supabase
        .channel('messages_$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            _messageStreamController.add(payload.newRecord);
          },
        )
        .subscribe();
  }

  void subscribeToChats(String userId) {
    if (!_authService.isAuthenticated) return;
    
    _chatsChannel?.unsubscribe();
    
    _chatsChannel = _supabase
        .channel('chats_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public', 
          table: 'messages',
          callback: (payload) {
            _chatStreamController.add(payload.newRecord);
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