import 'package:flutter/material.dart';
import '../provider/community_provider.dart';
import 'package:provider/provider.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../status/presentation/status_screen.dart';
import '../../calls/presentation/calls_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/community_type.dart';

class UpdatedMainNavigation extends StatefulWidget {
  final CommunityType communityType;

  const UpdatedMainNavigation({super.key, required this.communityType});

  @override
  State<UpdatedMainNavigation> createState() => _UpdatedMainNavigationState();
}

class _UpdatedMainNavigationState extends State<UpdatedMainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ChatListScreen(communityType: widget.communityType),
      const StatusScreen(),
      const CallsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
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
          items: [
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  if (_getUnreadCount() > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          _getUnreadCount().toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.radio_button_unchecked),
              activeIcon: Icon(Icons.radio_button_checked),
              label: 'Status',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.call_outlined),
              activeIcon: Icon(Icons.call),
              label: 'Calls',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  int _getUnreadCount() {
    final provider = context.watch<CommunityProvider>();
    return provider.chats.fold(0, (sum, chat) => sum + chat.unread);
  }
}