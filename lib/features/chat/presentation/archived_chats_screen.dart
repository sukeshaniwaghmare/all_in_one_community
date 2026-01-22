import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final archivedChats = [
      {
        'name': 'Old Group',
        'preview': 'Last message from archived chat',
        'time': '2 days ago',
        'initials': 'OG',
        'color': Colors.orange,
      },
      {
        'name': 'Work Team',
        'preview': 'Meeting tomorrow at 10 AM',
        'time': '1 week ago',
        'initials': 'WT',
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Archived Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value)),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Unarchive all', child: Text('Unarchive all')),
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Info section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These chats stay archived when new messages are received. Tap to change.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Archived chats list
          Expanded(
            child: ListView.builder(
              itemCount: archivedChats.length,
              itemBuilder: (context, index) {
                final chat = archivedChats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: chat['color'] as Color,
                    child: Text(
                      chat['initials'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    chat['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    chat['preview'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    chat['time'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${chat['name']}')),
                    );
                  },
                  onLongPress: () {
                    _showChatOptions(context, chat['name'] as String);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context, String chatName) {
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
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$chatName unarchived')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete chat'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$chatName deleted')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}