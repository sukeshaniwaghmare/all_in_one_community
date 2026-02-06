import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedContacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: const Color(0xFF075E54)),
        title: Text('New Group', style: TextStyle(color: const Color(0xFF075E54))),
        actions: [
          TextButton(
            onPressed: _selectedContacts.isNotEmpty && _groupNameController.text.trim().isNotEmpty
                ? _createGroup
                : null,
            child: Text('CREATE', style: TextStyle(color: const Color(0xFF075E54))),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group name',
                hintText: 'Enter group name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Select contacts:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final contact = 'Contact ${index + 1}';
                final isSelected = _selectedContacts.contains(contact);
                return CheckboxListTile(
                  title: Text(contact),
                  subtitle: Text('+1234567890$index'),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedContacts.add(contact);
                      } else {
                        _selectedContacts.remove(contact);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createGroup() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group "${_groupNameController.text.trim()}" created with ${_selectedContacts.length} members!')),
    );
  }
}
