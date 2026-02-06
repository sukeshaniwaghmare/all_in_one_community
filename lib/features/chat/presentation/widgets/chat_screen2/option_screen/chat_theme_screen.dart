import 'package:flutter/material.dart';

class ChatThemeScreen extends StatelessWidget {
  const ChatThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themes = [
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'Pink', 'color': Colors.pink},
      {'name': 'Teal', 'color': Colors.teal},
      {'name': 'Indigo', 'color': Colors.indigo},
      {'name': 'Brown', 'color': Colors.brown},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat theme'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final theme = themes[index];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, theme);
            },
            child: Container(
              decoration: BoxDecoration(
                color: theme['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
