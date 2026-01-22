import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/community_provider.dart';
import 'community_sidebar.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../chat/provider/chat_provider.dart' as chat;
import '../../calls/presentation/calls_screen.dart';
import '../../contacts/presentation/contacts_screen.dart';
import 'screens/settings_screen.dart';
import '../../chat/presentation/archived_chats_screen.dart';
import 'package:image_picker/image_picker.dart';

class CommunitySelectionScreen extends StatefulWidget {
  const CommunitySelectionScreen({super.key});

  @override
  State<CommunitySelectionScreen> createState() =>
      _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends State<CommunitySelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  int _currentTabIndex = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
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

    if (_searchController.text.isNotEmpty) {
      chats = chats
          .where((c) =>
              c.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              c.preview
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      drawer: const CommunityDrawer(),

      // STYLE APP BAR
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Community',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
         
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Camera'),
                        onTap: () async {
                          Navigator.pop(context);
                          final picker = ImagePicker();
                          await picker.pickImage(source: ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Gallery'),
                        onTap: () async {
                          Navigator.pop(context);
                          final picker = ImagePicker();
                          await picker.pickImage(source: ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'new_group', child: Text('New group')),
              PopupMenuItem(
                  value: 'new_community', child: Text('New community')),
              PopupMenuItem(
                  value: 'broadcast_list', child: Text('Broadcast list')),
              PopupMenuItem(
                  value: 'Linked Devices', child: Text('Linked devices')),
              PopupMenuItem(value: 'Starred', child: Text('Starred messages')),
              PopupMenuItem(value: 'payments', child: Text('Payments')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),

      //  BODY
      body: Column(
        children: [
          // 🔍 SEARCH BAR (WHATSAPP STYLE)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Ask Meta AI or Search',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // FILTER CHIPS
          if (_currentTabIndex == 0)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Unread'),
                  _buildFilterChip('Favorite'),
                  _buildFilterChip('Groups'),
                  _buildFilterChip('Important'),
                ],
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatsTab(_getFilteredChats(chats)),
                _buildCommunitiesTab(),
                const CallsScreen(),
                const Center(child: Text('Updates Screen')),
              ],
            ),
          ),
        ],
      ),

      // ✅ BOTTOM TAB BAR
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

      // ✅ FAB
      floatingActionButton: _currentTabIndex == 0
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

  // ================= HELPERS =================

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _selectedFilter == label,
        onSelected: (_) {
          setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  List<ChatItem> _getFilteredChats(List<ChatItem> chats) {
    switch (_selectedFilter) {
      case 'Unread':
        return chats.where((c) => c.unread > 0).toList();
      case 'Groups':
        return chats
            .where((c) => c.members != null && c.members!.isNotEmpty)
            .toList();
      default:
        return chats;
    }
  }

  Widget _buildChatsTab(List<ChatItem> chats) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.archive_outlined),
          title: const Text('Archived'),
          subtitle: const Text('2 chats'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ArchivedChatsScreen()),
            );
          },
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (_, i) {
              final chatItem = chats[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: chatItem.avatarColor,
                  child: Text(chatItem.initials),
                ),
                title: Text(chatItem.name),
                subtitle: Text(chatItem.preview, maxLines: 1),
                trailing: chatItem.unread > 0
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text('${chatItem.unread}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      )
                    : null,
                onTap: () => _openChat(context, chatItem),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitiesTab() {
    return const Center(child: Text('Communities'));
  }

  void _openChat(BuildContext context, ChatItem item) {
    final chatItem = chat.ChatItem(
      id: item.name,
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
    if (value == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }
}
