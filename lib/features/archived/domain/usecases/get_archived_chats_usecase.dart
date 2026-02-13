import '../repositories/archived_repository.dart';
import '../../data/models/archived_chat_model.dart';

class GetArchivedChatsUseCase {
  final ArchivedRepository repository;

  GetArchivedChatsUseCase(this.repository);

  Future<List<ArchivedChat>> call(String userId) async {
    return await repository.getArchivedChats(userId);
  }
}
