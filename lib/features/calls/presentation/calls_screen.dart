import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'call_info_screen.dart';
import 'contact_selection_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {

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
        // ✅ Top action buttons (added)
        _buildTopActions(),

        // Create call link option (unchanged)
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

        // Calls List (unchanged)
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
                      color: call['type'] == 'missed'
                          ? Colors.red
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(call['time'] as String),
                  ],
                ),
                trailing: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallInfoScreen(
                          name: call['name'] as String,
                          avatar: call['avatar'] as String,
                          color: call['color'] as Color,
                          isVideo: call['isVideo'] as bool,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    call['isVideo'] as bool
                        ? Icons.videocam
                        : Icons.call,
                    color: AppTheme.primaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallInfoScreen(
                        name: call['name'] as String,
                        avatar: call['avatar'] as String,
                        color: call['color'] as Color,
                        isVideo: call['isVideo'] as bool,
                      ),
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

  // 🔹 Top action buttons widget
  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.call, 
            label: 'Call',
            onTap: () => _showCallDialog(),
          ),
          _ActionButton(
            icon: Icons.calendar_today, 
            label: 'Schedule',
            onTap: () => _showScheduleDialog(),
          ),
          _ActionButton(
            icon: Icons.dialpad, 
            label: 'Keypad',
            onTap: () => _showKeypad(),
          ),
          _ActionButton(
            icon: Icons.group, 
            label: 'Group',
            onTap: () => _showGroupCall(),
          ),
          _ActionButton(
            icon: Icons.favorite_border, 
            label: 'Favorites',
            onTap: () => _showFavorites(),
          ),
        ],
      ),
    );
  }

  void _showCallDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactSelectionScreen()),
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Call'),
        content: const Text('Schedule a call for later'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showKeypad() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('Keypad Interface', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  void _showGroupCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Call'),
        content: const Text('Start a group call with multiple contacts'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('Favorite Contacts', style: TextStyle(fontSize: 18)),
        ),
      ),
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

// 🔹 Action button UI
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
