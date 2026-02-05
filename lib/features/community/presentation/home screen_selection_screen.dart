import 'package:all_in_one_community/features/chat/presentation/widgets/chat_screen2/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/community_provider.dart';
import 'community_sidebar.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/data/models/chat_model.dart';
import '../../chat/provider/chat_provider.dart' as chat;
import '../../calls/presentation/calls_screen.dart';
import '../../contacts/presentation/contacts_screen.dart';
import '../../chat/presentation/screens_options/settings_screen.dart';
import '../../chat/presentation/archived_chats_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'new_list_screen.dart';
import '../../chat/presentation/screens_options/new_group_screen.dart';
import '../../chat/presentation/screens_options/new_community_screen.dart';
import '../../chat/presentation/screens_options/broadcast_list_screen.dart';
import '../../chat/presentation/screens_options/linked_devices_screen.dart';
import '../../chat/presentation/screens_options/starred_messages_screen.dart';
import '../../chat/presentation/screens_options/payments_screen.dart';
import '../../calls/presentation/appbar_option_screen/schedule_call_screen.dart';
import '../../calls/presentation/appbar_option_screen/clear_call_log_screen.dart';
import '../../status/presentation/option_appbar_screen/status_privacy_screen.dart';
import '../../status/presentation/option_appbar_screen/create_channel_screen.dart';
import '../../status/presentation/option_appbar_screen/find_channels_screen.dart';
import '../../status/presentation/status_screen.dart';

class ChatItem {
  final String initials;
  final String name;
  final String preview;
  final String time;
  final int unread;
  final Color avatarColor;
  final List<String>? members;

  ChatItem({
    required this.initials,
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.avatarColor,
    this.members,
  });
}

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
  bool _isSearching = false;

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
    
    // Load chats from ChatProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<chat.ChatProvider>(context, listen: false).loadChats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityProvider>(context);
    final chatProvider = Provider.of<chat.ChatProvider>(context);
    
    // Use ChatProvider chats directly - they are already loaded from persistence
    List<ChatItem> chats = chatProvider.chats.map((chatItem) => ChatItem(
        initials: chatItem.name.isNotEmpty ? chatItem.name[0].toUpperCase() : '?',
        name: chatItem.name,
        preview: chatItem.lastMessage,
        time: _formatTime(chatItem.lastMessageTime),
        unread: chatItem.unreadCount,
        avatarColor: Colors.blue,
      )).toList();

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
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: Icon(
                    Icons.menu, // three lines
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),

        
        title: (_isSearching && _currentTabIndex != 0)
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: AppTheme.primaryColor),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                _getAppBarTitle(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
        actions: [
          // Show search icon for non-chat tabs
          if (_currentTabIndex != 0)
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppTheme.primaryColor),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                  }
                });
              },
            ),
          if (_currentTabIndex == 0)
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: AppTheme.primaryColor),
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
            icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => _getMenuItems(),
          ),
        ],
      ),

      //  BODY
      body: Column(
        children: [
          //  SEARCH BAR (ONLY FOR CHATS TAB)
          if (_currentTabIndex == 0)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

          // FILTER CHIPS
          if (_currentTabIndex == 0)
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Unread'),
                  _buildFilterChip('Favorites'),
                  _buildFilterChip('Groups'),
                  _buildFilterChip('New Order'),
                  _buildFilterChip('New Customer'),
                  _buildFilterChip('Pending Payment'),
                  _buildFilterChip('Paid'),
                  _buildFilterChip('Important'),
                  _buildFilterChip('Order Complete'),
                  _buildFilterChip('Follow Up'),
                  _buildFilterChip('Lead'),
                  _buildAddListButton(),
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
                _buildStatusTab(),
              ],
            ),
          ),
        ],
      ),

      //  BOTTOM TAB BAR
      bottomNavigationBar: Material(
        elevation: 9,
        child: Container(
          height: 55,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            tabs: const [
              Tab(icon: Icon(Icons.chat, size: 18), text: 'Chats'),
              Tab(icon: Icon(Icons.groups, size: 18), text: 'Communities'),
              Tab(icon: Icon(Icons.call, size: 18), text: 'Calls'),
              Tab(icon: Icon(Icons.update, size: 18), text: 'Updates'),
            ],
          ),
        ),
      ),

      //  FAB
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
          : _currentTabIndex == 3
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: "text_status",
                      mini: true,
                      backgroundColor: Colors.grey[600],
                      onPressed: () {},
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: "camera_status",
                      backgroundColor: AppTheme.primaryColor,
                      onPressed: () {},
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ],
                )
              : null,
    );
  }

  String _getAppBarTitle() {
    switch (_currentTabIndex) {
      case 0:
        return 'Chats';
      case 1:
        return 'Communities';
      case 2:
        return 'Calls';
      case 3:
        return 'Updates';
      default:
        return 'Community';
    }
  }

  List<PopupMenuEntry<String>> _getMenuItems() {
    switch (_currentTabIndex) {
      case 0: // Chats tab
        return const [
          PopupMenuItem(value: 'new_group', child: Text('New group')),
          PopupMenuItem(value: 'new_community', child: Text('New community')),
          PopupMenuItem(value: 'broadcast_list', child: Text('Broadcast list')),
          PopupMenuItem(value: 'Linked Devices', child: Text('Linked devices')),
          PopupMenuItem(value: 'Starred', child: Text('Starred messages')),
          PopupMenuItem(value: 'payments', child: Text('Payments')),
          PopupMenuItem(value: 'settings', child: Text('Settings')),
        ];
      case 1: // Communities tab
        return const [
          PopupMenuItem(value: 'settings', child: Text('Settings')),
        ];
      case 2: // Calls tab
        return const [
          PopupMenuItem(value: 'schedule_call', child: Text('Schedule call')),
          PopupMenuItem(value: 'clear_call_log', child: Text('Clear call log')),
          PopupMenuItem(value: 'settings', child: Text('Settings')),
        ];
      case 3: // Updates tab
        return const [
          PopupMenuItem(value: 'status_privacy', child: Text('Status privacy')),
          PopupMenuItem(value: 'create_channel', child: Text('Create channel')),
          PopupMenuItem(value: 'find_channels', child: Text('Find channels')),
          PopupMenuItem(value: 'settings', child: Text('Settings')),
        ];
      default:
        return const [
          PopupMenuItem(value: 'settings', child: Text('Settings')),
        ];
    }
  }

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

  Widget _buildAddListButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewListScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text('New list', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  List<ChatItem> _getFilteredChats(List<ChatItem> chats) {
    switch (_selectedFilter) {
      case 'Unread':
        return chats.where((c) => c.unread > 0).toList();
      case 'Favorites':
        // Filter favorite chats (placeholder)
        return [];
      case 'Groups':
        return chats
            .where((c) => c.members != null && c.members!.isNotEmpty)
            .toList();
      case 'New Order':
        // Filter chats with new order status
        return [];
      case 'New Customer':
        // Filter chats with new customers
        return [];
      case 'Pending Payment':
        // Filter chats with pending payments
        return [];
      case 'Paid':
        // Filter chats with completed payments
        return [];
      case 'Important':
        // Filter important chats
        return [];
      case 'Order Complete':
        // Filter chats with completed orders
        return [];
      case 'Follow Up':
        // Filter chats requiring follow up
        return [];
      case 'Lead':
        // Filter potential leads
        return [];
      default:
        return chats;
    }
  }

  Widget _buildChatsTab(List<ChatItem> chats) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ArchivedChatsScreen()),
            );
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.archive_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Archived',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${chats.length} chats${chats.fold<int>(0, (sum, chat) => sum + chat.unread) > 0 ? ' • ${chats.fold<int>(0, (sum, chat) => sum + chat.unread)} new' : ''}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: chats.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No chats yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        'Tap to start conversation',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (_, i) {
                    final chatItem = chats[i];
                    return InkWell(
                      onTap: () {
                        print('Tapping on chat: ${chatItem.name}');
                        _openChat(context, chatItem);
                      },
                      child: ListTile(
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
                      ),
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

  Widget _buildStatusTab() {
    return Container(
      color: Colors.grey[50],
      child: ListView(
        children: [
          _buildMyStatus(),
          const Divider(height: 8, thickness: 8, color: Color(0xFFF0F0F0)),
          _buildRecentUpdates(),
        ],
      ),
    );
  }

  Widget _buildMyStatus() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor,
                child: Text('M', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('Tap to add status update', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdates() {
    final statuses = [
      {'name': 'User 1', 'time': '1 minutes ago'},
      {'name': 'User 2', 'time': '2 minutes ago'},
      {'name': 'User 3', 'time': '3 minutes ago'},
      {'name': 'User 4', 'time': '4 minutes ago'},
      {'name': 'User 5', 'time': '5 minutes ago'},
    ];

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Recent updates', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          ...statuses.map((status) => _buildStatusTile(status['name']!, status['time']!)),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String name, String time) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          child: Text(name[0], style: const TextStyle(fontSize: 18)),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
    );
  }

  void _openChat(BuildContext context, ChatItem item) {
    // Use the existing Chat from ChatProvider if available, otherwise create local one
    final chatProvider = Provider.of<chat.ChatProvider>(context, listen: false);
    
    // Find existing chat or create new one
    Chat existingChat;
    try {
      existingChat = chatProvider.chats.firstWhere(
        (c) => c.name == item.name,
      );
    } catch (e) {
      // Create a local chat for demo
      final localId = 'local_${item.name.toLowerCase().replaceAll(' ', '_')}';
      existingChat = Chat(
        id: localId,
        name: item.name,
        lastMessage: item.preview,
        lastMessageTime: DateTime.now(),
        receiverUserId: localId,
      );
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(chat: existingChat)),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
      // Chat tab actions
      case 'new_group':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewGroupScreen()),
        );
        break;
      case 'new_community':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewCommunityScreen()),
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
      // Communities tab actions
      case 'create_community':
      case 'join_community':
      case 'community_settings':
      case 'manage_members':
        // Handle community-specific actions
        break;
      // Calls tab actions
      case 'schedule_call':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScheduleCallScreen()),
        );
        break;
      case 'clear_call_log':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClearCallLogScreen()),
        );
        break;
      // Updates tab actions
      case 'status_privacy':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StatusPrivacyScreen()),
        );
        break;
      case 'create_channel':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateChannelScreen()),
        );
        break;
      case 'find_channels':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FindChannelsScreen()),
        );
        break;
    }
  }
}
