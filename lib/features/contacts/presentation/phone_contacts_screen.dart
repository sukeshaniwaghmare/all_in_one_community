import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PhoneContactsScreen extends StatefulWidget {
  const PhoneContactsScreen({super.key});

  @override
  State<PhoneContactsScreen> createState() => _PhoneContactsScreenState();
}

class _PhoneContactsScreenState extends State<PhoneContactsScreen> {
  final List<Map<String, String>> phoneContacts = [
    {'name': 'Mom', 'phone': '+91 9876543210'},
    {'name': 'Dad', 'phone': '+91 9876543211'},
    {'name': 'Brother', 'phone': '+91 8765432109'},
    {'name': 'Sister', 'phone': '+91 7654321098'},
    {'name': 'Best Friend', 'phone': '+91 6543210987'},
    {'name': 'Office', 'phone': '+91 5432109876'},
    {'name': 'Doctor', 'phone': '+91 4321098765'},
    {'name': 'Neighbor', 'phone': '+91 3210987654'},
    {'name': 'Colleague', 'phone': '+91 2109876543'},
    {'name': 'Gym Trainer', 'phone': '+91 1098765432'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Phone Contacts', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${phoneContacts.length} contacts from phone',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: phoneContacts.length,
              itemBuilder: (context, index) {
                final contact = phoneContacts[index];
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
                  trailing: const Icon(Icons.phone, color: Colors.grey),
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
}