import 'package:flutter/material.dart';
import 'dart:async';
import '../domain/usecases/archive_chat_usecase.dart';
import '../domain/usecases/unarchive_chat_usecase.dart';
import '../domain/usecases/get_archived_chats_usecase.dart';
import '../data/models/archived_chat_model.dart';
import '../../../core/services/auth_service.dart';

class ArchivedProvider extends ChangeNotifier {
  final ArchiveChatUseCase archiveChatUseCase;
  final UnarchiveChatUseCase unarchiveChatUseCase;
  final GetArchivedChatsUseCase getArchivedChatsUseCase;
  final AuthService _authService = AuthService();

  List<String> _archivedChatIds = [];
  bool _isLoading = false;
  StreamSubscription? _archivedSubscription;

  ArchivedProvider({
    required this.archiveChatUseCase,
    required this.unarchiveChatUseCase,
    required this.getArchivedChatsUseCase,
  });

  List<String> get archivedChatIds => _archivedChatIds;
  bool get isLoading => _isLoading;

  bool isArchived(String chatId) => _archivedChatIds.contains(chatId);

  Future<void> loadArchivedChats() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final archived = await getArchivedChatsUseCase(userId);
      _archivedChatIds = archived.map((a) => a.chatId).toList();
    } catch (e) {
      _archivedChatIds = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveChat(String chatId) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await archiveChatUseCase(chatId, userId);
      _archivedChatIds.add(chatId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await unarchiveChatUseCase(chatId, userId);
      _archivedChatIds.remove(chatId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _archivedSubscription?.cancel();
    super.dispose();
  }
}
