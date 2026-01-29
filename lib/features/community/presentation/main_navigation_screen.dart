import 'package:flutter/material.dart';
import '../provider/community_provider.dart';
import 'package:provider/provider.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../status/presentation/status_screen.dart';
import '../../calls/presentation/calls_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../domain/community_type.dart';

class MainNavigationScreen extends StatefulWidget {
  final CommunityType communityType;

  const MainNavigationScreen({super.key, required this.communityType});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ChatListScreen(communityType: widget.communityType),
      const StatusScreen(),
      const CallsScreen(),
      const SettingsScreen(),
    ];
    
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.radio_button_unchecked), activeIcon: Icon(Icons.radio_button_checked), label: 'Status'),
            BottomNavigationBarItem(icon: Icon(Icons.call_outlined), activeIcon: Icon(Icons.call), label: 'Calls'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

// Removed CommunityScreen - using Status/Calls instead
class CommunityScreen extends StatelessWidget {
  final CommunityType communityType;

  const CommunityScreen({super.key, required this.communityType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: communityType.name,
        titleWidget: InkWell(
          onTap: () => _showCommunityInfo(context),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Text(communityType.icon, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Consumer<CommunityProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(communityType.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                        Text('${provider.memberCount} members', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'info', child: Text('Community Info')),
              const PopupMenuItem(value: 'invite', child: Text('Invite Members')),
              const PopupMenuItem(value: 'mute', child: Text('Mute')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildQuickActions(context),
          const SizedBox(height: 8),
          _buildMembersSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "community_fab",
        onPressed: () => _showAddMemberDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                context.read<CommunityProvider>().addMember(nameController.text, emailController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added successfully')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Add Member', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCommunityInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer<CommunityProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(communityType.icon, style: const TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 16),
                Text(communityType.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${provider.memberCount} members', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                Text(communityType.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.event, 'Events', () {}),
          _buildActionButton(Icons.poll, 'Polls', () {}),
          _buildActionButton(Icons.help, 'Help', () {}),
          _buildActionButton(Icons.info, 'Info', () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppTheme.primaryColor),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppTheme.primaryColor))),
            ],
          ),
          ...List.generate(
            3,
            (index) => Consumer<CommunityProvider>(
              builder: (context, provider, child) {
                if (provider.members.isEmpty) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Text('U${index + 1}', style: const TextStyle(color: Colors.white))),
                    title: Text('User ${index + 1}'),
                    subtitle: const Text('Member', style: TextStyle(color: AppTheme.textSecondary)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    onTap: () {},
                  );
                }
                
                if (index >= provider.members.length) return const SizedBox.shrink();
                
                final member = provider.members[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Text(member.avatar, style: const TextStyle(color: Colors.white))),
                  title: Text(member.name),
                  subtitle: Text(member.role, style: const TextStyle(color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}