import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ContactSettingsScreen extends StatefulWidget {
  const ContactSettingsScreen({super.key});

  @override
  State<ContactSettingsScreen> createState() => _ContactSettingsScreenState();
}

class _ContactSettingsScreenState extends State<ContactSettingsScreen> {
  bool _showMyContacts = true;
  bool _showAllContacts = false;
  final int _blockedContactsCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Contacts', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('Display options', [
            SwitchListTile(
              title: const Text('Show my contacts'),
              subtitle: const Text('Show contacts from your address book'),
              value: _showMyContacts,
              onChanged: (value) => setState(() => _showMyContacts = value),
            ),
            SwitchListTile(
              title: const Text('Show all contacts'),
              subtitle: const Text('Show all contacts including those not in your address book'),
              value: _showAllContacts,
              onChanged: (value) => setState(() => _showAllContacts = value),
            ),
          ]),
          _buildSection('Actions', [
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Blocked contacts'),
              subtitle: Text('$_blockedContactsCount blocked'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$_blockedContactsCount blocked contacts')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh'),
              subtitle: const Text('Pull to refresh contacts'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contacts refreshed')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help selected')),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}