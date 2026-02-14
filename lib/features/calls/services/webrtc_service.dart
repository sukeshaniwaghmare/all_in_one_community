import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final StreamController<MediaStream> _remoteStreamController = StreamController<MediaStream>.broadcast();
  final StreamController<RTCIceCandidate> _iceCandidateController = StreamController<RTCIceCandidate>.broadcast();
  
  Stream<MediaStream> get remoteStream => _remoteStreamController.stream;
  Stream<RTCIceCandidate> get iceCandidate => _iceCandidateController.stream;
  
  MediaStream? get localStream => _localStream;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  Future<void> initialize() async {
    _peerConnection = await createPeerConnection(_iceServers);
    
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (!_iceCandidateController.isClosed) {
        _iceCandidateController.add(candidate);
      }
    };
    
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty && !_remoteStreamController.isClosed) {
        _remoteStream = event.streams[0];
        _remoteStreamController.add(event.streams[0]);
      }
    };
  }

  Future<MediaStream> getUserMedia({required bool video, required bool audio}) async {
    final constraints = {
      'audio': audio,
      'video': video ? {'facingMode': 'user'} : false,
    };
    
    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    
    // Use addTrack instead of addStream for Unified Plan
    _localStream!.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });
    
    return _localStream!;
  }

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks().first);
    }
  }

  void toggleMute() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
    }
  }

  void toggleVideo() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
    }
  }

  Future<void> dispose() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    
    // Close controllers after disposing resources
    if (!_remoteStreamController.isClosed) {
      await _remoteStreamController.close();
    }
    if (!_iceCandidateController.isClosed) {
      await _iceCandidateController.close();
    }
  }
}