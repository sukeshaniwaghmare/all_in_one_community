import '../../../../calls/services/call_service.dart';
import '../../../../calls/domain/entities/call.dart';
import 'package:all_in_one_community/features/chat/presentation/widgets/chats_creen3/edit_infoscreen_screen.dart';
import 'package:flutter/material.dart';
import 'option_screen/create_group_screen.dart';
import 'package:provider/provider.dart';
import '../../../../community/provider/community_provider.dart';
import '../../../provider/chat_provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/apptopbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../chat_screen2/option_screen/media_screen.dart';
import '../../../../notifications/presentation/notification_screen.dart';
import 'option_screen/disappearing_messages_screen_infoscreen.dart';
import 'option_screen/advanced_chat_privacy_screen_infoscreen .dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class InfoScreen extends StatefulWidget {
  final String name;
  final int memberCount;
  final bool isGroup;
  final String? groupId;
  final String? description;
  final String? createdBy;
  final String? createdDate;
  final String? receiverId;

  const InfoScreen({
    super.key,
    required this.name,
    required this.memberCount,
    this.isGroup = true,
    this.groupId,
    this.description,
    this.createdBy,
    this.createdDate,
    this.receiverId,
  });

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  bool _isChatLocked = false;
  bool _isFavorite = false;
  XFile? _profileImage;
  bool _isEditMode = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _currentName;
  late String? _currentDescription;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _currentName = widget.name;
    _currentDescription = widget.description;
    _nameController = TextEditingController(text: _currentName);
    _descriptionController = TextEditingController(text: _currentDescription ?? '');
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (!widget.isGroup) {
      try {
        final profile = await _fetchUserProfile(_currentName);
        if (profile != null && mounted) {
          setState(() {
            _avatarUrl = profile['avatar_url'];
          });
        }
      } catch (e) {}
    } else if (widget.groupId != null) {
      // Load group avatar
      try {
        final groupData = await Supabase.instance.client
            .from('groups')
            .select('avatar_url')
            .eq('id', widget.groupId!)
            .single();
        
        if (mounted) {
          final avatarUrl = groupData['avatar_url'];
          setState(() {
            _avatarUrl = avatarUrl;
          });
        }
      } catch (e) {
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isEditMode ? Icons.close : Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () {
            if (_isEditMode) {
              setState(() {
                _isEditMode = false;
                _nameController.text = widget.name;
                _descriptionController.text = widget.description ?? '';
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _isEditMode ? 'Edit Info' : _currentName,
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          else ...[
          IconButton(
            icon: Icon(Icons.call, color: AppTheme.primaryColor),
            onPressed: () {
              if (widget.receiverId != null) {
                CallService.makeCall(context, widget.receiverId!, CallType.audio);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: AppTheme.primaryColor),
            onPressed: () {
              if (widget.receiverId != null) {
                CallService.makeCall(context, widget.receiverId!, CallType.video);
              }
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _shareContact();
                  break;
                case 'edit':
                  _editContact();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              if (widget.isGroup)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'verify',
                child: Row(
                  children: [
                    Icon(Icons.security),
                    SizedBox(width: 8),
                    Text('Verify security code'),
                  ],
                ),
              ),
            ],
          ),
          ],
        ],
      ),
      body: ListView(
        children: [
          _header(),
          const SizedBox(height: 8),
          _actionButtons(),
          const SizedBox(height: 8),
          _description(),
          const SizedBox(height: 8),
          _settings(),
          const SizedBox(height: 8),
          if (!widget.isGroup) const SizedBox(height: 8),
          if (!widget.isGroup) _createGroupWith(),
          if (!widget.isGroup) const SizedBox(height: 8),
          if (!widget.isGroup) _commonGroups(),
          if (!widget.isGroup) const SizedBox(height: 8),
          if (!widget.isGroup) _contactActions(),
          if (!widget.isGroup) const SizedBox(height: 8),
          if (widget.isGroup) _membersSection(),
          if (widget.isGroup) const SizedBox(height: 8),
          if (widget.isGroup) _groupActions(),
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
          GestureDetector(
            onTap: () {
              if (_profileImage != null) {
                _showProfileImage(context, _profileImage!.path, _currentName, isLocal: true);
              } else if (_avatarUrl != null && _avatarUrl!.startsWith('http')) {
                _showProfileImage(context, _avatarUrl!, _currentName);
              }
            },
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFDADADA),
              backgroundImage: _profileImage != null 
                ? FileImage(File(_profileImage!.path))
                : (_avatarUrl != null && _avatarUrl!.startsWith('http'))
                  ? NetworkImage(_avatarUrl!)
                  : null,
              child: (_profileImage == null && (_avatarUrl == null || !_avatarUrl!.startsWith('http')))
                ? Icon(widget.isGroup ? Icons.group : Icons.person, size: 40, color: Colors.white) 
                : null,
            ),
          ),
          const SizedBox(height: 12),
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Group name',
                  border: UnderlineInputBorder(),
                ),
              ),
            )
          else
            Text(
              _currentName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 4),
          Text(
            widget.isGroup ? 'Group · ${widget.memberCount} members' : 'Contact',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionItem(Icons.call, 'Audio', onTap: () {
            if (widget.receiverId != null) {
              CallService.makeCall(context, widget.receiverId!, CallType.audio);
            }
          }),
          _ActionItem(Icons.videocam, 'Video', onTap: () {
            if (widget.receiverId != null) {
              CallService.makeCall(context, widget.receiverId!, CallType.video);
            }
          }),
          if (widget.isGroup) _ActionItem(Icons.person_add, 'Add', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add participant')))),
          _ActionItem(Icons.search, 'Search', onTap: _searchInChat),
        ],
      ),
    );
  }

  Widget _description() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditMode)
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add group description',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text(
              _currentDescription ?? 'Add group description',
              style: TextStyle(
                color: _currentDescription == null ? const Color(0xFF128C7E) : Colors.black87,
                fontWeight: _currentDescription == null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          if (widget.createdBy != null) ...[
            const SizedBox(height: 8),
            Text(
              'Created by ${widget.createdBy}, ${widget.createdDate ?? ''}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  //  Settings list
  Widget _settings() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _SettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'All',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MediaScreen(
                    chatName: widget.name,
                    receiverUserId: 'temp_user_id',
                  ),
                ),
              );
            },
            child: const _SettingTile(
              icon: Icons.image,
              title: 'Media visibility',
            ),
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.lock,
            title: 'Encryption',
            subtitle: 'Messages and calls are end-to-end encrypted. Tap to learn more.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End-to-end encryption info'))),
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.timer,
            title: 'Disappearing messages',
            subtitle: 'Off',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DisappearingMessagesScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline, color: Colors.grey),
            title: const Text('Chat lock'),
            subtitle: const Text('Lock and hide this chat on this device'),
            value: _isChatLocked,
            onChanged: (value) {
              setState(() {
                _isChatLocked = value;
              });
            },
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.shield_outlined,
            title: 'Advanced chat privacy',
            subtitle: 'Off',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdvancedChatPrivacyScreen(),
                ),
              );
            },
          ),
          if (widget.isGroup) ...[
            const Divider(height: 1),
           
          ],
        ],
      ),
    );
  }

  

  Widget _createGroupWith() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Create Group',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group_add, color: Color(0xFF128C7E)),
            title: Text('Create group with ${widget.name}'),
            subtitle: const Text('Start a new group conversation'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateGroupScreen(preSelectedContact: widget.name),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _commonGroups() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    
    final commonGroups = <String>{};
    
    // Check chat provider groups
    for (final chat in chatProvider.chats) {
      if (chat.isGroup) {
        final members = communityProvider.getGroupMembers(chat.name);
        if (members.contains(widget.name)) {
          commonGroups.add(chat.name);
        }
      }
    }
    
    // Check community provider groups
    for (final chat in communityProvider.chats) {
      if (chat.members != null && chat.members!.contains(widget.name)) {
        commonGroups.add(chat.name);
      }
    }
    
    if (commonGroups.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Groups in common',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          ...commonGroups.map((groupName) => ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFDADADA),
              child: Icon(Icons.group, color: Colors.white, size: 20),
            ),
            title: Text(groupName),
            subtitle: const Text('Tap to open'),
            onTap: () {
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  Widget _contactActions() {
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
            onTap: _showAddToListDialog,
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.block,
            title: 'Block',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: _blockContact,
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.report,
            title: 'Report',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: _reportContact,
          ),
        ],
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
                trailing: const Icon(Icons.search, color: Colors.grey),
              ),
              const Divider(height: 1),
              ...members.map((member) => _memberTileFromData(member)),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_add, color: Color(0xFF128C7E)),
                title: const Text('Add participant', style: TextStyle(color: Color(0xFF128C7E))),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add participant functionality'))),
              ),
            ],
          ),
        );
      },
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
            onTap: _showAddToListDialog,
          ),
          const Divider(height: 1),
        _SettingTile(
          icon: Icons.exit_to_app,
          title: 'Exit group',
          iconColor: Colors.red,
          titleColor: Colors.red,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit group?'),
                content: const Text('You will no longer receive messages from this group.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Left the group'), backgroundColor: Colors.red),
                      );
                    },
                    child: const Text('Exit', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        const Divider(height: 1),
        _SettingTile(
          icon: Icons.report,
          title: 'Report Group',
          iconColor: Colors.red,
          titleColor: Colors.red,
          onTap: _reportContact,
        ),
        const Divider(height: 1),
       
        
        ],
      ),
    );
  }

  Widget _memberTile(String name, {bool isAdmin = false}) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFDADADA),
        child: Icon(Icons.person, color: Colors.white, size: 20),
      ),
      title: Text(name),
      subtitle: Text(
        isAdmin ? 'Group admin' : 'Hey there!',
        style: TextStyle(color: isAdmin ? const Color(0xFF128C7E) : Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _memberTileFromData(Map<String, dynamic> member) {
    final fullName = member['full_name'] ?? 'Unknown';
    final avatarUrl = member['avatar_url'];
    final bio = member['bio'] ?? 'Hey there!';
    final isAdmin = member['is_admin'] ?? false;
    final isCurrentUser = member['is_current_user'] ?? false;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDADADA),
        backgroundImage: (avatarUrl != null && avatarUrl.startsWith('http')) ? NetworkImage(avatarUrl) : null,
        child: (avatarUrl == null || !avatarUrl.startsWith('http')) ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
      ),
      title: Text(isCurrentUser ? 'You' : fullName),
      subtitle: Text(
        isAdmin ? 'Group admin' : bio,
        style: TextStyle(color: isAdmin ? const Color(0xFF128C7E) : Colors.grey, fontSize: 12),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchGroupMembers(String groupId) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      
      final response = await Supabase.instance.client
          .from('group_members')
          .select('user_id')
          .eq('group_id', groupId);
      
      final List<Map<String, dynamic>> membersWithProfiles = [];
      
      for (var member in response) {
        final userId = member['user_id'];
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
          
          membersWithProfiles.add({
            'full_name': profile['full_name'],
            'avatar_url': profile['avatar_url'],
            'bio': profile['bio'],
            'is_admin': groupData['created_by'] == userId,
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

  Future<Map<String, dynamic>?> _fetchUserProfile(String fullName) async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('avatar_url, bio')
          .eq('full_name', fullName)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGroup();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteGroup() {
    Provider.of<ChatProvider>(context, listen: false).deleteGroup(widget.name);
    Navigator.pop(context);
  }

  void _editProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
        _saveProfileImage(pickedFile.path);
      }
    } catch (e) {}
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
        _saveProfileImage(pickedFile.path);
      }
    } catch (e) {}
  }

  void _shareContact() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.message, color: AppTheme.primaryColor),
              title: const Text('Send via Message'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact shared via message')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryColor),
              title: const Text('Send via Email'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact shared via email')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editContact() async {
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditInfoScreen(
            groupName: _currentName,
            description: _currentDescription,
            groupId: widget.groupId,
          ),
        ),
      );
      
      if (result != null && result is Map<String, String>) {
        final newName = result['name']!;
        final newDescription = result['description'];
        final groupId = result['groupId'];
        
        if (groupId != null) {
          // Reload group data from Supabase to get updated avatar
          final groupData = await Supabase.instance.client
              .from('groups')
              .select('name, avatar_url')
              .eq('id', groupId)
              .single();
          
          setState(() {
            _currentName = newName;
            _currentDescription = newDescription;
            _avatarUrl = groupData['avatar_url'];
            _nameController.text = newName;
            _descriptionController.text = newDescription ?? '';
          });
        }
        
        // Update in ChatProvider
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.updateContactName(_currentName, newName);
        
        // Update in CommunityProvider
        final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
        communityProvider.updateContactName(_currentName, newName);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group info updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating group')),
      );
    }
  }

 

  void _showProfileImage(BuildContext context, String imagePath, String name, {bool isLocal = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(name, style: const TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              child: isLocal ? Image.file(File(imagePath), fit: BoxFit.contain) : Image.network(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfileImage(String imagePath) {
    // Store locally - extend later to save to providers
  }

  void _searchInChat() {
    showSearch(
      context: context,
      delegate: ChatSearchDelegate(chatName: widget.name),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddToListDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Add to list',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No lists available'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _blockContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block ${widget.name}?'),
        content: Text('Blocked contacts will no longer be able to call you or send you messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.name} has been blocked'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _reportContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report ${widget.name}?'),
        content: const Text('This contact will be reported for inappropriate behavior. The last 5 messages will be forwarded to our team.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.name} has been reported'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final newName = _nameController.text.trim();
    final newDescription = _descriptionController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty')),
      );
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.updateContactName(widget.name, newName);

    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    communityProvider.updateContactName(widget.name, newName);

    setState(() {
      _isEditMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group info updated')),
    );

    Navigator.pop(context);
  }
}

// 🔹 Action button widget
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionItem(this.icon, this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF128C7E)),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}

// 🔹 Setting tile
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

// 🔹 Chat Search Delegate
class ChatSearchDelegate extends SearchDelegate<String> {
  final String chatName;

  ChatSearchDelegate({required this.chatName});

  @override
  String get searchFieldLabel => 'Search messages...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter text to search messages'),
      );
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messages = chatProvider.messages
        .where((message) => message.text.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (messages.isEmpty) {
      return const Center(
        child: Text('No messages found'),
      );
    }

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ListTile(
          title: Text(
            message.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${message.senderName} • ${_formatMessageTime(message.timestamp)}',
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            close(context, message.text);
          },
        );
      },
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
