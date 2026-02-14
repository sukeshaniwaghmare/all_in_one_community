import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../community/provider/community_provider.dart';
import '../community/provider/community_list_provider.dart';
import 'community_sidebar.dart';
import '../community/presentation/communities_screen.dart';
import '../community/presentation/community_info_screen.dart';
import '../../core/theme/app_theme.dart';
import '../chat/data/models/chat_model.dart';
import '../chat/provider/chat_provider.dart' as chat;
import '../calls/presentation/call_history_screen.dart';
import '../contacts/presentation/select_contacts_screen.dart';
import '../chat/presentation/screens_options/settings_screen.dart';
import '../archived/presentation/archived_chats_screen.dart';
import '../archived/provider/archived_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../chat/presentation/widgets/chat_screen2/chat_screen.dart';
import '../chat/presentation/screens_options/new_group_screen.dart';
import '../chat/presentation/screens_options/new_community_screen.dart';
import '../chat/presentation/screens_options/broadcast_list_screen.dart';
import '../chat/presentation/screens_options/linked_devices_screen.dart';
import '../chat/presentation/screens_options/starred_messages_screen.dart';
import '../chat/presentation/screens_options/payments_screen.dart';
import '../calls/presentation/appbar_option_screen/schedule_call_screen.dart';
import '../status/presentation/status_view_screen.dart';
import '../status/provider/status_provider.dart';
import '../calls/services/call_service.dart';
import '../calls/domain/entities/call.dart';
import 'dart:io';

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
      Provider.of<ArchivedProvider>(context, listen: false).loadArchivedChats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<chat.ChatProvider>(context);
    final archivedProvider = Provider.of<ArchivedProvider>(context);
    List<ChatItem> chats = chatProvider.chats
        .where((c) => !archivedProvider.isArchived(c.id))
        .map((c) => ChatItem(
            initials: c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
            name: c.name,
            preview: c.lastMessage,
            time: _formatTime(c.lastMessageTime),
            unread: c.unreadCount,
            avatarColor: Colors.blue,
          )).toList();

    // Debug: Print all chats with their unread counts
    print('=== ALL CHATS ===');
    for (var chat in chats) {
      print('Chat: ${chat.name}, Unread: ${chat.unread}');
    }

    if (_searchController.text.isNotEmpty) {
      chats = chats.where((c) => c.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
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
              child: Icon(Icons.menu, color: AppTheme.primaryColor),
            ),
          ),
        ),

        title: _isSearching && _currentTabIndex != 0
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
              onPressed: () => _pickMediaForStatus(context),
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
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Unread', count: chats.where((c) => c.unread > 0).length),
                  _buildFilterChip('Favorites'),
                  _buildFilterChip('Commnunities'),
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
                const CallHistoryScreen(),
                _buildStatusTab(),
              ],
            ),
          ),
        ],
      ),

      //  BOTTOM TAB BAR
      bottomNavigationBar: Material(
        elevation: 9,
        child: SizedBox(
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
          PopupMenuItem(value: 'settings', child: Text('Settings')),
        ];
      default:
        return const [
          PopupMenuItem(value: 'settings', child: Text('Settings')),
        ];
    }
  }

  Widget _buildFilterChip(String label, {int? count}) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count != null && count > 0 ? '$label ($count)' : label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? AppTheme.primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddListButton() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New list feature coming soon')),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text('New list', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
  List<ChatItem> _getFilteredChats(List<ChatItem> chats) {
    final listProvider = Provider.of<CommunityListProvider>(context, listen: false);
    final chatProvider = Provider.of<chat.ChatProvider>(context, listen: false);
    
    print('=== FILTER: $_selectedFilter ===');
    
    switch (_selectedFilter) {
      case 'Unread':
        final unreadChats = chats.where((c) => c.unread > 0).toList();
        print('Unread filter: Found ${unreadChats.length} chats with unread messages');
        for (var chat in unreadChats) {
          print('  - ${chat.name}: ${chat.unread} unread');
        }
        return unreadChats;
      case 'Favorites':
        final favoriteCommunities = listProvider.getCommunitiesByList('Favorite');
        return chats.where((c) => favoriteCommunities.contains(c.name)).toList();
      case 'Commnunities':
        return chats.where((c) {
          final actualChat = chatProvider.chats.firstWhere((chat) => chat.name == c.name, orElse: () => Chat(id: '', name: '', lastMessage: '', lastMessageTime: DateTime.now(), receiverUserId: ''));
          return actualChat.isGroup;
        }).toList();
      case 'Follow Up':
        final followUpCommunities = listProvider.getCommunitiesByList('Follow Up');
        return chats.where((c) => followUpCommunities.contains(c.name)).toList();
      case 'Lead':
        final leadCommunities = listProvider.getCommunitiesByList('Lead');
        return chats.where((c) => leadCommunities.contains(c.name)).toList();
      default:
        return chats;
    }
  }

  Widget _buildChatsTab(List<ChatItem> chats) {
    final chatProvider = Provider.of<chat.ChatProvider>(context);
    final archivedProvider = Provider.of<ArchivedProvider>(context);
    final archivedCount = chatProvider.chats.where((c) => archivedProvider.isArchived(c.id)).length;
    
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchivedChatsScreen())),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.archive_outlined, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Archived', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text(
                        '$archivedCount',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
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
                      Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      Text('Tap to start conversation', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (_, i) {
                    final chatItem = chats[i];
                    final actualChat = chatProvider.chats.firstWhere((c) => c.name == chatItem.name);
                    return InkWell(
                      onTap: () => _openChat(context, chatItem),
                      onLongPress: () => _showChatOptions(context, actualChat.id, chatItem.name),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            if (actualChat.profileImage != null && actualChat.profileImage!.isNotEmpty) {
                              _showProfileImage(context, actualChat.profileImage!, chatItem.name);
                            }
                          },
                          child: actualChat.profileImage != null && actualChat.profileImage!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundColor: chatItem.avatarColor,
                                  child: ClipOval(
                                    child: Image.network(
                                      actualChat.profileImage!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text(chatItem.initials),
                                    ),
                                  ),
                                )
                              : CircleAvatar(backgroundColor: chatItem.avatarColor, child: Text(chatItem.initials)),
                        ),
                        title: Text(chatItem.name, style: TextStyle(fontWeight: chatItem.unread > 0 ? FontWeight.bold : FontWeight.normal)),
                        subtitle: Text(chatItem.preview, maxLines: 1, style: TextStyle(fontWeight: chatItem.unread > 0 ? FontWeight.w500 : FontWeight.normal)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(chatItem.time, style: TextStyle(fontSize: 12, color: chatItem.unread > 0 ? AppTheme.primaryColor : Colors.grey)),
                            if (chatItem.unread > 0) ...[
                              const SizedBox(height: 4),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text('${chatItem.unread}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCommunitiesTab() => const CommunitiesScreen();

  Widget _buildStatusTab() {
    final statusProvider = Provider.of<StatusProvider>(context);
    return Container(
      color: Colors.grey[50],
      child: ListView(
        children: [
          _buildMyStatus(),
          if (statusProvider.statuses.isNotEmpty) ...[
            const Divider(height: 8, thickness: 8, color: Color(0xFFF0F0F0)),
            _buildRecentUpdates(statusProvider),
          ],
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

  Widget _buildRecentUpdates(StatusProvider statusProvider) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Recent updates', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          ...statusProvider.statuses.map((status) => _buildStatusTile(
            status.userName,
            statusProvider.getTimeAgo(status.timestamp),
            status.imagePath,
          )),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String name, String time, String imagePath) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundImage: FileImage(File(imagePath)),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusViewScreen(
              userName: name,
              imagePath: imagePath,
            ),
          ),
        );
      },
    );
  }

  void _showProfileImage(BuildContext context, String imageUrl, String name) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InteractiveViewer(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.message, AppTheme.primaryColor, () => Navigator.pop(context)),
                    _buildActionButton(Icons.call, AppTheme.primaryColor, () {
                      Navigator.pop(context);
                      CallService.makeCall(context, 'receiver_user_id', CallType.audio);
                    }),
                    _buildActionButton(Icons.videocam, AppTheme.primaryColor, () {
                      Navigator.pop(context);
                      CallService.makeCall(context, 'receiver_user_id', CallType.video);
                    }),
                    _buildActionButton(Icons.info_outline, AppTheme.primaryColor, () => Navigator.pop(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, [VoidCallback? onPressed]) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Icon(icon, color: color, size: 28),
    );
  }

  void _openChat(BuildContext context, ChatItem item) {
    final chatProvider = Provider.of<chat.ChatProvider>(context, listen: false);
    Chat existingChat;
    try {
      existingChat = chatProvider.chats.firstWhere((c) => c.name == item.name);
    } catch (e) {
      final localId = 'local_${item.name.toLowerCase().replaceAll(' ', '_')}';
      existingChat = Chat(
        id: localId,
        name: item.name,
        lastMessage: item.preview,
        lastMessageTime: DateTime.now(),
        receiverUserId: localId,
      );
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: existingChat as dynamic)));
  }

  void _showChatOptions(BuildContext context, String chatId, String chatName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive chat'),
              onTap: () async {
                Navigator.pop(context);
                await Provider.of<ArchivedProvider>(context, listen: false).archiveChat(chatId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$chatName archived')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String value) {
    final routes = {
      'settings': const SettingsScreen(),
      'new_group': const NewGroupScreen(),
      'new_community': const NewCommunityScreen(),
      'broadcast_list': const BroadcastListScreen(),
      'Linked Devices': const LinkedDevicesScreen(),
      'Starred': const StarredMessagesScreen(),
      'payments': const PaymentsScreen(),
      'schedule_call': const ScheduleCallScreen(),
    };
    
    if (routes.containsKey(value)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => routes[value]!));
    } else if (value == 'clear_call_log') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clear call log feature coming soon')),
      );
    }
  }
final ImagePicker _picker = ImagePicker();

void _pickMediaForStatus(BuildContext context) async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  
  if (image != null) {
    Provider.of<StatusProvider>(context, listen: false).addStatus(image.path);
    _tabController.animateTo(3);  }
}

 
}
