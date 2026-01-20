import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../../core/widgets/common_menu_items.dart';
import 'contact_settings_screen.dart';
import 'phone_contacts_screen.dart';
import 'help_screen.dart';

class ContactsScreen extends StatefulWidget {
  final bool isGroupCreation;
  
  const ContactsScreen({super.key, this.isGroupCreation = false});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, String>> contacts = [
    {'name': 'Rahul Sharma', 'phone': '+91 9876543210'},
    {'name': 'Priya Patel', 'phone': '+91 9876543211'},
    {'name': 'Amit Kumar', 'phone': '+91 8765432109'},
    {'name': 'Sneha Gupta', 'phone': '+91 7654321098'},
    {'name': 'Vikram Singh', 'phone': '+91 6543210987'},
    {'name': 'Kavya Reddy', 'phone': '+91 5432109876'},
    {'name': 'Arjun Mehta', 'phone': '+91 4321098765'},
    {'name': 'Ananya Joshi', 'phone': '+91 3210987654'},
    {'name': 'Rohan Agarwal', 'phone': '+91 2109876543'},
    {'name': 'Ishita Verma', 'phone': '+91 1098765432'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredContacts = contacts;
    
    if (_isSearching && _searchController.text.isNotEmpty) {
      filteredContacts = contacts
          .where((contact) =>
              contact['name']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              contact['phone']!.contains(_searchController.text))
          .toList();
    }

    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select contact',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              '${filteredContacts.length} contacts',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contact_settings',
                child: Text('Contact settings'),
              ),
              const PopupMenuItem(
                value: 'invite_friend',
                child: Text('Invite a friend'),
              ),
              const PopupMenuItem(
                value: 'contacts',
                child: Text('Contacts'),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh'),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Text('Help'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildActionTiles(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contacts on Community',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      contact['name']![0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(contact['name']!),
                  subtitle: Text(contact['phone']!),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected: ${contact['name']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search contacts...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildActionTiles() {
    return Column(
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.group_add, color: Colors.white),
          ),
          title: const Text('New group'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New group selected')),
            );
          },
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.person_add, color: Colors.white),
          ),
          title: const Text('New contact'),
          trailing: const Icon(Icons.qr_code_scanner),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR Scanner opened')),
            );
          },
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.groups, color: Colors.white),
          ),
          title: const Text('New community'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New community selected')),
            );
          },
        ),
      ],
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'contact_settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactSettingsScreen()),
        );
        break;
      case 'invite_friend':
        _showInviteFriendDialog();
        break;
      case 'contacts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PhoneContactsScreen()),
        );
        break;
      case 'refresh':
        _refreshContacts();
        break;
      case 'help':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        );
        break;
    }
  }

  void _showInviteFriendDialog() {
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
            const Text(
              'Invite friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInviteOption(Icons.message, 'SMS', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite via SMS')),
                  );
                }),
                _buildInviteOption(Icons.email, 'Email', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite via Email')),
                  );
                }),
                _buildInviteOption(Icons.share, 'Share', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share app link')),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _refreshContacts() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts refreshed successfully')),
      );
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Tap search to find contacts'),
            Text('• Use QR scanner to add new contacts'),
            Text('• Create groups for multiple contacts'),
            Text('• Invite friends to join the community'),
            Text('• Manage settings from the menu'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}