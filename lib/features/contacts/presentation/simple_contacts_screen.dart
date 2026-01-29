import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/provider/chat_provider.dart';
import '../../chat/presentation/chat_screen.dart';

class SimpleContactsScreen extends StatelessWidget {
  const SimpleContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'name': 'John Doe', 'phone': '+91 98765 43210'},
      {'name': 'Jane Smith', 'phone': '+91 98765 43211'},
      {'name': 'Mike Johnson', 'phone': '+91 98765 43212'},
      {'name': 'Sarah Wilson', 'phone': '+91 98765 43213'},
      {'name': 'David Brown', 'phone': '+91 98765 43214'},
      {'name': 'Lisa Davis', 'phone': '+91 98765 43215'},
      {'name': 'Tom Miller', 'phone': '+91 98765 43216'},
      {'name': 'Emma Garcia', 'phone': '+91 98765 43217'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Contacts', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${contacts.length} contacts',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getContactColor(contact['name']!),
                    child: Text(
                      contact['name']![0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    contact['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    contact['phone']!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: const Icon(Icons.chat, color: AppTheme.primaryColor),
                  onTap: () => _startChat(context, contact),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getContactColor(String name) {
    const colors = [
      AppTheme.primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  void _startChat(BuildContext context, Map<String, String> contact) {
    final chatItem = ChatItem(
      id: contact['name']!.toLowerCase().replaceAll(' ', '_'),
      name: contact['name']!,
      lastMessage: 'Tap to start conversation',
      time: 'now',
      phoneNumber: contact['phone']!,
    );

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: chatItem),
      ),
    );
  }
}