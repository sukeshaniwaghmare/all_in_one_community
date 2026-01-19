import 'package:flutter/material.dart';
import '../../features/chat/presentation/create_group_screen.dart';
import '../../features/contacts/presentation/contacts_screen.dart';
import '../../features/calls/presentation/calls_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/status/presentation/status_screen.dart';

class CommonMenuItems {
  static List<PopupMenuEntry<String>> getChatMenuItems() {
    return [
      const PopupMenuItem(value: 'new_group', child: Text('New Group')),
      const PopupMenuItem(value: 'new_secret', child: Text('New Secret Chat')),
      const PopupMenuItem(value: 'contacts', child: Text('Contacts')),
      const PopupMenuItem(value: 'calls', child: Text('Calls')),
      const PopupMenuItem(value: 'settings', child: Text('Settings')),
    ];
  }

  static List<PopupMenuEntry<String>> getGeneralMenuItems() {
    return [
      const PopupMenuItem(value: 'status', child: Text('Status')),
      const PopupMenuItem(value: 'calls', child: Text('Calls')),
      const PopupMenuItem(value: 'settings', child: Text('Settings')),
      const PopupMenuItem(value: 'new_group', child: Text('New Group')),
    ];
  }

  static void handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'new_group':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
        );
        break;
      case 'contacts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactsScreen()),
        );
        break;
      case 'calls':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CallsScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'status':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatusScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$value selected')),
        );
    }
  }
}