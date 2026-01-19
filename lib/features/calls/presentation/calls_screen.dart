import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../../core/widgets/common_menu_items.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Calls',
        showBackButton: true,
        menuItems: CommonMenuItems.getGeneralMenuItems(),
        onMenuSelected: (value) => CommonMenuItems.handleMenuSelection(context, value),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _callHistory.length,
        itemBuilder: (context, index) {
          final call = _callHistory[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAvatarColor(call['name']),
              child: Text(
                call['name'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              call['name'],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  call['type'] == 'incoming' ? Icons.call_received : Icons.call_made,
                  size: 16,
                  color: call['type'] == 'missed' ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    call['time'],
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                call['isVideo'] ? Icons.videocam : Icons.call,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${call['name']}...')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new call')),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    const colors = [
      Color(0xFF5B9BD5),
      Color(0xFF70AD47),
      Color(0xFFFFC000),
      Color(0xFFED7D31),
      Color(0xFF9E480E),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  static final List<Map<String, dynamic>> _callHistory = [
    {
      'name': 'John Doe',
      'type': 'outgoing',
      'time': 'Today, 2:30 PM',
      'isVideo': false,
    },
    {
      'name': 'Sarah Wilson',
      'type': 'incoming',
      'time': 'Today, 1:15 PM',
      'isVideo': true,
    },
    {
      'name': 'Mike Johnson',
      'type': 'missed',
      'time': 'Yesterday, 9:45 AM',
      'isVideo': false,
    },
    {
      'name': 'Emma Davis',
      'type': 'outgoing',
      'time': 'Yesterday, 7:20 PM',
      'isVideo': true,
    },
    {
      'name': 'Alex Brown',
      'type': 'incoming',
      'time': '2 days ago',
      'isVideo': false,
    },
    {
      'name': 'Lisa Garcia',
      'type': 'outgoing',
      'time': '3 days ago',
      'isVideo': false,
    },
  ];
}