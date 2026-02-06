import 'package:flutter/material.dart';


class StarredMessagesScreen extends StatelessWidget {
  const StarredMessagesScreen({super.key});

  final List<Map<String, dynamic>> _starredMessages = const [
    {
      'sender': 'John Doe',
      'message': 'Hey, don\'t forget about the meeting tomorrow!',
      'time': '10:30 AM',
      'date': 'Today',
    },
    {
      'sender': 'Jane Smith',
      'message': 'The project deadline is next Friday.',
      'time': '2:15 PM',
      'date': 'Yesterday',
    },
    {
      'sender': 'Mike Johnson',
      'message': 'Great job on the presentation!',
      'time': '4:45 PM',
      'date': '2 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: const Color(0xFF075E54)),
        title: Text('Starred Messages', style: TextStyle(color: const Color(0xFF075E54))),
      ),
      body: _starredMessages.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No starred messages',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap and hold on any message and tap the star to add it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _starredMessages.length,
              itemBuilder: (context, index) {
                final message = _starredMessages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(message['sender'][0]),
                    ),
                    title: Text(message['sender']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message['message']),
                        const SizedBox(height: 4),
                        Text(
                          '${message['date']} at ${message['time']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.star, color: Colors.amber),
                      onPressed: () => _unstarMessage(context, index),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }

  void _unstarMessage(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message unstarred')),
    );
  }
}
