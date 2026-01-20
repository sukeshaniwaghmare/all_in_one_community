import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class BroadcastListScreen extends StatefulWidget {
  const BroadcastListScreen({super.key});

  @override
  State<BroadcastListScreen> createState() => _BroadcastListScreenState();
}

class _BroadcastListScreenState extends State<BroadcastListScreen> {
  final List<String> _selectedContacts = [];
  
  final List<Map<String, dynamic>> _contacts = [
    {'name': 'John Doe', 'phone': '+1234567890', 'selected': false},
    {'name': 'Jane Smith', 'phone': '+0987654321', 'selected': false},
    {'name': 'Mike Johnson', 'phone': '+1122334455', 'selected': false},
    {'name': 'Sarah Wilson', 'phone': '+5566778899', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('New Broadcast'),
        actions: [
          IconButton(
            onPressed: _selectedContacts.isNotEmpty ? _createBroadcast : null,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: const Text(
              'Only contacts with your number in their address book will receive your broadcast messages.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_selectedContacts.length} of ${_contacts.length} selected',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return CheckboxListTile(
                  value: contact['selected'],
                  onChanged: (value) {
                    setState(() {
                      contact['selected'] = value;
                      if (value == true) {
                        _selectedContacts.add(contact['name']);
                      } else {
                        _selectedContacts.remove(contact['name']);
                      }
                    });
                  },
                  title: Text(contact['name']),
                  subtitle: Text(contact['phone']),
                  secondary: CircleAvatar(
                    child: Text(contact['name'][0]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createBroadcast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Broadcast list created with ${_selectedContacts.length} contacts')),
    );
    Navigator.pop(context);
  }
}