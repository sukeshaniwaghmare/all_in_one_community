import 'package:all_in_one_community/features/community/presentation/member_options_bottom_sheet.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../chat/presentation/widgets/chat_screen2/option_screen/media_screen.dart';
import '../../notifications/presentation/notification_screen.dart';
import '../../chat/presentation/widgets/chats_creen3/option_screen/disappearing_messages_screen_infoscreen.dart';
import '../../chat/presentation/widgets/chats_creen3/option_screen/advanced_chat_privacy_screen_infoscreen .dart';
import 'role_selection_dialog.dart';

class CommunityInfoScreen extends StatefulWidget {
  final String name;
  final int memberCount;
  final String? groupId;
  final String? description;

  const CommunityInfoScreen({
    super.key,
    required this.name,
    required this.memberCount,
    this.groupId,
    this.description,
  });

  @override
  State<CommunityInfoScreen> createState() => _CommunityInfoScreenState();
}

class _CommunityInfoScreenState extends State<CommunityInfoScreen> {
  bool _isFavorite = false;
  String? _avatarUrl;
  bool _isAdmin = false;
  bool _isChatLocked = false;
  late String _groupName;

  @override
  void initState() {
    super.initState();
    _groupName = widget.name;
    _loadGroupAvatar();
  }

  Future<void> _loadGroupAvatar() async {
  
    
    if (widget.groupId != null) {
      try {
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        
        final groupData = await Supabase.instance.client
            .from('groups')
            .select('avatar_url, created_by')
            .eq('id', widget.groupId!)
            .single();
        
   
        
        if (mounted) {
          setState(() {
            _avatarUrl = groupData['avatar_url'];
            _isAdmin = groupData['created_by'] == currentUserId;
          });
        }
      } catch (e) {
      }
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _groupName,
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
            onSelected: (value) {
              if (value == 'add_members') _addMembers();
              else if (value == 'change_name') _changeGroupName();
              else if (value == 'group_permission') _groupPermission();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_members',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Add members'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'change_name',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Change group name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'group_permission',
                child: Row(
                  children: [
                    Icon(Icons.security),
                    SizedBox(width: 8),
                    Text('Group permission'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _header(),
          const SizedBox(height: 8),
          _description(),
          const SizedBox(height: 8),
          _settings(),
          const SizedBox(height: 8),
          _membersSection(),
          const SizedBox(height: 8),
          _groupActions(),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFDADADA),
            backgroundImage: (_avatarUrl != null && _avatarUrl!.startsWith('http'))
                ? NetworkImage(_avatarUrl!)
                : null,
            child: (_avatarUrl == null || !_avatarUrl!.startsWith('http'))
                ? const Icon(Icons.group, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            _groupName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Community · ${widget.memberCount} members',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _description() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.description ?? 'No description available',
        style: TextStyle(
          color: widget.description == null ? Colors.grey : Colors.black87,
        ),
      ),
    );
  }

  Widget _membersSection() {
    if (widget.groupId == null) return const SizedBox.shrink();
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchGroupMembers(widget.groupId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        final members = snapshot.data!;
        
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                title: Text('${members.length} members'),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'add_members') _addMembers();
                    else if (value == 'change_name') _changeGroupName();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_members',
                      child: Row(
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(width: 8),
                          Text('Add members'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'change_name',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Change group name'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.person_add, color: Colors.white, size: 20),
                ),
                title: const Text(
                  'Add members',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: _addMembers,
              ),
              const Divider(height: 1),
              ...members.map((member) => _memberTile(member)),
            ],
          ),
        );
      },
    );
  }

  Widget _memberTile(Map<String, dynamic> member) {
    final fullName = member['full_name'] ?? 'Unknown';
    final avatarUrl = member['avatar_url'];
    final bio = member['bio'] ?? 'Hey there!';
    final role = member['role'] ?? 'member';
    final roleDesc = member['role_description'] ?? '';
    final isAdmin = member['is_admin'] ?? false;
    final isCurrentUser = member['is_current_user'] ?? false;
    final isCreator = member['is_creator'] ?? false;
    
    String subtitle;
    String? description;
    Color subtitleColor;
    
    if (isAdmin) {
      subtitle = 'Group admin';
      description = roleDesc.isNotEmpty ? roleDesc : null;
      subtitleColor = const Color(0xFF128C7E);
    } else if (role != 'member' && role.isNotEmpty) {
      subtitle = role;
      description = roleDesc.isNotEmpty ? roleDesc : null;
      subtitleColor = const Color(0xFF128C7E);
    } else {
      subtitle = bio;
      description = null;
      subtitleColor = Colors.grey;
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDADADA),
        backgroundImage: (avatarUrl != null && avatarUrl.startsWith('http')) 
            ? NetworkImage(avatarUrl) 
            : null,
        child: (avatarUrl == null || !avatarUrl.startsWith('http')) 
            ? const Icon(Icons.person, color: Colors.white, size: 20) 
            : null,
      ),
      title: Text(isCurrentUser ? 'You' : fullName),
      subtitle: Row(
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor, 
              fontSize: 12
            ),
          ),
          if (description != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(subtitle),
                    content: Text(description!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.info_outline, color: Colors.blue, size: 16),
            ),
          ],
        ],
      ),
      onTap: _isAdmin && !isCurrentUser ? () {
        MemberOptionsBottomSheet.show(
          context,
          memberName: fullName,
          phoneNumber: member['phone'],
          avatarUrl: avatarUrl,
          isAdmin: isAdmin,
          isCurrentUser: isCurrentUser,
          groupId: widget.groupId,
          memberId: member['user_id'],
          onRoleUpdate: (role) async {
            try {
              print('DEBUG: Starting role update');
              print('DEBUG: Group ID: ${widget.groupId}');
              print('DEBUG: Member ID: ${member['user_id']}');
              print('DEBUG: New Role: $role');
              
              final checkExists = await Supabase.instance.client
                  .from('group_members')
                  .select()
                  .eq('group_id', widget.groupId!)
                  .eq('user_id', member['user_id']);
              
              print('DEBUG: Existing record: $checkExists');
              
              if (checkExists.isEmpty) {
                print('DEBUG: No record found, inserting new one');
                final insertResult = await Supabase.instance.client
                    .from('group_members')
                    .insert({
                      'group_id': widget.groupId!,
                      'user_id': member['user_id'],
                      'role': role,
                    })
                    .select();
                print('DEBUG: Insert result: $insertResult');
              } else {
                print('DEBUG: Record exists, updating by ID');
                final recordId = checkExists[0]['id'];
                print('DEBUG: Record ID: $recordId');
                final updateResult = await Supabase.instance.client
                    .from('group_members')
                    .update({'role': role})
                    .eq('id', recordId)
                    .select();
                print('DEBUG: Update result: $updateResult');
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$fullName role updated to $role')),
              );
              setState(() {});
            } catch (e) {
              print('DEBUG: Error updating role: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update role: $e')),
              );
            }
          },
          onMessage: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Message $fullName')),
            );
          },
          onAudioCall: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Audio call $fullName')),
            );
          },
          onVideoCall: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Video call $fullName')),
            );
          },
          onPay: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pay $fullName')),
            );
          },
          onInfo: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('View $fullName info')),
            );
          },
          onVerifySecurityCode: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verify security code')),
            );
          },
          onMakeAdmin: !isAdmin ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$fullName is now an admin')),
            );
            setState(() {});
          } : null,
          onDismissAdmin: isAdmin ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$fullName dismissed as admin')),
            );
            setState(() {});
          } : null,
          onAddOtherRole: () async {
            final selectedRoles = await RoleSelectionDialog.show(
              context,
              memberName: fullName,
              currentRoles: [],
            );
            if (selectedRoles != null && selectedRoles.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Roles assigned to $fullName: ${selectedRoles.join(", ")}'),
                ),
              );
            }
          },
          onRemoveMember: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Remove $fullName?'),
                content: const Text('This member will be removed from the group.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$fullName removed from group')),
                      );
                      setState(() {});
                    },
                    child: const Text('Remove', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        );
      } : null,
    );
  }

  Widget _settings() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _SettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'All',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.image,
            title: 'Media visibility',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaScreen(chatName: widget.name, receiverUserId: widget.groupId ?? ''))),
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.lock,
            title: 'Encryption',
            subtitle: 'Messages and calls are end-to-end encrypted.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End-to-end encryption info'))),
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.timer,
            title: 'Disappearing messages',
            subtitle: 'Off',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DisappearingMessagesScreen())),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline, color: Colors.grey),
            title: const Text('Chat lock'),
            subtitle: const Text('Lock and hide this chat on this device'),
            value: _isChatLocked,
            onChanged: (value) => setState(() => _isChatLocked = value),
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.shield_outlined,
            title: 'Advanced chat privacy',
            subtitle: 'Off',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedChatPrivacyScreen())),
          ),
        ],
      ),
    );
  }

  Widget _groupActions() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _SettingTile(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            title: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            iconColor: _isFavorite ? Colors.red : null,
            onTap: _toggleFavorite,
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.playlist_add,
            title: 'Add to list',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add to list'))),
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.delete_outline,
            title: 'Clear chat',
            onTap: _clearChat,
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.exit_to_app,
            title: 'Exit community',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: _exitCommunity,
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.report,
            title: 'Report Community',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: _reportCommunity,
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchGroupMembers(String groupId) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      
      final Map<String, String> roleDescriptions = {
        'admin': 'Can manage members and settings',
        'owner': 'Full control over the group',
        'moderator': 'Can moderate content and messages',
        'member': '',
        'read-only': 'Can only view messages',
      };
      
      final response = await Supabase.instance.client
          .from('group_members')
          .select('user_id, role')
          .eq('group_id', groupId);
      
      final List<Map<String, dynamic>> membersWithProfiles = [];
      
      for (var member in response) {
        final userId = member['user_id'];
        final role = member['role'] ?? 'member';
        final roleDesc = roleDescriptions[role.toLowerCase()] ?? '';
        final profile = await Supabase.instance.client
            .from('user_profiles')
            .select('full_name, avatar_url, bio')
            .eq('id', userId)
            .maybeSingle();
        
        if (profile != null) {
          final groupData = await Supabase.instance.client
              .from('groups')
              .select('created_by')
              .eq('id', groupId)
              .single();
          
          final isCreator = groupData['created_by'] == userId;
          final isAdmin = role == 'admin' || isCreator;
          
          membersWithProfiles.add({
            'user_id': userId,
            'full_name': profile['full_name'],
            'avatar_url': profile['avatar_url'],
            'bio': profile['bio'],
            'role': role,
            'role_description': roleDesc,
            'is_admin': isAdmin,
            'is_creator': isCreator,
            'is_current_user': userId == currentUserId,
          });
        }
      }
      
      membersWithProfiles.sort((a, b) {
        if (a['is_current_user']) return -1;
        if (b['is_current_user']) return 1;
        if (a['is_admin'] && !b['is_admin']) return -1;
        if (!a['is_admin'] && b['is_admin']) return 1;
        return 0;
      });
      
      return membersWithProfiles;
    } catch (e) {
      return [];
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
      ),
    );
  }

  void _clearChat() async {
    final dialogContext = context;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat'),
        content: Text('Clear all messages in ${widget.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL', style: TextStyle(color: AppTheme.primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('CLEAR', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
    
    if (result == true && mounted) {
      try {
        if (widget.groupId != null) {
          await Supabase.instance.client
              .from('group_messages')
              .delete()
              .eq('group_id', widget.groupId!);
          
          if (mounted) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(content: Text('Chat cleared')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text('Failed to clear chat: $e')),
          );
        }
      }
    }
  }

  void _exitCommunity() async {
    final dialogContext = context;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit group'),
        content: const Text('You will no longer receive messages from this group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXIT GROUP', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (result == true && mounted) {
      try {
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        if (currentUserId != null && widget.groupId != null) {
          await Supabase.instance.client
              .from('group_members')
              .delete()
              .eq('group_id', widget.groupId!)
              .eq('user_id', currentUserId);
          
          if (mounted) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(content: Text('You left the group')),
            );
            Navigator.pop(dialogContext);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text('Failed to exit group: $e')),
          );
        }
      }
    }
  }

  void _reportCommunity() async {
    final dialogContext = context;
    bool exitAndDelete = true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Report this group to Community?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The last 5 messages from this group will be forwarded to Community. If you exit this group and delete the chat, messages will only be removed from this device and your devices on the newer versions of Community.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text(
                'No one in this group will be notified.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: exitAndDelete,
                onChanged: (value) => setState(() => exitAndDelete = value ?? true),
                title: const Text('Exit group and delete chat'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF25D366),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Report',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && mounted) {
      if (exitAndDelete) {
        try {
          final currentUserId = Supabase.instance.client.auth.currentUser?.id;
          if (currentUserId != null && widget.groupId != null) {
            await Supabase.instance.client
                .from('group_members')
                .delete()
                .eq('group_id', widget.groupId!)
                .eq('user_id', currentUserId);
            
            if (mounted) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text('${widget.name} has been reported and you left the group'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(dialogContext);
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(content: Text('Failed to exit group: $e')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text('${widget.name} has been reported'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addMembers() async {
    try {
      final currentMembers = await _fetchGroupMembers(widget.groupId!);
      final currentMemberIds = currentMembers.map((m) => m['user_id']).toSet();
      
      final allUsers = await Supabase.instance.client
          .from('user_profiles')
          .select('id, full_name, avatar_url, bio');
      
      final availableUsers = allUsers.where((user) => !currentMemberIds.contains(user['id'])).toList();
      
      if (availableUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No users available to add')),
        );
        return;
      }
      
      final selectedUsers = await showDialog<List<Map<String, dynamic>>>(
        context: context,
        builder: (context) => _AddMembersDialog(users: availableUsers),
      );
      
      if (selectedUsers != null && selectedUsers.isNotEmpty) {
        for (var user in selectedUsers) {
          await Supabase.instance.client.from('group_members').insert({
            'group_id': widget.groupId!,
            'user_id': user['id'],
            'role': 'member',
          });
          
          await Supabase.instance.client.from('group_messages').insert({
            'group_id': widget.groupId!,
            'user_id': user['id'],
            'group_name': widget.name,
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedUsers.length} member(s) added successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add members: $e')),
      );
    }
  }

  void _changeGroupName() async {
    final TextEditingController nameController = TextEditingController(text: _groupName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Group Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter new group name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
           
              if (newName.isNotEmpty && widget.groupId != null) {
                Navigator.pop(context);
                try {
                  final result = await Supabase.instance.client
                      .from('groups')
                      .update({'name': newName})
                      .eq('id', widget.groupId!)
                      .select();
                  
                  
                  setState(() {
                    _groupName = newName;
                  });
                  
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Group name changed to "$newName"')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update name: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _groupPermission() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Permission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Send messages'),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
            ListTile(
              title: const Text('Edit group info'),
              trailing: Switch(value: false, onChanged: (v) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}

class _AddMembersDialog extends StatefulWidget {
  final List<Map<String, dynamic>> users;

  const _AddMembersDialog({required this.users});

  @override
  State<_AddMembersDialog> createState() => _AddMembersDialogState();
}

class _AddMembersDialogState extends State<_AddMembersDialog> {
  final Set<String> _selectedUserIds = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Members',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '${_selectedUserIds.length} selected',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.users.length,
                itemBuilder: (context, index) {
                  final user = widget.users[index];
                  final isSelected = _selectedUserIds.contains(user['id']);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedUserIds.add(user['id']);
                        } else {
                          _selectedUserIds.remove(user['id']);
                        }
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: const Color(0xFFDADADA),
                      backgroundImage: (user['avatar_url'] != null && user['avatar_url'].startsWith('http'))
                          ? NetworkImage(user['avatar_url'])
                          : null,
                      child: (user['avatar_url'] == null || !user['avatar_url'].startsWith('http'))
                          ? const Icon(Icons.person, color: Colors.white, size: 20)
                          : null,
                    ),
                    title: Text(user['full_name'] ?? 'Unknown'),
                    subtitle: Text(user['bio'] ?? 'Hey there!', style: const TextStyle(fontSize: 12)),
                    activeColor: AppTheme.primaryColor,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedUserIds.isEmpty
                        ? null
                        : () {
                            final selectedUsers = widget.users
                                .where((u) => _selectedUserIds.contains(u['id']))
                                .toList();
                            Navigator.pop(context, selectedUsers);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
