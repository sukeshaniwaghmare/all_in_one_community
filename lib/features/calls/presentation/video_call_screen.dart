import 'package:flutter/material.dart';
import 'dart:async';
import '../services/webrtc_service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../core/helpers/user_helper.dart';

class VideoCallScreen extends StatefulWidget {
  final String contactName;
  final bool isIncoming;
  final String? channelId;
  final String? receiverId;
  
  const VideoCallScreen({
    super.key,
    required this.contactName,
    this.isIncoming = false,
    this.channelId,
    this.receiverId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false, _isVideoEnabled = true, _isSpeakerOn = false, _isCallActive = false;
  Duration _callDuration = Duration.zero;
  Timer? _timer;
  final WebRTCService _webRTC = WebRTCService();
  int? _remoteUid;
  String? _resolvedReceiverId;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    await _webRTC.initialize();
    _resolvedReceiverId = widget.receiverId ?? await UserHelper.getUserIdByName(widget.contactName);
    _webRTC.registerEventHandler(
      onUserJoined: (connection, remoteUid, elapsed) => setState(() => _remoteUid = remoteUid),
      onUserOffline: (connection, remoteUid, reason) => _endCall(),
    );
    if (!widget.isIncoming) await _startCall();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _webRTC.endCall();
    super.dispose();
  }

  Future<void> _startCall() async {
    try {
      String channelId;
      if (widget.channelId != null) {
        channelId = widget.channelId!;
      } else {
        if (_resolvedReceiverId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
          Navigator.pop(context);
          return;
        }
        channelId = await _webRTC.startCall(
          receiverId: _resolvedReceiverId!,
          receiverName: widget.contactName,
          isVideo: true,
        );
      }
      
      await _webRTC.joinCall(channelId, 0, isVideo: true);
      
      setState(() => _isCallActive = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _callDuration = Duration(seconds: timer.tick);
        });
      });
    } catch (e) {
      Navigator.pop(context);
    }
  }

  Future<void> _endCall() async {
    _timer?.cancel();
    await _webRTC.endCall();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _acceptCall() async {
    await _startCall();
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
          if (_remoteUid != null && _isCallActive)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: AgoraVideoView(controller: VideoViewController.remote(
                rtcEngine: _webRTC.engine!, canvas: VideoCanvas(uid: _remoteUid),
                connection: const RtcConnection(channelId: ''),
              )),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.grey.shade800, Colors.black],
              )),
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 80, backgroundColor: Colors.grey.shade600,
                    child: Text(widget.contactName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.w300))),
                  const SizedBox(height: 20),
                  Text(widget.contactName, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w300)),
                  const SizedBox(height: 8),
                  Text(_isCallActive ? _formatDuration(_callDuration) : widget.isIncoming ? 'Incoming video call...' : 'Calling...',
                    style: const TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              )),
            ),
          if (_isVideoEnabled && _isCallActive)
            Positioned(top: 60, right: 20,
              child: SizedBox(width: 120, height: 160,
                child: ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: AgoraVideoView(controller: VideoViewController(
                    rtcEngine: _webRTC.engine!, canvas: const VideoCanvas(uid: 0),
                  )),
                ),
              ),
            ),
          Positioned(bottom: 80, left: 0, right: 0,
            child: widget.isIncoming && !_isCallActive ? _buildIncomingCallControls() : _buildActiveCallControls()),
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
        GestureDetector(
          onTap: () {
            setState(() => _isMuted = !_isMuted);
            _webRTC.toggleMute(_isMuted);
          },
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
        
        GestureDetector(
          onTap: () {
            setState(() => _isVideoEnabled = !_isVideoEnabled);
            _webRTC.toggleVideo(_isVideoEnabled);
          },
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
        
        GestureDetector(
          onTap: () => _webRTC.switchCamera(),
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cameraswitch,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}