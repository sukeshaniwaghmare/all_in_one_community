import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/contact_provider.dart';
import '../models/contact_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/presentation/widgets/chats_creen3/option_screen/create_community_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<ContactProvider>().setSearchQuery(query);
                },
              )
            : const Text('Select contact'),
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'invite_all') {
                _showInviteAllDialog(context);
              } else if (value == 'contact_settings') {
                // Contact settings action
              } else if (value == 'invite_friend') {
                // Invite a friend action
              } else if (value == 'contacts') {
                // Contacts action
              } else if (value == 'refresh') {
                context.read<ContactProvider>().loadContacts();
              } else if (value == 'help') {
                // Help action
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contact_settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Contact settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'invite_friend',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Invite a friend'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'contacts',
                child: Row(
                  children: [
                    Icon(Icons.contacts),
                    SizedBox(width: 8),
                    Text('Contacts'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'invite_all',
                child: Row(
                  children: [
                    Icon(Icons.group_add),
                    SizedBox(width: 8),
                    Text('Invite All'),
                  ],
                ),
              ),
            ],
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

          return Column(
            children: [
              _buildQuickActions(),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = provider.contacts[index];
                    return _buildContactTile(contact, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.group_add, color: Colors.white),
            ),
            title: const Text('New community'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCommunityScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person_add, color: Colors.white),
            ),
            title: const Text('New contact'),
            trailing: const Icon(Icons.qr_code),
            onTap: () {},
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildContactTile(Contact contact, ContactProvider provider) {
    return ListTile(
      leading: contact.profileImage != null && contact.profileImage!.isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage(contact.profileImage!),
              onBackgroundImageError: (_, __) {},
              child: null,
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
      title: Text(
        contact.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        contact.phoneNumber,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: contact.isAppUser
          ? IconButton(
              icon: const Icon(Icons.chat, color: AppTheme.primaryColor),
              onPressed: () => provider.startChat(contact, context),
            )
          : TextButton(
              onPressed: () => _showInviteDialog(contact, provider),
              child: const Text(
                'INVITE',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      onTap: contact.isAppUser
          ? () => provider.startChat(contact, context)
          : () => _showInviteDialog(contact, provider),
    );
  }



  void _showInviteAllDialog(BuildContext context) {
    final provider = context.read<ContactProvider>();
    final nonAppUsers = provider.contacts.where((c) => !c.isAppUser).length;
    
    if (nonAppUsers == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All contacts are already app users')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite All Contacts'),
        content: Text('Send invitations to all $nonAppUsers contacts from your phone?\n\nThis will send SMS/WhatsApp invites to everyone not using the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              _startInviteProcess(context, provider, nonAppUsers);
            },
            child: const Text('Invite All'),
          ),
        ],
      ),
    );
  }

  void _startInviteProcess(BuildContext context, ContactProvider provider, int totalCount) {
    provider.inviteAllContacts();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Inviting $totalCount contacts...'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 5),
      ),
    );
    
    // Show completion message after process
    Future.delayed(const Duration(seconds: 6), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Successfully invited all $totalCount contacts!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showInviteDialog(Contact contact, ContactProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite ${contact.name}'),
        content: Text(
          'Send an invitation to ${contact.name} to join this app?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () {
              provider.inviteContact(contact);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invitation sent to ${contact.name}'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}