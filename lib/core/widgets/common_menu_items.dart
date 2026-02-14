import 'package:flutter/material.dart';
import '../../features/chat/presentation/widgets/chats_creen3/option_screen/create_group_screen.dart';
import '../../features/contacts/presentation/select_contacts_screen.dart';
import '../../features/calls/presentation/call_history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

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
          MaterialPageRoute(builder: (context) => const CallHistoryScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'status':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status screen not implemented yet')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$value selected')),
        );
    }
  }
}