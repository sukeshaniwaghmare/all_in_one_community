import 'package:flutter/material.dart';

class ChatThemeScreen extends StatelessWidget {
  const ChatThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        itemCount: 9,
        itemBuilder: (context, index) {
          final colors = [
            Colors.blue, Colors.green, Colors.red,
            Colors.purple, Colors.orange, Colors.pink,
            Colors.teal, Colors.indigo, Colors.brown,
          ];
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
