import 'package:flutter/material.dart';
import '../../../core/services/enhanced_call_service.dart';
import '../../../core/theme/app_theme.dart';

class CallDemoWidget extends StatelessWidget {
  const CallDemoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Demo'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Real Calling Functionality',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildDemoButton(
              context,
              'Outgoing Audio Call',
              Icons.call,
              Colors.green,
              () => _makeOutgoingCall(context, false),
            ),
            
            const SizedBox(height: 16),
            
            _buildDemoButton(
              context,
              'Outgoing Video Call',
              Icons.videocam,
              Colors.blue,
              () => _makeOutgoingCall(context, true),
            ),
            
            const SizedBox(height: 16),
            
            _buildDemoButton(
              context,
              'Incoming Audio Call',
              Icons.call_received,
              Colors.orange,
              () => _simulateIncomingCall(context, false),
            ),
            
            const SizedBox(height: 16),
            
            _buildDemoButton(
              context,
              'Incoming Video Call',
              Icons.video_call,
              Colors.purple,
              () => _simulateIncomingCall(context, true),
            ),
            
            const SizedBox(height: 32),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            _buildDemoButton(
              context,
              'Make Real Phone Call',
              Icons.phone,
              Colors.red,
              () => _makeRealPhoneCall(context),
            ),
            
            const Spacer(),
            
            const Text(
              'Note: Real phone calls require phone permissions and will use your device\'s dialer.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _makeOutgoingCall(BuildContext context, bool isVideo) {
    CallService.startCall(
      context: context,
      contactName: 'John Doe',
      phoneNumber: '+1 (555) 123-4567',
      profileImage: null,
      isVideo: isVideo,
      isIncoming: false,
    );
  }

  void _simulateIncomingCall(BuildContext context, bool isVideo) {
    CallService.simulateIncomingCall(
      context: context,
      contactName: 'Sarah Wilson',
      phoneNumber: '+1 (555) 987-6543',
      profileImage: null,
      isVideo: isVideo,
    );
  }

  void _makeRealPhoneCall(BuildContext context) {
    CallService.makePhoneCall('+1234567890', context);
  }
}