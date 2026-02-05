import '../datasources/chat_datasource.dart';
import '../models/chat_model.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<List<ChatMessage>> getMessages(String chatId) async {
    return await dataSource.getMessages(chatId);
  }

  @override
  Future<List<Chat>> getChats() async {
    return await dataSource.getChats();
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    await dataSource.sendMessage(message);
  }
}