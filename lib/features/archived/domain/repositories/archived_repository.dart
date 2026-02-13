import '../../data/models/archived_chat_model.dart';

abstract class ArchivedRepository {
  Future<List<ArchivedChat>> getArchivedChats(String userId);
  Future<void> archiveChat(String chatId, String userId);
  Future<void> unarchiveChat(String chatId, String userId);
  Stream<List<ArchivedChat>> watchArchivedChats(String userId);
}
