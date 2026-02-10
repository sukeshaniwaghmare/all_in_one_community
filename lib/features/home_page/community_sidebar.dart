import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../profile/provider/profile_provider.dart';
import '../profile/presentation/profile_screen.dart';
import '../settings/presentation/settings_screen.dart';
import '../calls/presentation/calls_screen.dart';
import '../contacts/presentation/select_contacts_screen.dart';

class CommunityDrawer extends StatelessWidget {
  const CommunityDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _drawerHeader(context),
            _accountTile(context),
            const Divider(height: 1),

            _menuItem(Icons.person_outline, 'My Profile', context, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }),
            _menuItem(Icons.group_outlined, 'New Group', context),
            _menuItem(Icons.people_outline, 'Contacts', context, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactsScreen()),
              );
            }),
            _menuItem(Icons.call_outlined, 'Calls', context, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CallsScreen()),
              );
            }),
            _menuItem(Icons.bookmark_border, 'Saved Messages', context),
            _menuItem(Icons.settings_outlined, 'Settings', context, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }),

            const Divider(height: 1),

            _menuItem(Icons.person_add_alt, 'Invite Friends', context),
            _menuItem(Icons.info_outline, 'Community Features', context),
          ],
        ),
      ),
    );
  }

  /// 🔵 HEADER
  Widget _drawerHeader(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, provider, __) {
        final user = provider.user;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      backgroundImage: user?.avatarUrl != null ? (user!.avatarUrl!.startsWith('http') ? NetworkImage(user.avatarUrl!) : FileImage(File(user.avatarUrl!)) as ImageProvider) : null,
                      child: user?.avatarUrl == null ? Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ) : null,
                    ),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return IconButton(
                          icon: Icon(
                            themeProvider.isDarkMode ? Icons.wb_sunny : Icons.dark_mode_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user?.phone ?? '+91 9011064801',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 👤 ACCOUNT TILE
  Widget _accountTile(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, provider, __) {
        final user = provider.user;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            backgroundImage: user?.avatarUrl != null ? (user!.avatarUrl!.startsWith('http') ? NetworkImage(user.avatarUrl!) : FileImage(File(user.avatarUrl!)) as ImageProvider) : null,
            child: user?.avatarUrl == null ? Text(
              user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white),
            ) : null,
          ),
          title: Text(
            user?.fullName ?? 'User',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.verified, color: Colors.green),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        );
      },
    );
  }

  /// 📋 MENU ITEM
  Widget _menuItem(IconData icon, String title, BuildContext context, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}
