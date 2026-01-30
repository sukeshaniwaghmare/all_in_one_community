import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../models/contact_model.dart';
import '../../chat/provider/chat_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ContactProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  ChatProvider? _chatProvider;
  bool _isOnline = true;

  ContactProvider() {
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  bool get isOnline => _isOnline;

  List<Contact> get contacts => _searchQuery.isEmpty
      ? _contacts
      : _contacts
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.phoneNumber.contains(_searchQuery))
          .toList();

  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasPermission = await fc.FlutterContacts.requestPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final phoneContacts = await fc.FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
        withThumbnail: false,
      );

      _contacts = phoneContacts.map((c) => Contact.fromFlutter(c)).toList();

    } catch (e) {
      debugPrint('Error loading contacts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> inviteContact(Contact contact) async {
    debugPrint('Invited ${contact.name} (${contact.phoneNumber})');
    
    // Create a chat room for the invited contact
    if (_chatProvider != null) {
      final contactId = _generateContactId(contact.phoneNumber);
      await _chatProvider!.createDirectChatWithPhone(
        contactId,
        contact.name,
        contact.phoneNumber,
      );
    }
  }

  Future<void> inviteAllContacts() async {
    for (final c in _contacts.where((c) => !c.isAppUser)) {
      await inviteContact(c);
    }
  }

  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }

  Future<void> startChat(Contact contact) async {
    debugPrint('Starting chat with ${contact.name}');
    
    if (_chatProvider != null) {
      final contactId = _generateContactId(contact.phoneNumber);
      await _chatProvider!.createDirectChatWithPhone(
        contactId,
        contact.name,
        contact.phoneNumber,
      );
    }
  }

  String _generateContactId(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    const uuid = Uuid();
    return uuid.v5(Uuid.NAMESPACE_OID, cleanPhone);
  }
}
