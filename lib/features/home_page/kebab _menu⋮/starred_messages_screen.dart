import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../chat/provider/chat_provider.dart';
import '../../chat/data/models/chat_model.dart';
import '../../../core/theme/app_theme.dart';

class StarredMessagesScreen extends StatefulWidget {
  const StarredMessagesScreen({super.key});

  @override
  State<StarredMessagesScreen> createState() => _StarredMessagesScreenState();
}

class _StarredMessagesScreenState extends State<StarredMessagesScreen> {
  List<Map<String, dynamic>> _starredMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStarredMessages();
  }

  Future<void> _loadStarredMessages() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await Supabase.instance.client
          .from('messages')
          .select('id, message, sender_id, receiver_id, created_at')
          .eq('is_starred', true)
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('created_at', ascending: false);

      final messages = <Map<String, dynamic>>[];
      for (var msg in response) {
        final senderId = msg['sender_id'];
        final senderProfile = await Supabase.instance.client
            .from('user_profiles')
            .select('full_name')
            .eq('id', senderId)
            .maybeSingle();

        messages.add({
          'id': msg['id'],
          'sender': senderProfile?['full_name'] ?? 'Unknown',
          'message': msg['message'],
          'timestamp': DateTime.parse(msg['created_at']),
        });
      }

      setState(() {
        _starredMessages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        title: const Text('Starred Messages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _starredMessages.isEmpty
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Tap and hold on any message and tap the star to add it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
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
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Text(
                            message['sender'][0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          message['sender'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(message['message']),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(message['timestamp']),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.star, color: Colors.amber),
                          onPressed: () => _unstarMessage(message['id']),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return 'Today at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<void> _unstarMessage(int messageId) async {
    try {
      await Supabase.instance.client
          .from('messages')
          .update({'is_starred': false})
          .eq('id', messageId);

      setState(() {
        _starredMessages.removeWhere((msg) => msg['id'] == messageId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message unstarred'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unstar message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
