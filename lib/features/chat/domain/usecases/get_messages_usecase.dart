import '../../data/models/chat_model.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<ChatMessage>> call(String chatId) async {
    return await repository.getMessages(chatId);
  }
}