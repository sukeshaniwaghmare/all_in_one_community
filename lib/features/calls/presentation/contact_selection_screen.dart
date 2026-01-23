import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ContactSelectionScreen extends StatelessWidget {
  const ContactSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'name': 'Mom', 'phone': '+1 234 567 8901', 'avatar': 'M', 'color': Colors.pink},
      {'name': 'Dad', 'phone': '+1 234 567 8902', 'avatar': 'D', 'color': Colors.blue},
      {'name': 'Best Friend', 'phone': '+1 234 567 8903', 'avatar': 'B', 'color': Colors.green},
      {'name': 'Office', 'phone': '+1 234 567 8904', 'avatar': 'O', 'color': Colors.orange},
      {'name': 'Brother', 'phone': '+1 234 567 8905', 'avatar': 'B', 'color': Colors.purple},
      {'name': 'Sister', 'phone': '+1 234 567 8906', 'avatar': 'S', 'color': Colors.red},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: contact['color'] as Color,
              child: Text(
                contact['avatar'] as String,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(contact['name'] as String),
            subtitle: Text(contact['phone'] as String),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${contact['name']}')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.blue),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Video calling ${contact['name']}')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}