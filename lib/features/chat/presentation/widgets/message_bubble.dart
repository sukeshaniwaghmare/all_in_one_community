import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../../data/models/chat_model.dart';
import 'video_player_screen.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

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
    // Handle image messages
    if (message.type == MessageType.image && message.mediaUrl != null) {
      final mediaData = message.mediaUrl!;
      
      // Check if it's a network URL (Supabase Storage)
      if (mediaData.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            mediaData,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Failed to load image', 
                         style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        );
      }
      // Check if it's a file path (legacy support)
      else if (mediaData.startsWith('/')) {
        if (File(mediaData).existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(mediaData),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          );
        } else {
          // File doesn't exist - show placeholder
          return Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Image not available', 
                     style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          );
        }
      } else {
        // It's base64 data
        try {
          final imageBytes = base64Decode(mediaData);
          
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              imageBytes,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          );
        } catch (e) {
          // Base64 decode failed
        }
      }
      
      // Fallback placeholder
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
            Text('📷 Image', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // Handle video messages
    if (message.type == MessageType.video && message.mediaUrl != null) {
      final mediaData = message.mediaUrl!;
      
      return GestureDetector(
        onTap: () => _openVideo(context, mediaData),
        child: Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '🎥 Video',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Legacy support for IMAGE:/VIDEO: in text
    if (message.text.startsWith('IMAGE:')) {
      final imagePath = message.text.substring(6);
      if (File(imagePath).existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(imagePath), width: 200, height: 200, fit: BoxFit.cover),
        );
      }
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
