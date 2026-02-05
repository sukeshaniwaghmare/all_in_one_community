import '../../data/models/chat_model.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(ChatMessage message) async {
    await repository.sendMessage(message);
  }
}