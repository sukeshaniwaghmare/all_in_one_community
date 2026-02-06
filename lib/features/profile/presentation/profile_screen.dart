import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'edit_profile_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.user == null) {
            return const Center(child: Text('No user data available'));
          }

          final user = provider.user!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                color: AppTheme.primaryColor,
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit_info':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                                break;
                              case 'set_photo':
                                provider.updateProfileImage();
                                break;
                              case 'change_color':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Change Profile Color')),
                                );
                                break;
                              case 'logout':
                                _showLogoutDialog(context);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit_info',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit Information'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'set_photo',
                              child: Row(
                                children: [
                                  Icon(Icons.photo_camera),
                                  SizedBox(width: 8),
                                  Text('Set Profile Photo'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'change_color',
                              child: Row(
                                children: [
                                  Icon(Icons.palette),
                                  SizedBox(width: 8),
                                  Text('Change Profile Color'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Log Out', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: () => provider.updateProfileImage(),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: user.avatarUrl != null
                                ? (user.avatarUrl!.startsWith('http')
                                    ? NetworkImage(user.avatarUrl!) as ImageProvider
                                    : FileImage(File(user.avatarUrl!)))
                                : null,
                            backgroundColor: Colors.white,
                            child: user.avatarUrl == null
                                ? Text(
                                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'online',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              //  Info Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.phone != null && user.phone!.isNotEmpty) ...[
                      _InfoItem(
                        title: user.phone!,
                        subtitle: 'Mobile',
                      ),
                      const Divider(),
                    ],
                    _InfoItem(
                      title: user.email ?? 'Not set',
                      subtitle: 'Email',
                    ),
                    const Divider(),
                    _InfoItem(
                      title: user.location ?? 'Not set',
                      subtitle: 'Location',
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const Divider(),
                      _InfoItem(
                        title: user.bio!,
                        subtitle: 'Bio',
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              //Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Archived Posts'),
                  ],
                ),
              ),

                // 📄 Tab Content
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _EmptyPostView(),
                      _EmptyPostView(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// 🔹 Info Row
class _InfoItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showQr;

  const _InfoItem({
    required this.title,
    required this.subtitle,
    this.showQr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (showQr)
          const Icon(Icons.qr_code, color: Colors.blue),
      ],
    );
  }
}

// 🔹 Empty Posts View
class _EmptyPostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No posts yet...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {},
            icon: const Icon(Icons.camera_alt),
            label: const Text('Add a post'),
          ),
        ],
      ),
    );
  }
}
