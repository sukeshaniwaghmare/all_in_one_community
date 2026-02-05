import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../../../community/provider/community_provider.dart';
import '../../../../provider/chat_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

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
      if (await Permission.contacts.request().isGranted) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          _allMembers = contacts
              .where((contact) => contact.displayName.isNotEmpty)
              .map((contact) {
            final initials = contact.displayName
                .split(' ')
                .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                .take(2)
                .join();
            return Member(
              name: contact.displayName,
              avatar: initials.isEmpty ? 'U' : initials,
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (_selectedMembers.isNotEmpty) _selectedMembersChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allMembers.isEmpty
                    ? const Center(child: Text('No contacts found'))
                    : ListView.builder(
                        itemCount: _allMembers.length,
                        itemBuilder: (context, index) {
                          final member = _allMembers[index];
                          final isSelected = _selectedMembers.contains(member);
                          return CheckboxListTile(
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
                            secondary: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(member.avatar, style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(member.name),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedMembers.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsScreen(selectedMembers: _selectedMembers),
                  ),
                );
              },
              child: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }

  Widget _selectedMembersChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMembers.length,
        itemBuilder: (context, index) {
          final member = _selectedMembers[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(member.avatar, style: const TextStyle(color: Colors.white)),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMembers.remove(member);
                          });
                        },
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(member.name.split(' ')[0], style: const TextStyle(fontSize: 10)),
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFDADADA),
                  child: Icon(Icons.group, size: 50, color: Colors.white),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                hintText: 'Group name',
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Members: ${widget.selectedMembers.length}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () async {
          if (_groupNameController.text.trim().isNotEmpty) {
            final groupName = _groupNameController.text.trim();
            final memberIds = widget.selectedMembers.map((m) => m.name).toList(); // In real app, use user IDs
            
            // Create group using real-time service
            await context.read<ChatProvider>().createGroup(groupName, memberIds);
            
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Group "$groupName" created!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class Member {
  final String name;
  final String avatar;

  Member({required this.name, required this.avatar});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
