import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _lastSeen = 'Everyone';
  String _profilePhoto = 'Everyone';
  String _about = 'Everyone';
  String _status = 'My contacts';
  bool _readReceipts = true;
  bool _groups = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Privacy',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('Who can see my personal info', [
            _buildPrivacyOption('Last seen and online', _lastSeen, (value) => setState(() => _lastSeen = value)),
            _buildPrivacyOption('Profile photo', _profilePhoto, (value) => setState(() => _profilePhoto = value)),
            _buildPrivacyOption('About', _about, (value) => setState(() => _about = value)),
            _buildPrivacyOption('Status', _status, (value) => setState(() => _status = value)),
          ]),
          const SizedBox(height: 8),
          _buildSection('Messages', [
            _buildSwitchOption('Read receipts', 'If turned off, you won\'t send or receive read receipts', _readReceipts, (value) => setState(() => _readReceipts = value)),
          ]),
          const SizedBox(height: 8),
          _buildSection('Groups', [
            _buildSwitchOption('Groups', 'Who can add me to groups', _groups, (value) => setState(() => _groups = value)),
          ]),
          const SizedBox(height: 8),
          _buildSection('Advanced', [
            _buildSimpleOption('Blocked contacts', 'None'),
            _buildSimpleOption('Fingerprint lock', 'Unlocked'),
            _buildSimpleOption('Two-step verification', 'Disabled'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String title, String value, Function(String) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: AppTheme.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () => _showPrivacyOptions(title, value, onChanged),
    );
  }

  Widget _buildSwitchOption(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSimpleOption(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () {},
    );
  }

  void _showPrivacyOptions(String title, String currentValue, Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ...['Everyone', 'My contacts', 'Nobody'].map((option) => 
              RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: currentValue,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}