import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _callNotifications = true;
  String _messageSound = 'Default';
  String _groupSound = 'Default';
  String _callRingtone = 'Default';
  bool _vibrate = true;
  bool _popup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Notifications',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('Messages', [
            _buildSwitchTile('Show notifications', _messageNotifications, (value) => setState(() => _messageNotifications = value)),
            _buildSoundTile('Notification tone', _messageSound),
            _buildSwitchTile('Vibrate', _vibrate, (value) => setState(() => _vibrate = value)),
            _buildSwitchTile('Popup notification', _popup, (value) => setState(() => _popup = value)),
          ]),
          const SizedBox(height: 8),
          _buildSection('Groups', [
            _buildSwitchTile('Show notifications', _groupNotifications, (value) => setState(() => _groupNotifications = value)),
            _buildSoundTile('Notification tone', _groupSound),
            _buildSwitchTile('Vibrate', _vibrate, (value) => setState(() => _vibrate = value)),
            _buildSwitchTile('Popup notification', _popup, (value) => setState(() => _popup = value)),
          ]),
          const SizedBox(height: 8),
          _buildSection('Calls', [
            _buildSwitchTile('Show notifications', _callNotifications, (value) => setState(() => _callNotifications = value)),
            _buildSoundTile('Ringtone', _callRingtone),
            _buildSwitchTile('Vibrate', _vibrate, (value) => setState(() => _vibrate = value)),
          ]),
          const SizedBox(height: 8),
          _buildSection('App notifications', [
            _buildSimpleTile('Conversation tones', 'Play sounds for incoming and outgoing messages'),
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

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSoundTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: AppTheme.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () => _showSoundPicker(title, value),
    );
  }

  Widget _buildSimpleTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () {},
    );
  }

  void _showSoundPicker(String title, String currentValue) {
    final sounds = ['None', 'Default', 'Chime', 'Bell', 'Whistle'];
    
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
            ...sounds.map((sound) => 
              ListTile(
                title: Text(sound),
                trailing: currentValue == sound ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                onTap: () {
                  setState(() {
                    if (title.contains('Ringtone')) {
                      _callRingtone = sound;
                    } else if (title.contains('Group')) {
                      _groupSound = sound;
                    } else {
                      _messageSound = sound;
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}