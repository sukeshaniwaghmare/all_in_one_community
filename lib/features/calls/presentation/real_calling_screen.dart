import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class RealCallingScreen extends StatefulWidget {
  final String contactName;
  final String phoneNumber;
  final String? profileImage;
  final bool isVideo;
  final bool isIncoming;

  const RealCallingScreen({
    Key? key,
    required this.contactName,
    required this.phoneNumber,
    this.profileImage,
    this.isVideo = false,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<RealCallingScreen> createState() => _RealCallingScreenState();
}

class _RealCallingScreenState extends State<RealCallingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  String _callStatus = '';
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoOn = true;
  bool _isCallEnded = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initCall();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  void _initCall() {
    if (widget.isIncoming) {
      _callStatus = 'Incoming call...';
      _playRingtone();
    } else {
      _callStatus = 'Calling...';
      _simulateOutgoingCall();
    }
  }

  void _playRingtone() {
    // Simulate ringtone with haptic feedback
    HapticFeedback.lightImpact();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isConnected || _isCallEnded) {
        timer.cancel();
      } else {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _simulateOutgoingCall() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && !_isCallEnded) {
      setState(() => _callStatus = 'Ringing...');
    }
    
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && !_isCallEnded) {
      _acceptCall();
    }
  }

  void _acceptCall() {
    setState(() {
      _isConnected = true;
      _callStatus = 'Connected';
    });
    _startCallTimer();
    _pulseController.stop();
    HapticFeedback.mediumImpact();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  void _endCall() {
    setState(() => _isCallEnded = true);
    _callTimer?.cancel();
    _pulseController.stop();
    HapticFeedback.heavyImpact();
    
    Navigator.pop(context);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isVideo ? Colors.black : const Color(0xFF0C1317),
      body: Stack(
        children: [
          if (widget.isVideo) _buildVideoBackground(),
          _buildCallInterface(),
          if (widget.isIncoming && !_isConnected) _buildIncomingCallActions(),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.videocam,
          size: 100,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildCallInterface() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildContactInfo(),
          const Spacer(),
          if (_isConnected) _buildConnectedControls() else _buildCallingControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isConnected ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: widget.profileImage != null
                    ? ClipOval(
                        child: Image.network(
                          widget.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(),
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          widget.contactName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.phoneNumber,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isConnected ? _formatDuration(_callDuration) : _callStatus,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.contactName.isNotEmpty ? widget.contactName[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCallingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCallButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: _endCall,
          size: 70,
        ),
      ],
    );
  }

  Widget _buildConnectedControls() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.isVideo)
              _buildCallButton(
                icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                color: _isVideoOn ? Colors.white.withOpacity(0.2) : Colors.red,
                onPressed: () => setState(() => _isVideoOn = !_isVideoOn),
              ),
            _buildCallButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              color: _isMuted ? Colors.red : Colors.white.withOpacity(0.2),
              onPressed: () => setState(() => _isMuted = !_isMuted),
            ),
            _buildCallButton(
              icon: Icons.call_end,
              color: Colors.red,
              onPressed: _endCall,
              size: 70,
            ),
            _buildCallButton(
              icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              color: _isSpeakerOn ? Colors.blue : Colors.white.withOpacity(0.2),
              onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
            ),
            _buildCallButton(
              icon: Icons.add_call,
              color: Colors.white.withOpacity(0.2),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingCallActions() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCallButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: _endCall,
            size: 70,
          ),
          _buildCallButton(
            icon: Icons.call,
            color: Colors.green,
            onPressed: _acceptCall,
            size: 70,
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}