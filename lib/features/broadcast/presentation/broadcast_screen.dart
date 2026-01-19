import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final List<Contact> _selectedContacts = [];
  final List<Contact> _contacts = [
    Contact('Alice Johnson', '+1 234 567 8901'),
    Contact('Bob Smith', '+1 234 567 8902'),
    Contact('Charlie Brown', '+1 234 567 8903'),
    Contact('Diana Prince', '+1 234 567 8904'),
    Contact('Edward Norton', '+1 234 567 8905'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'New broadcast',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
          if (_selectedContacts.isNotEmpty) _buildSelectedContacts(),
          _buildBroadcastInfo(),
          Expanded(child: _buildContactsList()),
        ],
      ),
      floatingActionButton: _selectedContacts.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: _createBroadcast,
              child: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSelectedContacts() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedContacts.length} of ${_contacts.length} selected',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedContacts.length,
              itemBuilder: (context, index) {
                final contact = _selectedContacts[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(contact.name[0], style: const TextStyle(color: Colors.white)),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: GestureDetector(
                              onTap: () => _removeContact(contact),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.name.split(' ')[0],
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastInfo() {
    return Container(
      color: const Color(0xFFFFF3CD),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF856404)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Only contacts with your number saved will receive your broadcast messages.',
              style: TextStyle(color: Color(0xFF856404), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          final isSelected = _selectedContacts.contains(contact);
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(contact.name[0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(contact.name),
            subtitle: Text(contact.phone),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleContact(contact),
              activeColor: AppTheme.primaryColor,
            ),
            onTap: () => _toggleContact(contact),
          );
        },
      ),
    );
  }

  void _toggleContact(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void _removeContact(Contact contact) {
    setState(() {
      _selectedContacts.remove(contact);
    });
  }

  void _createBroadcast() {
    if (_selectedContacts.isNotEmpty) {
      Navigator.pop(context, _selectedContacts);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Broadcast list created with ${_selectedContacts.length} contacts')),
      );
    }
  }
}

class Contact {
  final String name;
  final String phone;

  Contact(this.name, this.phone);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact && runtimeType == other.runtimeType && phone == other.phone;

  @override
  int get hashCode => phone.hashCode;
}