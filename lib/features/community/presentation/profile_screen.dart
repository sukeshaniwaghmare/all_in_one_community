import 'package:flutter/material.dart';
import '../../../core/widgets/apptopbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildMenuSection('Account', [
            _MenuItem(Icons.person, 'Personal Information', () {}),
            _MenuItem(Icons.security, 'Privacy & Security', () {}),
            _MenuItem(Icons.notifications, 'Notifications', () {}),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection('Community', [
            _MenuItem(Icons.groups, 'My Communities', () {}),
            _MenuItem(Icons.admin_panel_settings, 'Admin Panel', () {}),
            _MenuItem(Icons.help, 'Help & Support', () {}),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection('Settings', [
            _MenuItem(Icons.dark_mode, 'Dark Mode', () {}, trailing: Switch(value: false, onChanged: (v) {})),
            _MenuItem(Icons.language, 'Language', () {}),
            _MenuItem(Icons.info, 'About', () {}),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'john.doe@email.com',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Card(
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
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              trailing: item.trailing ?? const Icon(Icons.chevron_right),
              onTap: item.onTap,
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  _MenuItem(this.icon, this.title, this.onTap, {this.trailing});
}