import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
        title: Text('Settings', style: TextStyle(color: AppTheme.primaryColor)),
      ),
      body: ListView(
        children: [
          // Profile Section
          ListTile(
            leading: const CircleAvatar(
              radius: 25,
              child: Icon(Icons.person, size: 30),
            ),
            title: const Text('Your Name', style: TextStyle(fontSize: 18)),
            subtitle: const Text('Hey there! I am using Community.'),
            trailing: const Icon(Icons.qr_code),
            onTap: () => _openProfile(context),
          ),
          const Divider(),
          
          // Settings Options
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Account'),
            subtitle: const Text('Security notifications, change number'),
            onTap: () => _openAccount(context),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy'),
            subtitle: const Text('Block contacts, disappearing messages'),
            onTap: () => _openPrivacy(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Avatar'),
            subtitle: const Text('Create, edit, profile photo'),
            onTap: () => _openAvatar(context),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chats'),
            subtitle: const Text('Theme, wallpapers, chat history'),
            onTap: () => _openChats(context),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Message, group & call tones'),
            onTap: () => _openNotifications(context),
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Storage and Data'),
            subtitle: const Text('Network usage, auto-download'),
            onTap: () => _openStorageData(context),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('App Language'),
            subtitle: const Text('English (device\'s language)'),
            onTap: () => _openLanguage(context),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            subtitle: const Text('Help centre, contact us, privacy policy'),
            onTap: () => _openHelp(context),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Invite a friend'),
            onTap: () => _inviteFriend(context),
          ),
          
          const Divider(),
          
          // App Info
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('from', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 4),
                Text('FACEBOOK', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Version 2.23.24.76', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile settings opened')),
    );
  }

  void _openAccount(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account settings opened')),
    );
  }

  void _openPrivacy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings opened')),
    );
  }

  void _openAvatar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar settings opened')),
    );
  }

  void _openChats(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat settings opened')),
    );
  }

  void _openNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings opened')),
    );
  }

  void _openStorageData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage and data settings opened')),
    );
  }

  void _openLanguage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language settings opened')),
    );
  }

  void _openHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center opened')),
    );
  }

  void _inviteFriend(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite friend feature opened')),
    );
  }
}