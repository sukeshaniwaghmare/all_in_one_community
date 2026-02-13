import '../repositories/archived_repository.dart';

class ArchiveChatUseCase {
  final ArchivedRepository repository;

  ArchiveChatUseCase(this.repository);

  Future<void> call(String chatId, String userId) async {
    await repository.archiveChat(chatId, userId);
  }
}
