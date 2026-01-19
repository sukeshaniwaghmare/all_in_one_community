import 'package:flutter/material.dart';
import '../provider/chat_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import 'info_screen.dart';
import '../../media/presentation/media_viewer_screen.dart';
import 'disappearing_messages_screen.dart';
import 'chat_theme_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final ChatItem chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _showEmojiPicker = false;
  bool _isRecording = false;
  bool _isSearching = false;
  List<Message> _filteredMessages = [];
  Map<String, dynamic>? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages(widget.chat.id);
    });
    _messageController.addListener(() {
      setState(() => _isTyping = _messageController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatBgColor = _selectedTheme?['background'] ?? AppTheme.chatBackground;
    final primaryColor = _selectedTheme?['color'] ?? AppTheme.primaryColor;
    
    return Scaffold(
      backgroundColor: chatBgColor,
      appBar: _isSearching ? _buildSearchAppBar() : AppTopBar(
        title: widget.chat.name,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleWidget: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoScreen(
                  name: widget.chat.name,
                  memberCount: widget.chat.memberCount,
                  isGroup: widget.chat.isGroup,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: widget.chat.isGroup ? Colors.white24 : _getAvatarColor(widget.chat.name),
                child: Text(widget.chat.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.chat.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    Text(
                      widget.chat.isGroup ? '${widget.chat.memberCount} members' : (widget.chat.isOnline ? 'online' : 'last seen recently'),
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call, color: Colors.white), onPressed: _makePhoneCall),
          IconButton(icon: const Icon(Icons.videocam, color: Colors.white), onPressed: _makeVideoCall),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              if (widget.chat.isGroup) const PopupMenuItem(value: 'new_group', child: Text('New group')),
              const PopupMenuItem(value: 'view_contact', child: Text('View contact')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'search', child: Text('Search')),
              const PopupMenuItem(value: 'media', child: Text('Media, links, and docs')),
              const PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
              const PopupMenuItem(value: 'disappearing', child: Text('Disappearing messages')),
              const PopupMenuItem(value: 'chat_theme', child: Text('Chat theme')),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'more',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('More'),
                    Icon(Icons.arrow_right, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                final messages = _isSearching ? _filteredMessages : provider.messages;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _MessageBubble(
                      message: message, 
                      isGroup: widget.chat.isGroup,
                      themeColor: primaryColor,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
          if (_showEmojiPicker)
            Flexible(
              child: SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _messageController.text += emoji.emoji;
                    setState(() => _isTyping = _messageController.text.isNotEmpty);
                  },
                  config: const Config(
                    emojiViewConfig: EmojiViewConfig(columns: 7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final primaryColor = _selectedTheme?['color'] ?? AppTheme.primaryColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -1))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() => _showEmojiPicker = !_showEmojiPicker);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppTheme.textSecondary, size: 24),
                    onPressed: _showAttachmentOptions,
                  ),
                  if (!_isTyping)
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: AppTheme.textSecondary, size: 24),
                      onPressed: _openCamera,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: primaryColor, 
              shape: BoxShape.circle
            ),
            child: IconButton(
              onPressed: _isTyping ? _sendMessage : _toggleRecording,
              icon: Icon(_isTyping ? Icons.send : (_isRecording ? Icons.stop : Icons.mic), color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(Icons.insert_drive_file, 'Document', AppTheme.primaryColor),
                _buildAttachmentOption(Icons.camera_alt, 'Camera', Colors.pink),
                _buildAttachmentOption(Icons.photo_library, 'Gallery', Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(Icons.headset, 'Audio', Colors.orange),
                _buildAttachmentOption(Icons.location_on, 'Location', Colors.green),
                _buildAttachmentOption(Icons.person, 'Contact', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        if (label == 'Camera') {
          await _openCamera();
        } else if (label == 'Gallery') {
          final picker = ImagePicker();
          final image = await picker.pickImage(source: ImageSource.gallery);
          if (image != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image selected: ${image.name}')),
            );
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(_messageController.text.trim());
      _messageController.clear();
      setState(() => _showEmojiPicker = false);
    }
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo captured: ${image.name}')),
      );
    }
  }

  void _handleMenuAction(String value) {
    if (value == 'more') {
      _showMoreOptions();
    } else if (value == 'new_group') {
      _createNewGroup();
    } else if (value == 'search') {
      setState(() {
        _isSearching = true;
      });
    } else if (value == 'disappearing') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DisappearingMessagesScreen(),
        ),
      );
    } else if (value == 'chat_theme') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatThemeScreen(currentTheme: _selectedTheme),
        ),
      ).then((selectedTheme) {
        if (selectedTheme != null) {
          setState(() {
            _selectedTheme = selectedTheme;
          });
          _saveTheme(selectedTheme);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Theme changed to ${selectedTheme['name']}')),
          );
        }
      });
    } else if (value == 'mute') {
      _muteNotifications();
    } else if (value == 'view_contact') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InfoScreen(
            name: widget.chat.name,
            memberCount: widget.chat.memberCount,
            isGroup: widget.chat.isGroup,
          ),
        ),
      );
    } else if (value == 'media') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MediaViewerScreen(
            mediaUrl: 'sample_image.jpg',
            mediaType: 'image',
            caption: 'Sample media from chat',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${value.replaceAll('_', ' ').toUpperCase()} clicked')),
      );
    }
  }

  void _showMoreOptions() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Size overlaySize = overlay.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlaySize.width - 200,
        kToolbarHeight + 10,
        20,
        0,
      ),
      items: [
        const PopupMenuItem(value: 'report', child: Text('Report')),
        const PopupMenuItem(value: 'block', child: Text('Block')),
        const PopupMenuItem(value: 'clear_chat', child: Text('Clear chat')),
        const PopupMenuItem(value: 'export_chat', child: Text('Export chat')),
        const PopupMenuItem(value: 'add_shortcut', child: Text('Add shortcut')),
        const PopupMenuItem(value: 'add_to_list', child: Text('Add to list')),
      ],
    ).then((value) {
      if (value != null) {
        _handleMoreAction(value);
      }
    });
  }

  Future<void> _toggleRecording() async {
    // For demo/testing: just show a message instead of actual recording
    if (_isRecording) {
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎤 Voice message sent')),
        );
        // Send fake voice message
        context.read<ChatProvider>().sendMessage('🎤 Voice message');
      }
    } else {
      setState(() => _isRecording = true);
      // Auto-stop after 2 seconds for demo
      Future.delayed(const Duration(seconds: 2), () {
        if (_isRecording && mounted) {
          _toggleRecording();
        }
      });
    }
  }

  void _makePhoneCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Voice Call'),
        content: Text('Calling ${widget.chat.name}...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  void _makeVideoCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Video Call'),
        content: Text('Video calling ${widget.chat.name}...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  void _createNewGroup() {
    final TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group name',
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select members to add to the group'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (groupNameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group "${groupNameController.text.trim()}" created!')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Messages'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search in conversation',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (searchController.text.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Searching for "${searchController.text.trim()}"')),
                );
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            _filteredMessages.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search messages...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: _searchMessages,
      ),
    );
  }

  void _searchMessages(String query) {
    final provider = context.read<ChatProvider>();
    if (query.isEmpty) {
      setState(() {
        _filteredMessages.clear();
      });
      return;
    }
    
    final filtered = provider.messages
        .where((message) => message.text.toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    setState(() {
      _filteredMessages = filtered;
    });
  }

  void _muteNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('8 hours'),
              onTap: () => _setMuteDuration('8 hours'),
            ),
            ListTile(
              title: const Text('1 week'),
              onTap: () => _setMuteDuration('1 week'),
            ),
            ListTile(
              title: const Text('Always'),
              onTap: () => _setMuteDuration('Always'),
            ),
          ],
        ),
      ),
    );
  }

  void _setMuteDuration(String duration) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifications muted for $duration')),
    );
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('chat_theme_${widget.chat.id}');
    if (themeName != null) {
      final themes = [
        {'name': 'Default', 'color': Colors.teal, 'background': Colors.grey[100]},
        {'name': 'Blue', 'color': Colors.blue, 'background': Colors.blue[50]},
        {'name': 'Pink', 'color': Colors.pink, 'background': Colors.pink[50]},
        {'name': 'Purple', 'color': Colors.purple, 'background': Colors.purple[50]},
        {'name': 'Green', 'color': Colors.green, 'background': Colors.green[50]},
        {'name': 'Orange', 'color': Colors.orange, 'background': Colors.orange[50]},
      ];
      final theme = themes.firstWhere((t) => t['name'] == themeName, orElse: () => themes[0]);
      setState(() {
        _selectedTheme = theme;
      });
    }
  }

  Future<void> _saveTheme(Map<String, dynamic> theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_theme_${widget.chat.id}', theme['name']);
  }

  void _handleMoreAction(String value) {
    if (value == 'report') {
      _showReportDialog();
    } else if (value == 'block') {
      _showBlockDialog();
    } else if (value == 'clear_chat') {
      _showClearChatDialog();
    } else if (value == 'export_chat') {
      _exportChat();
    } else if (value == 'add_shortcut') {
      _addShortcut();
    } else if (value == 'add_to_list') {
      _showAddToListDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${value.replaceAll('_', ' ').toUpperCase()} clicked')),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report ${widget.chat.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Spam'),
              onTap: () => _submitReport('Spam'),
            ),
            ListTile(
              title: const Text('Harassment'),
              onTap: () => _submitReport('Harassment'),
            ),
            ListTile(
              title: const Text('Inappropriate content'),
              onTap: () => _submitReport('Inappropriate content'),
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () => _submitReport('Other'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _submitReport(String reason) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report submitted for $reason')),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block ${widget.chat.name}?'),
        content: Text('Blocked contacts will no longer be able to call you or send you messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.chat.name} has been blocked')),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This will clear all messages from this chat. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatProvider>().clearMessages();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export chat'),
        content: const Text('Export chat history as a text file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat with ${widget.chat.name} exported successfully')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _addShortcut() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shortcut for ${widget.chat.name} added to home screen')),
    );
  }

  void _showAddToListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to list'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Favorites'),
              onTap: () => _addToList('Favorites'),
            ),
            ListTile(
              title: const Text('Important'),
              onTap: () => _addToList('Important'),
            ),
            ListTile(
              title: const Text('Work'),
              onTap: () => _addToList('Work'),
            ),
            ListTile(
              title: const Text('Family'),
              onTap: () => _addToList('Family'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addToList(String listName) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.chat.name} added to $listName list')),
    );
  }

  Color _getAvatarColor(String name) {
    const colors = [Color(0xFF5B9BD5), Color(0xFF70AD47), Color(0xFFFFC000), Color(0xFFED7D31), Color(0xFF9E480E)];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isGroup;
  final Color? themeColor;

  const _MessageBubble({
    required this.message, 
    required this.isGroup,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && isGroup && message.sender != null)
            CircleAvatar(
              radius: 16,
              backgroundColor: _getAvatarColor(message.sender!),
              child: Text(message.sender![0], style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          if (!message.isMe && isGroup) const SizedBox(width: 4),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: message.isMe ? (themeColor ?? AppTheme.outgoingBubble) : AppTheme.incomingBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(message.isMe ? 12 : 2),
                  bottomRight: Radius.circular(message.isMe ? 2 : 12),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isMe && isGroup && message.sender != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(message.sender!, style: TextStyle(color: _getAvatarColor(message.sender!), fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  Text(message.text, style: TextStyle(color: message.isMe ? Colors.white : AppTheme.textPrimary, fontSize: 15)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message.time, style: TextStyle(color: message.isMe ? Colors.white70 : AppTheme.textSecondary, fontSize: 11)),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(message.isRead ? Icons.done_all : Icons.done, size: 14, color: message.isRead ? Colors.lightBlueAccent : Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String name) {
    const colors = [Color(0xFF5B9BD5), Color(0xFF70AD47), Color(0xFFFFC000), Color(0xFFED7D31), Color(0xFF9E480E)];
    return colors[name.hashCode.abs() % colors.length];
  }
}