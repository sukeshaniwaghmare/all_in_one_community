import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../data/models/chat_model.dart';
import 'video_player_screen.dart';
import 'image_gallery_screen.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 234, 232, 232),
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
    // Handle multiple images from text (local sending)
    if (message.text.startsWith('IMAGES:')) {
      final imagePaths = message.text.substring(7).split('|||');
      return _buildImageGrid(context, imagePaths);
    }

    // Handle multiple images from mediaUrl (from database)
    if (message.type == MessageType.image && message.mediaUrl != null && message.mediaUrl!.contains('|||')) {
      final imageUrls = message.mediaUrl!.split('|||');
      return _buildImageGrid(context, imageUrls);
    }

    // Handle image messages
    if (message.type == MessageType.image && message.mediaUrl != null) {
      final mediaData = message.mediaUrl!;
      
      // Check if it's a network URL (Supabase Storage)
      if (mediaData.startsWith('http')) {
        return GestureDetector(
          onTap: () => _openImage(context, mediaData),
          child: ClipRRect(
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
        ),
        );
      }
      // Check if it's a file path (legacy support)
      else if (mediaData.startsWith('/')) {
        if (File(mediaData).existsSync()) {
          return GestureDetector(
            onTap: () => _openImage(context, mediaData),
            child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(mediaData),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
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
      style: const TextStyle(
        color: Colors.black,
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<String> imagePaths) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < imagePaths.length - 1 ? 4 : 0),
            child: GestureDetector(
              onTap: () => _openImageGallery(context, imagePaths, index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(imagePaths[index], width: 150, height: 200),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String imagePath, {double? width, double? height}) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else if (imagePath.startsWith('/') && File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }

  void _openImageGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageGalleryScreen(images: images, initialIndex: initialIndex),
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

  void _openImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.white,
                onSelected: (value) async {
                  if (value == 'save') {
                    await _saveImage(context, imagePath);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(value)),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'View contact',
                    child: Text('View contact'),
                  ),
                  const PopupMenuItem(
                    value: 'save',
                    child: Text('Save'),
                  ),
                  const PopupMenuItem(
                    value: 'Share',
                    child: Text('Share'),
                  ),
                  const PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'Show in chat',
                    child: Text('Show in chat'),
                  ),
                  const PopupMenuItem(
                    value: 'Forward',
                    child: Text('Forward'),
                  ),
                  const PopupMenuItem(
                    value: 'Rotate',
                    child: Text('Rotate'),
                  ),
                ],
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: imagePath.startsWith('http')
                  ? Image.network(imagePath)
                  : Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context, String imagePath) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving image...')),
      );

      if (imagePath.startsWith('http')) {
        final response = await http.get(Uri.parse(imagePath));
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newFile = File('${directory.path}/$fileName');
        await File(imagePath).copy(newFile.path);
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to ${newFile.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
