import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../community/domain/community_type.dart';
import '../../../provider/chat_provider.dart';
import 'package:provider/provider.dart';
import '../chat_screen2/chat_screen.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/apptopbar.dart';
import '../../../../../core/widgets/common_menu_items.dart';
import '../../../../../core/services/realtime_service.dart';
import '../../../../../core/services/auth_service.dart';

class ChatListScreen extends StatefulWidget {
  final CommunityType communityType;

  const ChatListScreen({super.key, required this.communityType});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final RealtimeService _realtimeService = RealtimeService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChats();
      final userId = _authService.currentUserId;
      if (userId != null) {
        _realtimeService.subscribeToChats(userId);
      }
    });
  }

  @override
  void dispose() {
    _realtimeService.unsubscribeFromChats();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: widget.communityType.name,
        menuItems: CommonMenuItems.getChatMenuItems(),
        onMenuSelected: (value) => CommonMenuItems.handleMenuSelection(context, value),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.chats.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      Text('Start a conversation!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: provider.chats.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final chat = provider.chats[index];
                    return _UserProfileTile(chat: chat, onTap: () => _navigateToChat(context, chat));
                  },
                ),
      
    );
  }

  void _navigateToChat(BuildContext context, chat) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: chat),
      ),
    );
  }
}

class _UserProfileTile extends StatelessWidget {
  final dynamic chat;
  final VoidCallback onTap;

  const _UserProfileTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = chat.profileImage;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _getAvatarColor(chat.name),
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            chat.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
                        },
                      ),
                    )
                  : Text(
                      chat.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: chat.unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 13,
                    color: chat.unreadCount > 0 ? AppTheme.primaryColor : AppTheme.textSecondary,
                  ),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    const colors = [Color(0xFF5B9BD5), Color(0xFF70AD47), Color(0xFFFFC000), Color(0xFFED7D31), Color(0xFF9E480E), Color(0xFFC55A11), Color(0xFF7030A0)];
    return colors[name.hashCode.abs() % colors.length];
  }
}