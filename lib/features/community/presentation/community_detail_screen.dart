import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/community_model.dart';
import '../data/datasources/community_datasource.dart';
import '../../groups/data/models/group_model.dart';
import '../../chat/data/models/chat_model.dart';
import '../../chat/presentation/widgets/chat_screen2/chat_screen.dart';
import 'new_group_in_community_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
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
      final groups = await _dataSource.fetchGroupsByCommunity(widget.community.id);
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading groups: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showLinkGroupDialog() async {
    final allGroups = await _dataSource.fetchAllGroups();
    final availableGroups = allGroups.where((g) => g.communityId == null).toList();

    if (!mounted) return;

    if (availableGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No groups available to link')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Existing Group'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableGroups.length,
            itemBuilder: (context, index) {
              final group = availableGroups[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(group.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(group.name),
                subtitle: Text('${group.memberCount} members'),
                onTap: () async {
                  Navigator.pop(context);
                  await _linkGroup(group.id);
                },
              );
            },
          ),
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

  Future<void> _linkGroup(String groupId) async {
    try {
      await Supabase.instance.client.from('groups').update({
        'community_id': widget.community.id,
      }).eq('id', groupId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group linked successfully!'), backgroundColor: Colors.green),
        );
        _loadGroups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        title: Text(widget.community.name),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.community.icon ?? widget.community.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.community.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.community.memberCount} members',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (widget.community.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.community.description!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.groups, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Groups (${_groups.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _groups.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No groups yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                              const SizedBox(height: 8),
                              Text('Tap + to create or link icon to link', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _groups.length,
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              backgroundImage: group.avatarUrl != null ? NetworkImage(group.avatarUrl!) : null,
                              child: group.avatarUrl == null
                                  ? Text(group.name[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                                  : null,
                            ),
                            title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text('${group.memberCount} members'),
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
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'link_group',
            mini: true,
            backgroundColor: Colors.grey[700],
            onPressed: _showLinkGroupDialog,
            child: const Icon(Icons.link, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'new_group',
            backgroundColor: AppTheme.primaryColor,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewGroupInCommunityScreen(
                    communityId: widget.community.id,
                    communityName: widget.community.name,
                  ),
                ),
              );
              if (result == true) _loadGroups();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
