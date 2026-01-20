import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/community_provider.dart';
import 'community_sidebar.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../chat/provider/chat_provider.dart' as chat;
import 'communities_screen.dart';
import '../../calls/presentation/calls_screen.dart';
import '../../contacts/presentation/contacts_screen.dart';
import 'screens/new_community_screen.dart';
import 'screens/broadcast_list_screen.dart';
import 'screens/linked_devices_screen.dart';
import 'screens/starred_messages_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/settings_screen.dart';

class CommunitySelectionScreen extends StatefulWidget {
  const CommunitySelectionScreen({super.key});

  @override
  State<CommunitySelectionScreen> createState() =>
      _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends State<CommunitySelectionScreen>
    with SingleTickerProviderStateMixin {

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityProvider>(context);
    List<ChatItem> chats = provider.chats;

    if (_isSearching && _searchController.text.isNotEmpty) {
      chats = chats
          .where((c) =>
              c.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              c.preview.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      drawer: const CommunityDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Community'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
              });
            },
          ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                 const PopupMenuItem(
                  value: 'new_group',
                  child: Text('New group'),
                ),
                const PopupMenuItem(
                  value: 'new_community',
                  child: Text('New community'),
                ),
               
                const PopupMenuItem(
                  value: 'broadcast_list',
                  child: Text('Broadcast list'),
                ),
                 const PopupMenuItem(
                  value: 'Linked Devices',
                  child: Text('Linked Devices'),
                ),
                 const PopupMenuItem(
                  value: 'Starred',
                  child: Text('Starred'),
                ),
                const PopupMenuItem(
                  value: 'payments',
                  child: Text('Payments'),
                ),
                const PopupMenuItem(
                  value: 'read_all',
                  child: Text('Read all'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings'),
                ),
              ],
            ),
        ],
      ),

      // ✅ BODY
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(chats),
          _buildCommunitiesTab(),
          _buildCallsTab(),
          _buildUpdatesTab(),
        ],
      ),

      // ✅ BOTTOM TAB BAR (4 tabs)
      bottomNavigationBar: Material(
        elevation: 10,
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Chats'),
            Tab(icon: Icon(Icons.groups), text: 'Communities'),
            Tab(icon: Icon(Icons.call), text: 'Calls'),
            Tab(icon: Icon(Icons.update), text: 'Updates'),
          ],
        ),
      ),

      // ✅ FAB only on Chats tab
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactsScreen()),
                );
              },
              child: const Icon(Icons.chat),
            )
          : null,
    );
  }

  // -------------------- TABS --------------------

  Widget _buildChatsTab(List<ChatItem> chats) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chatItem = chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: chatItem.avatarColor,
            child: Text(chatItem.initials,
                style: const TextStyle(color: Colors.white)),
          ),
          title: Text(chatItem.name),
          subtitle: Text(chatItem.preview, maxLines: 1),
          trailing: Text(chatItem.time),
          onTap: () => _openChat(context, chatItem),
        );
      },
    );
  }

  Widget _buildCommunitiesTab() {
    return ListView(
      children: [
        // New Community Option
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          title: const Text(
            'New community',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create new community')),
            );
          },
        ),
        const Divider(),
        
        // Communities List
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: const Text(
            'Tech Enthusiasts',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Latest tech news and discussions\n1250 members'),
          isThreeLine: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opened Tech Enthusiasts community'),
              ),
            );
          },
        ),
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'F',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: const Text(
            'Flutter Developers',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Flutter development tips and tricks\n890 members'),
          isThreeLine: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opened Flutter Developers community'),
              ),
            );
          },
        ),
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: const Text(
            'Design Community',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('UI/UX design inspiration\n567 members'),
          isThreeLine: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opened Design Community'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCallsTab() => const CallsScreen();

  Widget _buildUpdatesTab() =>
      const Center(child: Text('Updates Screen'));

  void _openChat(BuildContext context, ChatItem item) {
    final chatItem = chat.ChatItem(
      id: item.name.hashCode.toString(),
      name: item.name,
      lastMessage: item.preview,
      time: item.time,
      unreadCount: item.unread,
      isGroup: false,
      isOnline: false,
      memberCount: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(chat: chatItem)),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'new_community':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewCommunityScreen()),
        );
        break;
      case 'new_group':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactsScreen()),
        );
        break;
      case 'broadcast_list':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BroadcastListScreen()),
        );
        break;
      case 'Linked Devices':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LinkedDevicesScreen()),
        );
        break;
      case 'Starred':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StarredMessagesScreen()),
        );
        break;
      case 'payments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentsScreen()),
        );
        break;
      case 'read_all':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All messages marked as read')),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }
}

