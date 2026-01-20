import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = [
      {
        'name': 'Mom',
        'time': '2 minutes ago',
        'type': 'incoming',
        'isVideo': false,
        'avatar': 'M',
        'color': Colors.pink,
      },
      {
        'name': 'Dad',
        'time': '1 hour ago',
        'type': 'outgoing',
        'isVideo': true,
        'avatar': 'D',
        'color': Colors.blue,
      },
      {
        'name': 'Best Friend',
        'time': 'Yesterday',
        'type': 'missed',
        'isVideo': false,
        'avatar': 'B',
        'color': Colors.green,
      },
      {
        'name': 'Office',
        'time': 'Yesterday',
        'type': 'outgoing',
        'isVideo': false,
        'avatar': 'O',
        'color': Colors.orange,
      },
      {
        'name': 'Brother',
        'time': '2 days ago',
        'type': 'incoming',
        'isVideo': true,
        'avatar': 'B',
        'color': Colors.purple,
      },
    ];

    return Column(
      children: [
        // Create call link option
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.link, color: Colors.white, size: 28),
          ),
          title: const Text(
            'Create call link',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Share a link for your WhatsApp call'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call link created')),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        // Calls List
        Expanded(
          child: ListView.builder(
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: call['color'] as Color,
                  child: Text(
                    call['avatar'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  call['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: call['type'] == 'missed' ? Colors.red : null,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      _getCallIcon(call['type'] as String),
                      size: 16,
                      color: call['type'] == 'missed' ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(call['time'] as String),
                  ],
                ),
                trailing: Icon(
                  call['isVideo'] as bool ? Icons.videocam : Icons.call,
                  color: AppTheme.primaryColor,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${call['name']}...'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCallIcon(String type) {
    switch (type) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'missed':
        return Icons.call_received;
      default:
        return Icons.call;
    }
  }
}