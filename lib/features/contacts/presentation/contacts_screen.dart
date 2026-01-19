import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../../core/widgets/common_menu_items.dart';

class ContactsScreen extends StatefulWidget {
  final bool isGroupCreation;
  
  const ContactsScreen({super.key, this.isGroupCreation = false});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<Map<String, String>> contacts = [
    {'name': 'John Doe', 'phone': '+91 9876543210'},
    {'name': 'Jane Smith', 'phone': '+91 8765432109'},
    {'name': 'Mike Johnson', 'phone': '+91 7654321098'},
    {'name': 'Sarah Wilson', 'phone': '+91 6543210987'},
    {'name': 'David Brown', 'phone': '+91 5432109876'},
    {'name': 'Emma Davis', 'phone': '+91 4321098765'},
    {'name': 'Alex Garcia', 'phone': '+91 3210987654'},
    {'name': 'Lisa Miller', 'phone': '+91 2109876543'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: widget.isGroupCreation ? 'Select Contacts' : 'Contacts',
        showBackButton: true,
        menuItems: widget.isGroupCreation ? null : CommonMenuItems.getGeneralMenuItems(),
        onMenuSelected: (value) => CommonMenuItems.handleMenuSelection(context, value),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
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
            trailing: widget.isGroupCreation 
                ? const Icon(Icons.add_circle_outline)
                : null,
            onTap: () {
              if (widget.isGroupCreation) {
                Navigator.pop(context, contact);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${contact['name']}'),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}