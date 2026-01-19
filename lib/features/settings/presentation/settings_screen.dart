import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../qr/presentation/qr_code_screen.dart';
import '../../privacy/presentation/privacy_screen.dart';
import '../../notifications/presentation/notification_screen.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../broadcast/presentation/broadcast_screen.dart';
import '../../contacts/presentation/contacts_screen.dart';
import '../../media/presentation/media_viewer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Settings',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const SearchScreen()
              ));
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'camera', child: Text('Camera')),
              const PopupMenuItem(value: 'broadcast', child: Text('New broadcast')),
              const PopupMenuItem(value: 'contacts', child: Text('Contacts')),
              const PopupMenuItem(value: 'media', child: Text('Media viewer')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildProfileSection(),
          const SizedBox(height: 8),
          _buildSettingsSection('Account', [
            SettingItem(Icons.key, 'Privacy', 'Last seen, profile photo, about'),
            SettingItem(Icons.security, 'Security', 'End-to-end encryption, login alerts'),
            SettingItem(Icons.person_add, 'Two-step verification', 'Add extra security'),
            SettingItem(Icons.block, 'Blocked contacts', 'None'),
          ]),
          const SizedBox(height: 8),
          _buildSettingsSection('Chats', [
            SettingItem(Icons.chat_bubble, 'Chat backup', 'Last backup: Never'),
            SettingItem(Icons.history, 'Chat history', 'Export, delete'),
            SettingItem(Icons.wallpaper, 'Wallpaper', 'Change chat wallpaper'),
            SettingItem(Icons.text_fields, 'Font size', 'Medium'),
          ]),
          const SizedBox(height: 8),
          _buildSettingsSection('Notifications', [
            SettingItem(Icons.notifications, 'Messages', 'Sound, vibration, popup'),
            SettingItem(Icons.group, 'Groups', 'Sound, vibration, popup'),
            SettingItem(Icons.call, 'Calls', 'Ringtone, vibration'),
          ]),
          const SizedBox(height: 8),
          _buildSettingsSection('Storage and data', [
            SettingItem(Icons.storage, 'Storage usage', 'Network usage, auto-download'),
            SettingItem(Icons.wifi, 'Network usage', 'Bytes sent and received'),
          ]),
          const SizedBox(height: 8),
          _buildSettingsSection('Help', [
            SettingItem(Icons.help, 'Help', 'FAQ, contact us, privacy policy'),
            SettingItem(Icons.info, 'App info', 'Version, terms of service'),
          ]),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'camera':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
        break;
      case 'broadcast':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
        break;
      case 'contacts':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsScreen()));
        break;
      case 'media':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const MediaViewerScreen(
            mediaUrl: 'demo',
            mediaType: 'image',
            caption: 'Demo image',
          )
        ));
        break;
    }
  }

  void _handleSettingTap(BuildContext context, String title) {
    switch (title) {
      case 'Privacy':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()));
        break;
      case 'Messages':
      case 'Groups':
      case 'Calls':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title clicked')),
        );
    }
  }

  Widget _buildProfileSection() {
    return Builder(
      builder: (context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primaryColor,
              child: Text('M', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('Hey there! I am using WhatsApp.', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code, color: AppTheme.primaryColor),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const QRCodeScreen()
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<SettingItem> items) {
    return Builder(
      builder: (context) => Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            ...items.map((item) => ListTile(
              leading: Icon(item.icon, color: AppTheme.textSecondary),
              title: Text(item.title),
              subtitle: item.subtitle != null ? Text(item.subtitle!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)) : null,
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              onTap: () => _handleSettingTap(context, item.title),
            )),
          ],
        ),
      ),
    );
  }
}

class SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;

  SettingItem(this.icon, this.title, this.subtitle);
}