import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/community_provider.dart';
import 'main_navigation_screen.dart';
import 'community_sidebar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../chat/provider/chat_provider.dart' as chat;
import '../../status/presentation/status_screen.dart';
import '../../calls/presentation/calls_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../search/presentation/search_screen.dart';

class CommunitySelectionScreen extends StatefulWidget {
  const CommunitySelectionScreen({super.key});

  @override
  State<CommunitySelectionScreen> createState() => _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends State<CommunitySelectionScreen> {
  String _selectedTab = 'all';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityProvider>(context);
    final List<ChatItem> allChats = provider.chats;
    List<ChatItem> filteredChats = _selectedTab == 'dealdost'
        ? allChats.where((chat) => chat.name.toLowerCase().contains('deal dost')).toList()
        : _selectedTab == 'videos'
        ? []
        : allChats;
    
    if (_isSearching && _searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredChats = filteredChats.where((chat) => 
        chat.name.toLowerCase().contains(searchText) ||
        chat.preview.toLowerCase().contains(searchText)
      ).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const CommunityDrawer(),
      appBar: AppTopBar(
        title: _isSearching ? '' : 'Community',
        titleWidget: _isSearching ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search chats and messages...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() {}),
        ) : null,
        leading: _isSearching ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ) : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: _isSearching ? [] : [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const CallsScreen()
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'status', child: Text('Status')),
              const PopupMenuItem(value: 'calls', child: Text('Calls')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'New group', child: Text('New group')),
              const PopupMenuItem(value: 'New broadcast', child: Text('New broadcast')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(allChats.length, filteredChats.length, allChats),
          Expanded(
            child: (_isSearching && filteredChats.isEmpty && _searchController.text.isNotEmpty)
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No chats found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.separated(
              itemCount: _selectedTab == 'all' ? filteredChats.length + 1 : filteredChats.length,
              separatorBuilder: (context, index) {
                if (_selectedTab == 'all') {
                  return index == 0 ? const SizedBox.shrink() : const Divider(height: 1, indent: 72);
                }
                return const Divider(height: 1, indent: 72);
              },
              itemBuilder: (context, index) {
                if (_selectedTab == 'all' && index == 0) {
                  return _buildArchivedHeader();
                }
                final chatIndex = _selectedTab == 'all' ? index - 1 : index;
                final chatItem = filteredChats[chatIndex];
                return _CommunityTile(
                  chatItem: chatItem,
                  onTap: () => _openChat(context, chatItem),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'status':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen()));
        break;
      case 'calls':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CallsScreen()));
        break;
      case 'settings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$value selected')),
        );
    }
  }

  Widget _buildTabs(int totalCount, int filteredCount, List<ChatItem> allChats) {
    final dealDostCount = allChats.where((chat) => chat.name.toLowerCase().contains('deal dost')).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedTab = 'all'),
            child: Text(
              'All chats  $totalCount',
              style: TextStyle(
                fontSize: 14,
                color: _selectedTab == 'all' ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: _selectedTab == 'all' ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
         
          GestureDetector(
            onTap: () => setState(() => _selectedTab = 'videos'),
            child: Text(
              'All videos',
              style: TextStyle(
                fontSize: 14,
                color: _selectedTab == 'videos' ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: _selectedTab == 'videos' ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.folder, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            'Archived Chats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, ChatItem communityChat) {
    final isGroup = communityChat.members != null && communityChat.members!.isNotEmpty;
    final memberCount = isGroup ? (communityChat.members!.length + 1) : 0;
    final chatItem = chat.ChatItem(
      id: communityChat.name.hashCode.toString(),
      name: communityChat.name,
      lastMessage: communityChat.preview,
      time: communityChat.time,
      unreadCount: communityChat.unread,
      isGroup: isGroup,
      isOnline: false,
      memberCount: memberCount,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: chatItem)));
  }
}

class _CommunityTile extends StatelessWidget {
  final ChatItem chatItem;
  final VoidCallback onTap;

  const _CommunityTile({
    required this.chatItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = chatItem.unread;
    final hasTime = chatItem.time.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: chatItem.avatarColor,
              child: Text(
                chatItem.initials,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatItem.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chatItem.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasTime)
                  Text(
                    chatItem.time,
                    style: TextStyle(
                      fontSize: 13,
                      color: unreadCount > 0 ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
}
