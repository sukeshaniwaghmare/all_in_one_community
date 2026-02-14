import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entities/call.dart';
import '../provider/call_provider.dart';

class CallScreen extends StatefulWidget {
  final Call call;
  final bool isIncoming;

  const CallScreen({
    super.key,
    required this.call,
    this.isIncoming = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    
    final callProvider = context.read<CallProvider>();
    
    if (callProvider.localStream != null) {
      _localRenderer.srcObject = callProvider.localStream;
    }
    
    callProvider.remoteStream.listen((stream) {
      _remoteRenderer.srcObject = stream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallProvider>(
        builder: (context, callProvider, child) {
          if (!callProvider.isCallActive && !widget.isIncoming) {
            return _buildWaitingScreen();
          }
          
          if (widget.isIncoming && callProvider.currentCall?.status == CallStatus.ringing) {
            return _buildIncomingCallScreen(callProvider);
          }
          
          return _buildActiveCallScreen(callProvider);
        },
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Calling...',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 10),
          const Text(
            'Waiting for answer',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          Consumer<CallProvider>(
            builder: (context, callProvider, child) {
              return _buildCallButton(
                icon: Icons.call_end,
                color: Colors.red,
                onPressed: () {
                  callProvider.endCall();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingCallScreen(CallProvider callProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              widget.call.callerId[0].toUpperCase(),
              style: const TextStyle(fontSize: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Incoming ${widget.call.callType.name} call',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCallButton(
                icon: Icons.call_end,
                color: Colors.red,
                onPressed: () {
                  callProvider.rejectCall();
                  Navigator.pop(context);
                },
              ),
              _buildCallButton(
                icon: Icons.call,
                color: Colors.green,
                onPressed: () => callProvider.acceptCall(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallScreen(CallProvider callProvider) {
    return Stack(
      children: [
        // Remote video (full screen)
        if (widget.call.callType == CallType.video)
          Positioned.fill(
            child: RTCVideoView(_remoteRenderer, mirror: false),
          ),
        
        // Local video (picture-in-picture)
        if (widget.call.callType == CallType.video && callProvider.isVideoEnabled)
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),
          ),
        
        // Call controls
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: _buildCallControls(true),
        ),
        
        // Call info
        Positioned(
          top: 60,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.call.callType.name.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Text(
                '00:00',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallControls(bool isActive) {
    return Consumer<CallProvider>(
      builder: (context, callProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (isActive && widget.call.callType == CallType.video) ...[
              _buildCallButton(
                icon: callProvider.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                color: callProvider.isVideoEnabled ? Colors.white : Colors.grey,
                onPressed: callProvider.toggleVideo,
              ),
              _buildCallButton(
                icon: Icons.flip_camera_ios,
                color: Colors.white,
                onPressed: callProvider.switchCamera,
              ),
            ],
            
            if (isActive)
              _buildCallButton(
                icon: callProvider.isMuted ? Icons.mic_off : Icons.mic,
                color: callProvider.isMuted ? Colors.grey : Colors.white,
                onPressed: callProvider.toggleMute,
              ),
            
            _buildCallButton(
              icon: Icons.call_end,
              color: Colors.red,
              onPressed: () {
                callProvider.endCall();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCallButton({
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
        child: Icon(
          icon,
          color: color == Colors.white ? Colors.black : Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }
}