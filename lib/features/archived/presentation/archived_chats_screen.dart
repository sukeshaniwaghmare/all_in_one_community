import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/provider/chat_provider.dart';
import '../../chat/presentation/widgets/chat_screen2/chat_screen.dart';
import '../provider/archived_provider.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final archivedProvider = Provider.of<ArchivedProvider>(context);
    final archivedChats = chatProvider.chats.where((chat) => archivedProvider.isArchived(chat.id)).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Archived Chats', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: archivedChats.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No archived chats', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: archivedChats.length,
              itemBuilder: (context, index) {
                final chat = archivedChats[index];
                return ListTile(
                  leading: chat.profileImage != null && chat.profileImage!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(chat.profileImage!),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?'),
                        ),
                  title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: chat as dynamic))),
                  onLongPress: () => _showChatOptions(context, chat.id, chat.name),
                );
              },
            ),
    );
  }

  void _showChatOptions(BuildContext context, String chatId, String chatName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.unarchive),
              title: const Text('Unarchive chat'),
              onTap: () async {
                Navigator.pop(context);
                await Provider.of<ArchivedProvider>(context, listen: false).unarchiveChat(chatId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$chatName unarchived')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}