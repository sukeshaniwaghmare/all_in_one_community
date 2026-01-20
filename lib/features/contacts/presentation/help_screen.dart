import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Help', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection(
            'Getting Started',
            [
              'Tap search to find contacts quickly',
              'Use QR scanner to add new contacts instantly',
              'Create groups for multiple contacts',
              'Invite friends to join the community',
            ],
          ),
          _buildHelpSection(
            'Managing Contacts',
            [
              'View all your contacts in one place',
              'Access phone contacts separately',
              'Block unwanted contacts',
              'Refresh contacts to sync latest changes',
            ],
          ),
          _buildHelpSection(
            'Settings & Privacy',
            [
              'Manage contact display options',
              'Control who can see your information',
              'Configure notification preferences',
              'Access blocked contacts list',
            ],
          ),
          _buildHelpSection(
            'Troubleshooting',
            [
              'If contacts don\'t appear, try refreshing',
              'Check app permissions for contacts access',
              'Restart the app if issues persist',
              'Contact support for further assistance',
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 48, color: AppTheme.primaryColor),
                  const SizedBox(height: 12),
                  const Text(
                    'Need More Help?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Contact our support team for personalized assistance',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening support chat...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Contact Support'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}