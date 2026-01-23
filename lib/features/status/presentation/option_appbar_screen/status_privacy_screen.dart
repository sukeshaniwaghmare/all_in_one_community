import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class StatusPrivacyScreen extends StatefulWidget {
  const StatusPrivacyScreen({super.key});

  @override
  State<StatusPrivacyScreen> createState() => _StatusPrivacyScreenState();
}

class _StatusPrivacyScreenState extends State<StatusPrivacyScreen> {
  String _selectedPrivacy = 'My contacts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
        title: Text('Status Privacy', style: TextStyle(color: AppTheme.primaryColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who can see my status updates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('My contacts'),
              subtitle: const Text('Share with all your contacts'),
              value: 'My contacts',
              groupValue: _selectedPrivacy,
              onChanged: (value) => setState(() => _selectedPrivacy = value!),
            ),
            RadioListTile<String>(
              title: const Text('My contacts except...'),
              subtitle: const Text('Share with contacts except some'),
              value: 'My contacts except',
              groupValue: _selectedPrivacy,
              onChanged: (value) => setState(() => _selectedPrivacy = value!),
            ),
            RadioListTile<String>(
              title: const Text('Only share with...'),
              subtitle: const Text('Share with selected contacts only'),
              value: 'Only share with',
              groupValue: _selectedPrivacy,
              onChanged: (value) => setState(() => _selectedPrivacy = value!),
            ),
          ],
        ),
      ),
    );
  }
}