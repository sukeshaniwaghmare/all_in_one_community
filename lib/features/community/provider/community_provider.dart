import 'package:flutter/material.dart';
import '../domain/community_type.dart';
import '../domain/entities/member_entity.dart';
import '../domain/entities/chat_entity.dart';
import '../data/repositories/community_repository_impl.dart';
import '../data/datasources/community_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityRepositoryImpl _repository;
  
  CommunityProvider(this._repository) {
    _loadGroups();
    _loadFavorites();
  }

  CommunityType? _selectedCommunity;
  List<MemberEntity> _members = [];
  bool _isLoading = false;
  int _memberCount = 0;
  Set<String> _favoriteCommunities = {};

  CommunityType? get selectedCommunity => _selectedCommunity;
  List<MemberEntity> get members => _members;
  bool get isLoading => _isLoading;
  int get memberCount => _memberCount;
  Set<String> get favoriteCommunities => _favoriteCommunities;

  final List<ChatEntity> _chats = [];

  List<ChatEntity> get chats => _chats;

  void selectCommunity(CommunityType type) {
    _selectedCommunity = type;
    notifyListeners();
    loadMembers();
  }

  Future<void> loadMembers() async {
    _isLoading = true;
    notifyListeners();
    
    _members = await _repository.getMembers();
    _memberCount = await _repository.getMemberCount();
    
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
            
            _chats.add(ChatEntity(
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
    final newMember = MemberEntity(
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
    final newChat = ChatEntity(
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
    final chat = _chats.firstWhere((c) => c.name == groupName, orElse: () => const ChatEntity(initials: '', name: '', preview: '', time: '', unread: 0, avatarColor: Colors.grey));
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
        _chats.insert(0, ChatEntity(
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
      _chats[index] = ChatEntity(
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

  // -------------------- FAVORITES --------------------

  bool isFavorite(String communityName) => _favoriteCommunities.contains(communityName);

  Future<void> toggleFavorite(String communityName) async {
    if (_favoriteCommunities.contains(communityName)) {
      _favoriteCommunities.remove(communityName);
    } else {
      _favoriteCommunities.add(communityName);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('favorite_communities');
    if (json != null) {
      _favoriteCommunities = Set<String>.from(jsonDecode(json));
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_communities', jsonEncode(_favoriteCommunities.toList()));
  }
}