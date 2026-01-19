import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PersonProfileScreen extends StatefulWidget {
  final String name;
  final bool isOnline;
  final Color avatarColor;

  const PersonProfileScreen({
    super.key,
    required this.name,
    required this.isOnline,
    required this.avatarColor,
  });

  @override
  State<PersonProfileScreen> createState() => _PersonProfileScreenState();
}

class _PersonProfileScreenState extends State<PersonProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Contact', 'Notifications', 'Media visibility', 'Encryption'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.only(top: 40, bottom: 0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {},
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'add_to_favorites', child: Row(children: [Icon(Icons.favorite_border), SizedBox(width: 8), Text('Add to Favorites')])),
                        const PopupMenuItem(value: 'block', child: Row(children: [Icon(Icons.block, color: Colors.red), SizedBox(width: 8), Text('Block', style: TextStyle(color: Colors.red))])),
                        const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.report, color: Colors.red), SizedBox(width: 8), Text('Report', style: TextStyle(color: Colors.red))])),
                      ],
                    ),
                  ],
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
          // Contact Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: widget.avatarColor,
                  child: Text(widget.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(widget.isOnline ? 'online' : 'last seen recently', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 24),
              _buildPrivacyOption(
                icon: Icons.lock,
                title: 'Chat lock',
                subtitle: 'Lock and hide this chat on this device.',
                isEnabled: false,
              ),
              const Divider(height: 1),
              _buildPrivacyOption(
                icon: Icons.security,
                title: 'Advanced chat privacy',
                subtitle: 'Off',
                isEnabled: false,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text('+1 234 567 8900'),
                subtitle: const Text('Mobile'),
                trailing: IconButton(icon: const Icon(Icons.call), onPressed: () {}),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Bio'),
                subtitle: const Text('Hey there! I am using this app.'),
              ),
            ],
          ),
          // Notifications Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSettingTile(Icons.notifications, 'Notifications', 'All'),
              const Divider(height: 1),
              _buildSettingTile(Icons.message, 'Mute notifications', 'Off'),
            ],
          ),
          // Media Visibility Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSettingTile(Icons.visibility, 'Media visibility', 'All'),
              const Divider(height: 1),
              _buildSettingTile(Icons.download, 'Auto-download', 'Wi-Fi only'),
            ],
          ),
          // Encryption Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSettingTile(Icons.lock, 'Encryption', 'Messages and calls are end-to-end encrypted. Tap to learn more.'),
              const Divider(height: 1),
              _buildSettingTile(Icons.timer, 'Disappearing messages', 'Off'),
            ],
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: Switch(value: isEnabled, onChanged: (value) {}),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
      onTap: () {},
    );
  }
}
