import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CallingScreen extends StatefulWidget {
  final String contactName;
  final String phoneNumber;
  final bool isVideo;

  const CallingScreen({
    Key? key,
    required this.contactName,
    required this.phoneNumber,
    required this.isVideo,
  }) : super(key: key);

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  String _callStatus = 'Calling...';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _simulateCall();
  }

  void _simulateCall() async {
    // Simulate ringing
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _callStatus = 'Ringing...';
      });
    }

    // Simulate connection after 5 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _callStatus = 'Connected';
        _isConnected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // Contact Info
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.contactName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              widget.contactName,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              widget.phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              _callStatus,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            
            const Spacer(),
            
            // Call Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.isVideo) ...[
                  _buildCallButton(
                    icon: Icons.videocam_off,
                    onPressed: () {},
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ],
                
                _buildCallButton(
                  icon: Icons.mic_off,
                  onPressed: () {},
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                
                _buildCallButton(
                  icon: Icons.call_end,
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.red,
                ),
                
                _buildCallButton(
                  icon: Icons.volume_up,
                  onPressed: () {},
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
      ),
    );
  }
}