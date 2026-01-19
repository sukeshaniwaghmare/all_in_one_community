import 'package:flutter/material.dart';
import 'dart:async';

class VideoCallScreen extends StatefulWidget {
  final String contactName;
  final bool isIncoming;
  
  const VideoCallScreen({
    super.key,
    required this.contactName,
    this.isIncoming = false,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  Duration _callDuration = Duration.zero;
  Timer? _timer;
  bool _isCallActive = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isIncoming) {
      _startCall();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCall() {
    setState(() => _isCallActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  void _acceptCall() {
    _startCall();
  }

  void _declineCall() {
    Navigator.pop(context);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video area
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade800,
                  Colors.black,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade600,
                    child: Text(
                      widget.contactName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 60,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.contactName,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCallActive 
                        ? _formatDuration(_callDuration)
                        : widget.isIncoming 
                            ? 'Incoming video call...'
                            : 'Calling...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Self video preview (small window)
          if (_isVideoEnabled && _isCallActive)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          
          // Control buttons
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: widget.isIncoming && !_isCallActive
                ? _buildIncomingCallControls()
                : _buildActiveCallControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Decline button
        GestureDetector(
          onTap: _declineCall,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        // Accept button
        GestureDetector(
          onTap: _acceptCall,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.videocam,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute button
        GestureDetector(
          onTap: () => setState(() => _isMuted = !_isMuted),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _isMuted ? Colors.red : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        // End call button
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        
        // Video toggle button
        GestureDetector(
          onTap: () => setState(() => _isVideoEnabled = !_isVideoEnabled),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _isVideoEnabled ? Colors.white24 : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        // Speaker button
        GestureDetector(
          onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _isSpeakerOn ? Colors.blue : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}