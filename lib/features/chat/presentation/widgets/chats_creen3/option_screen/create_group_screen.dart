import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../../provider/chat_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateGroupScreen extends StatefulWidget {
  final String? preSelectedContact;
  
  const CreateGroupScreen({super.key, this.preSelectedContact});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Member> _selectedMembers = [];
  List<Member> _allMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('id, full_name, avatar_url')
          .neq('id', currentUserId ?? '')
          .order('full_name');

      setState(() {
        _allMembers = (response as List).map((user) {
          final name = user['full_name'] ?? 'User';
          final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();
          return Member(
            id: user['id'] ?? '',
            name: name,
            avatar: initials.isEmpty ? 'U' : initials,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add group members', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('${_selectedMembers.length} of ${_allMembers.length} selected', 
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedMembers.isNotEmpty) _selectedMembersChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allMembers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.contacts_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No contacts found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _allMembers.length,
                        itemBuilder: (context, index) {
                          final member = _allMembers[index];
                          final isSelected = _selectedMembers.contains(member);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedMembers.remove(member);
                                } else {
                                  _selectedMembers.add(member);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    child: Text(member.avatar, 
                                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(member.name, 
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  ),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedMembers.add(member);
                                        } else {
                                          _selectedMembers.remove(member);
                                        }
                                      });
                                    },
                                    activeColor: AppTheme.primaryColor,
                                    shape: const CircleBorder(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedMembers.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              elevation: 4,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsScreen(selectedMembers: _selectedMembers),
                  ),
                );
              },
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
    );
  }

  Widget _selectedMembersChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMembers.length,
        itemBuilder: (context, index) {
          final member = _selectedMembers[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(member.avatar, 
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMembers.remove(member);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 56,
                  child: Text(
                    member.name.split(' ')[0],
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GroupDetailsScreen extends StatefulWidget {
  final List<Member> selectedMembers;

  const GroupDetailsScreen({super.key, required this.selectedMembers});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Group', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.group, size: 60, color: Colors.grey[400]),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _groupNameController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Group name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.people, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Participants: ${widget.selectedMembers.length}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.selectedMembers.length,
              itemBuilder: (context, index) {
                final member = widget.selectedMembers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(member.avatar, 
                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                  title: Text(member.name, style: const TextStyle(fontSize: 16)),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        onPressed: () async {
          if (_groupNameController.text.trim().isNotEmpty) {
            final groupName = _groupNameController.text.trim();
            final memberIds = widget.selectedMembers.map((m) => m.id).toList();
            
            await context.read<ChatProvider>().createGroup(groupName, memberIds);
            await context.read<ChatProvider>().loadChats();
            
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Group "$groupName" created!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

class Member {
  final String id;
  final String name;
  final String avatar;

  Member({required this.id, required this.name, required this.avatar});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
