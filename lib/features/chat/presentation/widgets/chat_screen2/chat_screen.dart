import 'package:all_in_one_community/features/chat/presentation/widgets/chat_screen2/chat_screen.dart';
import 'package:all_in_one_community/features/chat/presentation/widgets/chat_screen2/message_bubble.dart';
import 'package:all_in_one_community/features/notifications/services/notification_service.dart' as local_notifications;
import 'package:all_in_one_community/features/notifications/services/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import '../../../data/models/chat_model.dart';
import '../../../provider/chat_provider.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../core/theme/app_theme.dart';
import 'option_screen/media_screen.dart';
import 'option_screen/disappearing_messages_screen.dart';
import 'option_screen/chat_theme_screen.dart';
import '../chats_creen3/info_screen.dart';
import 'image_picker_screen.dart';

// ==================== UTILITY EXTENSION ====================
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// ==================== CHAT SCREEN WIDGET ====================
class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatScreen> {
  // ==================== STATE VARIABLES ====================
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  late ChatProvider _chatProvider;
  bool _showAttachmentOptions = false;
  bool _isSearching = false;
  Timer? _refreshTimer;
  Map<String, dynamic>? _selectedTheme;
  
  // ==================== LIFECYCLE: INIT ====================
  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();

    // LOGIC: Set current chat to prevent notifications
    FCMService.setCurrentChat(widget.chat.receiverUserId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // LOGIC: Load messages from database
      await _chatProvider.loadMessages(widget.chat.receiverUserId);

      // LOGIC: Mark messages as delivered
      await _chatProvider.markMessagesAsDelivered(widget.chat.receiverUserId);

      // LOGIC: Mark messages as read
      await _chatProvider.markMessagesAsRead(widget.chat.receiverUserId);

      // LOGIC: Listen for new messages and auto-scroll
      _chatProvider.addListener(_scrollToBottom);

      // LOGIC: Clear notification badge
      local_notifications.NotificationService.clearBadge();
    });
  }

  // ==================== UI: BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // UI: Resize when keyboard opens
      // ==================== UI: APP BAR ====================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        // UI: Back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        // UI: Title (Search bar or Chat name)
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // LOGIC: Search messages (to be implemented)
                },
              )
            : GestureDetector(
                onTap: () {
                  // LOGIC: Navigate to info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InfoScreen(
                        name: widget.chat.name,
                        memberCount: 0,
                        isGroup: widget.chat.isGroup,
                      ),
                    ),
                  );
                },
                // UI: Chat name and avatar
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFDADADA),
                      backgroundImage: widget.chat.profileImage != null
                          ? NetworkImage(widget.chat.profileImage!)
                          : null,
                      child: widget.chat.profileImage == null
                          ? Icon(
                              widget.chat.isGroup ? Icons.group : Icons.person,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.chat.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
        // UI: Menu options
        actions: _isSearching
            ? null
            : [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
            onSelected: (value) {
              // LOGIC: Handle menu selection
              if (value == 'search') {
                setState(() {
                  _isSearching = true;
                });
              } else if (value == 'media') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MediaScreen(
                  chatName: widget.chat.name,
                  receiverUserId: widget.chat.receiverUserId,
                )));
              } else if (value == 'disappearing') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DisappearingMessagesScreen()));
              } else if (value == 'theme') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatThemeScreen()),
                ).then((theme) {
                  if (theme != null) {
                    setState(() => _selectedTheme = theme);
                  }
                });
              } else if (value == 'more') {
                _showMoreOptions(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 12),
                    Text('Search'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'media',
                child: Row(
                  children: [
                    Icon(Icons.perm_media),
                    SizedBox(width: 12),
                    Text('Media, links, and docs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'disappearing',
                child: Row(
                  children: [
                    Icon(Icons.timer),
                    SizedBox(width: 12),
                    Text('Disappearing messages'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.color_lens),
                    SizedBox(width: 12),
                    Text('Chat theme'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'more',
                child: Row(
                  children: [
                    Icon(Icons.more_horiz),
                    SizedBox(width: 12),
                    Text('More'),
                    Spacer(),
                    Icon(Icons.arrow_right, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // ==================== UI: BODY ====================
      body: Column(
        children: [
          // UI: Messages list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // UI: Loading state
                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // UI: Empty state
                if (chatProvider.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // UI: Messages list
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      message: chatProvider.messages[index],
                      theme: _selectedTheme,
                    );
                  },
                );
              },
            ),
          ),
          // ==================== UI: INPUT AREA ====================
          SafeArea(
            child: Column(
              children: [
                // UI: Attachment options (Camera, Gallery, Video)
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
                // UI: Message input bar
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
                      // UI: Attachment button
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
                      // UI: Text input field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
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
                      // UI: Send button
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // LOGIC: Send message
                            if (_messageController.text.trim().isNotEmpty) {
                              final message = _messageController.text.trim();
                              context.read<ChatProvider>().sendMessage(
                                message,
                                widget.chat.receiverUserId,
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

  // ==================== LIFECYCLE: DISPOSE ====================
  @override
  void dispose() {
    // LOGIC: Clear current chat
    FCMService.setCurrentChat(null);
    
    _refreshTimer?.cancel();
    _chatProvider.removeListener(_scrollToBottom);
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== LOGIC: AUTO SCROLL ====================
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

  // ==================== UI: ATTACHMENT OPTION WIDGET ====================
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

  // ==================== LOGIC: PICK MEDIA (IMAGE/VIDEO) ====================
  Future<void> _pickMedia(ImageSource source, String type) async {
    try {
      if (type == 'video') {
        // LOGIC: Pick single video
        final file = await _picker.pickVideo(source: source);
        if (file != null) {
          setState(() => _showAttachmentOptions = false);
          await _sendSingleMedia(file.path, 'video');
        }
      } else {
        // LOGIC: Open image picker screen for multiple selection
        setState(() => _showAttachmentOptions = false);
        
        final selectedImages = await Navigator.push<List<XFile>>(
          context,
          MaterialPageRoute(builder: (_) => ImagePickerScreen()),
        );
        
        if (selectedImages != null && selectedImages.isNotEmpty) {
          // UI: Show upload progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Uploading ${selectedImages.length} image(s)...'),
                ],
              ),
              duration: Duration(seconds: 30),
            ),
          );

          if (selectedImages.length == 1) {
            // LOGIC: Send single image
            await _sendSingleMedia(selectedImages[0].path, 'image');
          } else {
            // LOGIC: Send multiple images as grouped message
            final imagePaths = selectedImages.map((f) => f.path).join('|||');
            
            await context.read<ChatProvider>().sendMessage(
              'IMAGES:$imagePaths',
              widget.chat.receiverUserId,
            );

            // UI: Show success message
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${selectedImages.length} images sent!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      // UI: Show error message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading $type: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== LOGIC: SEND SINGLE MEDIA ====================
  Future<void> _sendSingleMedia(String path, String type) async {
    // UI: Show upload progress
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Uploading $type...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    // LOGIC: Send media message
    final mediaMessage = type == 'video' ? 'VIDEO:$path' : 'IMAGE:$path';
    await context.read<ChatProvider>().sendMessage(mediaMessage, widget.chat.receiverUserId);

    // UI: Show success message
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.capitalize()} sent successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ==================== UI: MORE OPTIONS MENU ====================
  void _showMoreOptions(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.delete_sweep),
              SizedBox(width: 12),
              Text('Clear chat'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.file_download),
              SizedBox(width: 12),
              Text('Export chat'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'shortcut',
          child: Row(
            children: [
              Icon(Icons.add_to_home_screen),
              SizedBox(width: 12),
              Text('Add shortcut'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'list',
          child: Row(
            children: [
              Icon(Icons.playlist_add),
              SizedBox(width: 12),
              Text('Add to list'),
            ],
          ),
        ),
      ],
    ).then((value) {
      // LOGIC: Handle menu selection
      if (value == 'clear') {
        _showClearChatDialog();
      } else if (value == 'export') {
        _exportChat();
      } else if (value == 'shortcut') {
        _addShortcut();
      } else if (value == 'list') {
        _addToList();
      }
    });
  }

  // ==================== UI: CLEAR CHAT DIALOG ====================
  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This will clear all messages from this chat. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat cleared')),
              );
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  // ==================== LOGIC: EXPORT CHAT ====================
  void _exportChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting chat...')),
    );
  }

  // ==================== LOGIC: ADD SHORTCUT ====================
  void _addShortcut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shortcut added to home screen')),
    );
  }

  // ==================== LOGIC: ADD TO LIST ====================
  void _addToList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to list')),
    );
  }
}