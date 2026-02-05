import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/chat_model.dart';
import 'video_player_screen.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Text(
                message.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            _buildMessageContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    print('=== MESSAGE DEBUG ===');
    print('Message text: ${message.text}');
    print('Message isMe: ${message.isMe}');
    print('Sender ID: ${message.senderId}');
    print('Receiver ID: ${message.receiverId}');
    print('====================');
    
    if (message.text.startsWith('IMAGE:')) {
      final imagePath = message.text.substring(6);
      print('IMAGE detected: $imagePath');
      print('File exists: ${File(imagePath).existsSync()}');

      // ✅ LOCAL IMAGE (sender side)
      if (File(imagePath).existsSync()) {
        print('Showing actual image');
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagePath),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      }

      // ❌ PLACEHOLDER (receiver side)
      print('Showing image placeholder');
      return Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 50, color: Colors.blue),
            const SizedBox(height: 8),
            Text('📷 Photo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Image received', style: TextStyle(fontSize: 12, color: Colors.blue[700])),
          ],
        ),
      );
    }

    if (message.text.startsWith('VIDEO:')) {
      final videoPath = message.text.substring(6);
      return GestureDetector(
        onTap: () => _openVideo(context, videoPath),
        child: const Icon(Icons.play_circle, size: 40),
      );
    }

    return Text(
      message.text,
      style: TextStyle(
        color: message.isMe ? Colors.white : Colors.black,
      ),
    );
  }

  void _openVideo(BuildContext context, String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoPath: videoPath),
      ),
    );
  }
}
