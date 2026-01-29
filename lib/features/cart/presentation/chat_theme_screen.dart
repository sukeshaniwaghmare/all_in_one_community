import 'package:flutter/material.dart';

class ChatThemeScreen extends StatefulWidget {
  final Map<String, dynamic>? currentTheme;

  const ChatThemeScreen({super.key, this.currentTheme});

  @override
  State<ChatThemeScreen> createState() => _ChatThemeScreenState();
}

class _ChatThemeScreenState extends State<ChatThemeScreen> {
  final List<Map<String, dynamic>> themes = [
    {'name': 'Default', 'color': Colors.teal, 'background': Colors.grey[100]},
    {'name': 'Blue', 'color': Colors.blue, 'background': Colors.blue[50]},
    {'name': 'Pink', 'color': Colors.pink, 'background': Colors.pink[50]},
    {'name': 'Purple', 'color': Colors.purple, 'background': Colors.purple[50]},
    {'name': 'Green', 'color': Colors.green, 'background': Colors.green[50]},
    {'name': 'Orange', 'color': Colors.orange, 'background': Colors.orange[50]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Theme'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final theme = themes[index];
          final isSelected = widget.currentTheme?['name'] == theme['name'];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme['color'],
                child: const Icon(Icons.palette, color: Colors.white),
              ),
              title: Text(theme['name']),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () {
                Navigator.pop(context, theme);
              },
            ),
          );
        },
      ),
    );
  }
}