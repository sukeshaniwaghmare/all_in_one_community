import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../contacts/provider/contact_provider.dart';
import '../../contacts/models/contact_model.dart';
import '../../../core/theme/app_theme.dart';

class BroadcastListScreen extends StatefulWidget {
  const BroadcastListScreen({super.key});

  @override
  State<BroadcastListScreen> createState() => _BroadcastListScreenState();
}

class _BroadcastListScreenState extends State<BroadcastListScreen> {
  final List<String> _selectedContactIds = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppTheme.primaryColor),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<ContactProvider>().setSearchQuery(query);
                },
              )
            : const Text('New broadcast'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<ContactProvider>().setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            onPressed: _selectedContactIds.isNotEmpty ? _createBroadcast : null,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final appUsers = provider.contacts.where((c) => c.isAppUser).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: const Text(
                  'Only contacts with your number in their address book will receive your broadcast messages.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${_selectedContactIds.length} of ${appUsers.length} selected',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              Expanded(
                child: appUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'No contacts available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: appUsers.length,
                        itemBuilder: (context, index) {
                          final contact = appUsers[index];
                          final isSelected = _selectedContactIds.contains(contact.id);
                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedContactIds.add(contact.id);
                                } else {
                                  _selectedContactIds.remove(contact.id);
                                }
                              });
                            },
                            title: Text(
                              contact.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              contact.phoneNumber,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            secondary: contact.profileImage != null && contact.profileImage!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(contact.profileImage!),
                                  )
                                : CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    child: Text(
                                      contact.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createBroadcast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Broadcast list created with ${_selectedContactIds.length} contacts'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    Navigator.pop(context);
  }
}
