import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/apptopbar.dart';

class AdvancedChatPrivacyScreen extends StatefulWidget {
  const AdvancedChatPrivacyScreen({super.key});

  @override
  State<AdvancedChatPrivacyScreen> createState() => _AdvancedChatPrivacyScreenState();
}

class _AdvancedChatPrivacyScreenState extends State<AdvancedChatPrivacyScreen> {
  bool _readReceipts = true;
  bool _onlineStatus = true;
  bool _typingIndicator = true;
  bool _screenshotNotification = false;
  bool _forwardingRestriction = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Advanced chat privacy',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Control advanced privacy settings for this chat.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Read receipts'),
                  subtitle: const Text('Show when messages are read'),
                  value: _readReceipts,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) => setState(() => _readReceipts = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Online status'),
                  subtitle: const Text('Show when you are online'),
                  value: _onlineStatus,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) => setState(() => _onlineStatus = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Typing indicator'),
                  subtitle: const Text('Show when you are typing'),
                  value: _typingIndicator,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) => setState(() => _typingIndicator = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Screenshot notification'),
                  subtitle: const Text('Notify when screenshots are taken'),
                  value: _screenshotNotification,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) => setState(() => _screenshotNotification = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Forwarding restriction'),
                  subtitle: const Text('Prevent messages from being forwarded'),
                  value: _forwardingRestriction,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) => setState(() => _forwardingRestriction = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}