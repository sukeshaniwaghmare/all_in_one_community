import 'package:flutter/material.dart';

class EncryptionSettingsScreen extends StatefulWidget {
  const EncryptionSettingsScreen({super.key});

  @override
  State<EncryptionSettingsScreen> createState() => _EncryptionSettingsScreenState();
}

class _EncryptionSettingsScreenState extends State<EncryptionSettingsScreen> {
  bool _isE2EEnabled = true;
  bool _isBiometricEnabled = false;
  bool _isBackupEncrypted = true;
  bool _showSecurityNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Privacy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('End-to-End Encryption'),
          _buildEncryptionCard(),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Authentication'),
          _buildAuthenticationSettings(),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Backup Security'),
          _buildBackupSettings(),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Privacy Controls'),
          _buildPrivacySettings(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEncryptionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: _isE2EEnabled ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End-to-End Encryption',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _isE2EEnabled 
                            ? 'Your messages are secured with end-to-end encryption'
                            : 'Messages are not encrypted',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isE2EEnabled ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isE2EEnabled,
                  onChanged: (value) {
                    setState(() => _isE2EEnabled = value);
                  },
                ),
              ],
            ),
            if (_isE2EEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Messages and calls are end-to-end encrypted. Tap to verify.',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face unlock'),
            value: _isBiometricEnabled,
            onChanged: (value) {
              setState(() => _isBiometricEnabled = value);
            },
            secondary: const Icon(Icons.fingerprint),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add extra security to your account'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Two-Factor Authentication setup')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Encrypted Backups'),
            subtitle: const Text('Encrypt chat backups'),
            value: _isBackupEncrypted,
            onChanged: (value) {
              setState(() => _isBackupEncrypted = value);
            },
            secondary: const Icon(Icons.backup),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Backup Encryption Key'),
            subtitle: const Text('Manage your backup encryption key'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showBackupKeyDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Security Notifications'),
            subtitle: const Text('Get notified about security events'),
            value: _showSecurityNotifications,
            onChanged: (value) {
              setState(() => _showSecurityNotifications = value);
            },
            secondary: const Icon(Icons.notifications_active),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.visibility_off),
            title: const Text('Disappearing Messages'),
            subtitle: const Text('Set default timer for new chats'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showDisappearingMessagesDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Contacts'),
            subtitle: const Text('Manage blocked users'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Blocked contacts management')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBackupKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Encryption Key'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your backup encryption key:'),
            SizedBox(height: 16),
            SelectableText(
              'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ12-3456',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                backgroundColor: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Store this key safely. You\'ll need it to restore encrypted backups.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Copy Key'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDisappearingMessagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disappearing Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Off',
            '24 hours',
            '7 days',
            '90 days',
          ].map((option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: 'Off',
            onChanged: (value) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Set to: $value')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }
}