import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../provider/chat_provider.dart';
import '../../../../data/models/chat_model.dart';
import '../video_player_screen.dart';

class MediaScreen extends StatefulWidget {
  final String chatName;
  final String receiverUserId;

  const MediaScreen({super.key, required this.chatName, required this.receiverUserId});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {

  List<ChatMessage> _mediaMessages = [];
  List<ChatMessage> _docMessages = [];
  List<ChatMessage> _linkMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadMessages(widget.receiverUserId);
    
    setState(() {
      _mediaMessages = chatProvider.messages.where((msg) => 
        msg.type == MessageType.image || msg.type == MessageType.video
      ).toList();
      
      _docMessages = chatProvider.messages.where((msg) => 
        msg.type == MessageType.file
      ).toList();
      
      _linkMessages = chatProvider.messages.where((msg) => 
        msg.type == MessageType.text && _containsUrl(msg.text)
      ).toList();
      
      _isLoading = false;
    });
  }

  bool _containsUrl(String text) {
    final urlPattern = RegExp(
      r'(https?://[^\s]+)',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }

  String _extractUrl(String text) {
    final urlPattern = RegExp(
      r'(https?://[^\s]+)',
      caseSensitive: false,
    );
    final match = urlPattern.firstMatch(text);
    return match?.group(0) ?? text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.chatName} Media'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Media'),
                Tab(text: 'Docs'),
                Tab(text: 'Links'),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildMediaTab(),
                        _buildDocsTab(),
                        _buildLinksTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTab() {
    if (_mediaMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No media shared yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _mediaMessages.length,
      itemBuilder: (context, index) {
        final message = _mediaMessages[index];
        final isVideo = message.type == MessageType.video;
        
        return GestureDetector(
          onTap: () {
            if (isVideo) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(videoPath: message.mediaUrl!),
                ),
              );
            } else {
              _openImage(context, message.mediaUrl!);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isVideo)
                Container(
                  color: Colors.black87,
                  child: const Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
                )
              else if (message.mediaUrl!.startsWith('http'))
                Image.network(
                  message.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              else
                Image.file(
                  File(message.mediaUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
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
        // Download from network
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
        // Copy local file
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

  Widget _buildDocsTab() {
    if (_docMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No documents shared yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _docMessages.length,
      itemBuilder: (context, index) {
        final message = _docMessages[index];
        final fileName = message.mediaUrl?.split('/').last ?? 'Document';
        final date = _formatDate(message.timestamp);
        
        return ListTile(
          leading: const Icon(Icons.description, color: AppTheme.primaryColor),
          title: Text(fileName),
          subtitle: Text(date),
          trailing: const Icon(Icons.download),
          onTap: () {
            // Handle document open
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLinksTab() {
    if (_linkMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No links shared yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _linkMessages.length,
      itemBuilder: (context, index) {
        final message = _linkMessages[index];
        final url = _extractUrl(message.text);
        final date = _formatDate(message.timestamp);
        
        return ListTile(
          leading: const Icon(Icons.link, color: AppTheme.primaryColor),
          title: Text(
            url,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(date),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            // Handle link open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening: $url')),
            );
          },
        );
      },
    );
  }
}