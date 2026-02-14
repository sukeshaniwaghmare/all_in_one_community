import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entities/call.dart';
import '../provider/call_provider.dart';
import 'call_screen.dart';

class IncomingCallDialog extends StatefulWidget {
  final Call call;

  const IncomingCallDialog({super.key, required this.call});

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> {
  String _callerName = 'Unknown';

  @override
  void initState() {
    super.initState();
    _fetchCallerName();
  }

  Future<void> _fetchCallerName() async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('full_name')
          .eq('id', widget.call.callerId)
          .maybeSingle();
      
      if (response != null && mounted) {
        setState(() {
          _callerName = response['full_name'] ?? 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching caller name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                _callerName.isNotEmpty ? _callerName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _callerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Incoming ${widget.call.callType.name} call',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onPressed: () {
                    context.read<CallProvider>().rejectCall();
                    Navigator.pop(context);
                  },
                ),
                _buildActionButton(
                  icon: Icons.call,
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(call: widget.call, isIncoming: true),
                      ),
                    );
                    context.read<CallProvider>().acceptCall();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}