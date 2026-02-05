import 'package:all_in_one_community/features/chat/presentation/widgets/message_bubble.dart';
import 'package:all_in_one_community/features/notifications/services/notification_service.dart' as local_notifications;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/chat_model.dart';
import '../../../provider/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  late ChatProvider _chatProvider;
  bool _showAttachmentOptions = false;
  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load messages
      await _chatProvider.loadMessages(widget.chat.receiverUserId);

      // Mark delivered (receiver side)
      await _chatProvider
          .markMessagesAsDelivered(widget.chat.receiverUserId);

      // Mark read when chat opened
      await _chatProvider.markMessagesAsRead(widget.chat.receiverUserId);

      _chatProvider.addListener(_scrollToBottom);

      // Clear notification badge
      local_notifications.NotificationService.clearBadge();
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name), // UI only
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      message: chatProvider.messages[index],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (_showAttachmentOptions)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAttachmentOption(
                          icon: Icons.photo_camera,
                          label: 'Camera',
                          color: Colors.green,
                          onTap: () => _pickMedia(ImageSource.camera, 'image'),
                        ),
                        _buildAttachmentOption(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          color: Colors.blue,
                          onTap: () => _pickMedia(ImageSource.gallery, 'image'),
                        ),
                        _buildAttachmentOption(
                          icon: Icons.videocam,
                          label: 'Video',
                          color: Colors.red,
                          onTap: () => _pickMedia(ImageSource.gallery, 'video'),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showAttachmentOptions = !_showAttachmentOptions;
                          });
                        },
                        icon: Icon(
                          _showAttachmentOptions
                              ? Icons.close
                              : Icons.attach_file,
                          color: Colors.grey[600],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _messageController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_messageController.text
                                .trim()
                                .isNotEmpty) {
                              final message =
                                  _messageController.text.trim();

                              print(
                                  'Sending message: $message to ${widget.chat.receiverUserId}');

                              context.read<ChatProvider>().sendMessage(
                                    message,
                                    widget.chat
                                        .receiverUserId, // ✅ UUID
                                  );

                              _messageController.clear();
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_scrollToBottom);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, String type) async {
    try {
      final XFile? file;
      if (type == 'video') {
        file = await _picker.pickVideo(source: source);
      } else {
        file = await _picker.pickImage(source: source);
      }

      if (file != null) {
        setState(() {
          _showAttachmentOptions = false;
        });

        print('Selected $type: ${file.path}');
        
        // Send media message with file path
        final mediaMessage = type == 'video' 
            ? 'VIDEO:${file.path}' 
            : 'IMAGE:${file.path}';
        context.read<ChatProvider>().sendMessage(
          mediaMessage,
          widget.chat.receiverUserId,
        );
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }
}
