import '../repositories/archived_repository.dart';

class UnarchiveChatUseCase {
  final ArchivedRepository repository;

  UnarchiveChatUseCase(this.repository);

  Future<void> call(String chatId, String userId) async {
    await repository.unarchiveChat(chatId, userId);
  }
}
