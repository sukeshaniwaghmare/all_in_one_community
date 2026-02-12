import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/datasources/community_datasource.dart';
import '../data/models/group_model.dart';
import '../../chat/data/models/chat_model.dart';
import '../../chat/presentation/widgets/chat_screen2/chat_screen.dart';
import 'community_info_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final _dataSource = CommunityDataSource();
  List<GroupModel> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      print('Fetching groups...');
      final groups = await _dataSource.fetchAllGroups();
      print('Groups fetched: ${groups.length}');
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading groups: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return ListView(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.groups, color: Colors.grey[600], size: 28),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          title: const Text('New community', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create new community')),
            );
          },
        ),
        const Divider(height: 1),
        if (_groups.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No groups found', style: TextStyle(color: Colors.grey))),
          )
        else
          ...List.generate(_groups.length, (index) {
            final group = _groups[index];
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: group.avatarUrl != null ? NetworkImage(group.avatarUrl!) : null,
                    child: group.avatarUrl == null
                        ? Text(group.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600))
                        : null,
                  ),
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subtitle: Text('${group.memberCount} members', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.grey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityInfoScreen(
                            name: group.name,
                            memberCount: group.memberCount,
                            groupId: group.id,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chat: Chat(
                            id: group.id,
                            name: group.name,
                            lastMessage: '',
                            lastMessageTime: DateTime.now(),
                            isGroup: true,
                            receiverUserId: group.id,
                            profileImage: group.avatarUrl,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (index < _groups.length - 1) const Divider(height: 1, indent: 72),
            ],
            );
          }),
      ],
    );
  }
  }
