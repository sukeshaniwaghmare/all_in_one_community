import 'package:flutter/material.dart';
import '../../community/domain/community_type.dart';
import '../provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'realtime_chat_screen.dart' as chat_screen;
import 'create_group_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../../core/widgets/common_menu_items.dart';
import '../../contacts/presentation/simple_contacts_screen.dart';

class ChatListScreen extends StatefulWidget {
  final CommunityType communityType;

  const ChatListScreen({super.key, required this.communityType});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChats();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                      Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
                    return _ChatListTile(chat: chat, onTap: () => _navigateToChat(context, chat));
                  },
                ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "contact_fab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SimpleContactsScreen()),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.contacts, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "chat_fab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              );
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, ChatItem chat) {
    context.read<ChatProvider>().markAsRead(chat.id);
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => chat_screen.RealtimeChatScreen(
         chatId: chat.id,
          chatName: chat.name,
          isGroup: chat.isGroup,
        ),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatItem chat;
  final VoidCallback onTap;

  const _ChatListTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: chat.isGroup ? AppTheme.primaryColor : _getAvatarColor(chat.name),
                  child: Text(
                    chat.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                ),
                if (chat.isOnline && !chat.isGroup)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.onlineColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
              ],
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
                  Row(
                    children: [
                      if (chat.isGroup && chat.lastMessageSender != null)
                        Text(
                          '${chat.lastMessageSender}: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
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