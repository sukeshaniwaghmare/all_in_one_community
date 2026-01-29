import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../models/contact_model.dart'; // Your own Contact model

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

      // Try getting all contacts without properties first to check count
      final hasPermission = await fc.FlutterContacts.requestPermission();
      if (!hasPermission) {
        debugPrint('Contacts permission denied');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get all contacts with properties
      final phoneContacts = await fc.FlutterContacts.getContacts(
        withProperties: true,
        deduplicateProperties: true,
      
      );

      debugPrint('Found ${phoneContacts.length} contacts from device');

      final List<Contact> loadedContacts = [];
      final Set<String> uniqueContactIds = {};

      for (final c in phoneContacts) {
        if (c.phones.isEmpty) continue;

        // Get primary phone or first available
        final phoneObj = c.phones.first;
        String phone = _normalizePhone(phoneObj.number);
        if (phone.isEmpty) continue;

        // Create a unique ID using contact ID
        final contactId = c.id;
        
        // Skip duplicates
        if (uniqueContactIds.contains(contactId)) continue;
        uniqueContactIds.add(contactId);

        loadedContacts.add(Contact(
          id: contactId,
          name: c.displayName.isEmpty ? 'Unknown' : c.displayName,
          phoneNumber: phone,
          isAppUser: _checkIfAppUser(phone),
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

  bool _checkIfAppUser(String phoneNumber) {
    // TODO: Replace with real logic checking app users
    // For now, check against a hardcoded list or implement API call
    return false;
  }

  Future<void> inviteContact(Contact contact) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('Invited ${contact.name} (${contact.phoneNumber})');
      
      // Update contact as app user (for demo purposes)
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _contacts[index] = contact.copyWith(isAppUser: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error inviting contact: $e');
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

  Future<void> startChat(Contact contact) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Starting chat with ${contact.name}');
    } catch (e) {
      debugPrint('Error starting chat: $e');
    }
  }
}