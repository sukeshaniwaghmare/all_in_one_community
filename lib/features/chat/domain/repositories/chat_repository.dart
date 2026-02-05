import '../../data/models/chat_model.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages(String chatId);
  Future<List<Chat>> getChats();
  Future<void> sendMessage(ChatMessage message);
}