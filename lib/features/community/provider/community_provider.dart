import 'package:flutter/material.dart';
import '../domain/community_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class CommunityProvider extends ChangeNotifier {
  CommunityProvider() {
    _loadGroups();
  }

  CommunityType? _selectedCommunity;
  List<Member> _members = [];
  bool _isLoading = false;
  int _memberCount = 1234;

  CommunityType? get selectedCommunity => _selectedCommunity;
  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  int get memberCount => _memberCount;

  final List<ChatItem> _chats = [];

  List<ChatItem> get chats => _chats;

  void selectCommunity(CommunityType type) {
    _selectedCommunity = type;
    notifyListeners();
    loadMembers();
  }

  void loadMembers() {
    _isLoading = true;
    notifyListeners();
    
    _members = [
      Member(
        id: '1',
        name: 'John Doe',
        role: 'Admin',
        avatar: 'JD',
        isOnline: true,
      ),
      Member(
        id: '2',
        name: 'Jane Smith',
        role: 'Moderator',
        avatar: 'JS',
        isOnline: false,
      ),
      Member(
        id: '3',
        name: 'Mike Wilson',
        role: 'Member',
        avatar: 'MW',
        isOnline: true,
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  void updateMemberCount(int count) {
    _memberCount = count;
    notifyListeners();
  }

  Future<void> loadContacts() async {
    try {
      if (await Permission.contacts.request().isGranted) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        _chats.clear();
        
        for (var contact in contacts) {
          if (contact.displayName.isNotEmpty) {
            final initials = contact.displayName
                .split(' ')
                .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                .take(2)
                .join();
            
            _chats.add(ChatItem(
              initials: initials.isEmpty ? 'U' : initials,
              name: contact.displayName,
              preview: 'Tap to start conversation',
              time: '',
              unread: 0,
              avatarColor: _getRandomColor(),
            ));
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }
  
  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      const Color(0xFFE67E22),
      Colors.purple,
      Colors.teal,
    ];
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }

  void addMember(String name, String email) {
    final newMember = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: 'Member',
      avatar: name.isNotEmpty ? name[0].toUpperCase() : 'U',
      isOnline: false,
    );
    
    _members.add(newMember);
    _memberCount++;
    notifyListeners();
  }

  void createGroup(String groupName, List<String> memberNames) async {
    final initials = groupName.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();
    final newChat = ChatItem(
      initials: initials.isEmpty ? 'G' : initials,
      name: groupName,
      preview: 'Group created',
      time: 'Just now',
      unread: 0,
      avatarColor: Colors.blue,
      members: memberNames,
    );
    _chats.insert(0, newChat);
    await _saveGroups();
    notifyListeners();
  }

  List<String> getGroupMembers(String groupName) {
    final chat = _chats.firstWhere((c) => c.name == groupName, orElse: () => _chats.first);
    return chat.members ?? [];
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groups = _chats.where((c) => c.members != null).map((c) => {
      'name': c.name,
      'members': c.members,
      'initials': c.initials,
    }).toList();
    await prefs.setString('saved_groups', jsonEncode(groups));
  }

  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_groups');
    if (saved != null) {
      final List<dynamic> groups = jsonDecode(saved);
      for (var g in groups) {
        _chats.insert(0, ChatItem(
          initials: g['initials'],
          name: g['name'],
          preview: 'Group created',
          time: 'Just now',
          unread: 0,
          avatarColor: Colors.blue,
          members: List<String>.from(g['members']),
        ));
      }
    }
    notifyListeners();
  }

  void updateContactName(String oldName, String newName) {
    final index = _chats.indexWhere((chat) => chat.name == oldName);
    if (index != -1) {
      final oldChat = _chats[index];
      _chats[index] = ChatItem(
        initials: newName.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join(),
        name: newName,
        preview: oldChat.preview,
        time: oldChat.time,
        unread: oldChat.unread,
        avatarColor: oldChat.avatarColor,
        members: oldChat.members,
      );
      notifyListeners();
      print('Updated contact name from $oldName to $newName in CommunityProvider');
    }
  }
}

class Member {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final bool isOnline;

  Member({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    this.isOnline = false,
  });
}

class ChatItem {
  final String initials;
  final String name;
  final String preview;
  final String time;
  final int unread;
  final Color avatarColor;
  final List<String>? members;

  const ChatItem({
    required this.initials,
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.avatarColor,
    this.members,
  });
}