import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/chat_model.dart';
import '../../../provider/chat_provider.dart';
import 'video_player_screen.dart';
import 'image_gallery_screen.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Map<String, dynamic>? theme;

  const MessageBubble({super.key, required this.message, this.theme});

  @override
  Widget build(BuildContext context) {
    final bgColor = message.isMe 
        ? (theme?['color'] ?? const Color(0xFFD1C4E9))
        : const Color(0xFFEEEEEE);
    
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isMe)
                Text(
                  message.senderName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6750A4)),
                ),
              _buildMessageContent(context),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.reply, color: Colors.grey[700]),
              title: Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reply feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.grey[700]),
              title: Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message copied')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.star_border, color: Colors.grey[700]),
              title: Text('Star'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message starred')),
                );
              },
            ),
            if (message.isMe)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.forward, color: Colors.grey[700]),
              title: Text('Forward'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Forward feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete message?'),
        content: Text('This message will be deleted for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(context);
            },
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<ChatProvider>();
    
    try {
      await provider.deleteMessage(message.id);
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Message deleted'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete message'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
    final count = imagePaths.length;
    
    if (count == 1) {
      return GestureDetector(
        onTap: () => _openImageGallery(context, imagePaths, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageWidget(imagePaths[0], width: 200, height: 200),
        ),
      );
    }
    
    if (count == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _openImageGallery(context, imagePaths, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(imagePaths[0], width: 130, height: 130),
            ),
          ),
          SizedBox(width: 2),
          GestureDetector(
            onTap: () => _openImageGallery(context, imagePaths, 1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(imagePaths[1], width: 130, height: 130),
            ),
          ),
        ],
      );
    }
    
    if (count == 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _openImageGallery(context, imagePaths, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(imagePaths[0], width: 130, height: 200),
            ),
          ),
          SizedBox(width: 2),
          Column(
            children: [
              GestureDetector(
                onTap: () => _openImageGallery(context, imagePaths, 1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(imagePaths[1], width: 130, height: 99),
                ),
              ),
              SizedBox(height: 2),
              GestureDetector(
                onTap: () => _openImageGallery(context, imagePaths, 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(imagePaths[2], width: 130, height: 99),
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    // 4+ images: Show 2x2 grid with count overlay
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _openImageGallery(context, imagePaths, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(imagePaths[0], width: 130, height: 130),
              ),
            ),
            SizedBox(width: 2),
            GestureDetector(
              onTap: () => _openImageGallery(context, imagePaths, 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(imagePaths[1], width: 130, height: 130),
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _openImageGallery(context, imagePaths, 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(imagePaths[2], width: 130, height: 130),
              ),
            ),
            SizedBox(width: 2),
            GestureDetector(
              onTap: () => _openImageGallery(context, imagePaths, 3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    _buildImageWidget(imagePaths[3], width: 130, height: 130),
                    if (count > 4)
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+${count - 4}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
