import '../datasources/archived_datasource.dart';
import '../models/archived_chat_model.dart';
import '../../domain/repositories/archived_repository.dart';

class ArchivedRepositoryImpl implements ArchivedRepository {
  final ArchivedDataSource dataSource;

  ArchivedRepositoryImpl(this.dataSource);

  @override
  Future<List<ArchivedChat>> getArchivedChats(String userId) async {
    return await dataSource.getArchivedChats(userId);
  }

  @override
  Future<void> archiveChat(String chatId, String userId) async {
    await dataSource.archiveChat(chatId, userId);
  }

  @override
  Future<void> unarchiveChat(String chatId, String userId) async {
    await dataSource.unarchiveChat(chatId, userId);
  }

  @override
  Stream<List<ArchivedChat>> watchArchivedChats(String userId) {
    return dataSource.watchArchivedChats(userId);
  }
}
