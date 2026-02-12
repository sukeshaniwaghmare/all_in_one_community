import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../models/contact_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../chat/provider/chat_provider.dart' as chat;
import '../../chat/data/models/chat_model.dart' as chat;
import '../../chat/presentation/widgets/chat_screen2/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Contact> get contacts => _searchQuery.isEmpty
      ? _contacts
      : _contacts
          .where((contact) =>
              contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              contact.phoneNumber.contains(_searchQuery))
          .toList();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Load all phone contacts
  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final status = await Permission.contacts.status;
      if (status != PermissionStatus.granted) {
        final requestStatus = await Permission.contacts.request();
        if (requestStatus != PermissionStatus.granted) {
          debugPrint('Contacts permission denied');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      final hasPermission = await fc.FlutterContacts.requestPermission();
      if (!hasPermission) {
        debugPrint('Contacts permission denied');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch app users from Supabase
      final appUsers = await _fetchAppUsers();
      debugPrint('App users map has ${appUsers.length} entries');

      final phoneContacts = await fc.FlutterContacts.getContacts(
        withProperties: true,
        deduplicateProperties: true,
      );

      debugPrint('Found ${phoneContacts.length} contacts from device');

      final List<Contact> loadedContacts = [];
      final Set<String> uniqueContactIds = {};

      for (final c in phoneContacts) {
        if (c.phones.isEmpty) continue;

        final phoneObj = c.phones.first;
        String phone = _normalizePhone(phoneObj.number);
        if (phone.isEmpty) continue;

        final contactId = c.id;
        
        if (uniqueContactIds.contains(contactId)) continue;
        uniqueContactIds.add(contactId);

        // For now, mark all contacts as non-app users with invite button
        // You can later implement phone matching logic
        
        loadedContacts.add(Contact(
          id: contactId,
          name: c.displayName.isEmpty ? 'Unknown' : c.displayName,
          phoneNumber: phone,
          isAppUser: false,
          profileImage: null,
        ));
      }

      // Add all Supabase users as app users at the top
      for (var entry in appUsers.entries) {
        final userId = entry.key;
        final userData = entry.value;
        
        loadedContacts.insert(0, Contact(
          id: userId,
          name: userData['full_name'] ?? 'Unknown',
          phoneNumber: '',
          isAppUser: true,
          profileImage: userData['avatar_url'],
        ));
      }

      _contacts = loadedContacts;
      debugPrint('Loaded ${_contacts.length} unique contacts');

    } catch (e, stackTrace) {
      debugPrint('Error loading contacts: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, Map<String, dynamic>>> _fetchAppUsers() async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('id, full_name, avatar_url');
      
      debugPrint('Fetched ${response.length} app users from Supabase');
      
      final Map<String, Map<String, dynamic>> appUsersMap = {};
      for (var user in response) {
        final userId = user['id'];
        if (userId != null) {
          appUsersMap[userId] = user;
        }
      }
      return appUsersMap;
    } catch (e) {
      debugPrint('Error fetching app users: $e');
      return {};
    }
  }

  String _normalizePhone(String phone) {
    // Remove all non-digit characters except leading +
    String normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Handle country codes
    if (normalized.startsWith('+')) {
      // Keep as is if it starts with +
      return normalized;
    } else if (normalized.startsWith('0')) {
      // Remove leading 0
      normalized = normalized.substring(1);
    }
    
    // Add country code if needed (example for India)
    if (normalized.length == 10) {
      normalized = '+91$normalized';
    }
    
    return normalized;
  }

Future<void> inviteContact(Contact contact) async {
    try {
      await _sendSMS(contact.phoneNumber, 'Join our community app! Download now: [App Link]');
      debugPrint('Invited ${contact.name} (${contact.phoneNumber})');
      
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _contacts[index] = contact.copyWith(isAppUser: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error inviting contact: $e');
    }
  }

  Future<void> _sendSMS(String phoneNumber, String message) async {
    final uri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch SMS for $phoneNumber');
    }
  }

  Future<void> inviteAllContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final nonAppUsers = _contacts.where((c) => !c.isAppUser).toList();
      debugPrint('Inviting ${nonAppUsers.length} contacts');

      for (int i = 0; i < nonAppUsers.length; i++) {
        final contact = nonAppUsers[i];
        await inviteContact(contact);
        
        // Small delay to avoid overwhelming the system
        if (i % 10 == 0 && i > 0) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      debugPrint('Invited all ${nonAppUsers.length} contacts!');
    } catch (e) {
      debugPrint('Error inviting all contacts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startChat(Contact contact, BuildContext context) async {
    try {
      // Create chat object
      final newChat = chat.Chat(
        id: contact.id,
        name: contact.name,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        receiverUserId: contact.id,
        profileImage: contact.profileImage,
      );
      
      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chat: newChat as dynamic),
        ),
      );
    } catch (e) {
      debugPrint('Error starting chat: $e');
    }
  }
}