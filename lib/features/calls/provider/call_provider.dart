import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../domain/entities/call.dart';
import '../domain/repositories/call_repository.dart';
import '../services/webrtc_service.dart';

class CallProvider extends ChangeNotifier {
  final CallRepository _callRepository;
  final WebRTCService _webrtcService;
  
  CallProvider(this._callRepository, this._webrtcService);

  Call? _currentCall;
  bool _isCallActive = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  StreamSubscription? _callSubscription;
  StreamSubscription? _iceCandidateSubscription;
  StreamSubscription? _incomingCallSubscription;
  StreamSubscription? _webrtcIceCandidateSubscription;

  Call? get currentCall => _currentCall;
  bool get isCallActive => _isCallActive;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  MediaStream? get localStream => _webrtcService.localStream;
  Stream<MediaStream> get remoteStream => _webrtcService.remoteStream;

  void startListeningForIncomingCalls() {
    print('🎧 Started listening for incoming calls');
    _incomingCallSubscription = _callRepository.watchIncomingCalls().listen((call) {
      print('📞 Incoming call detected: ${call.id} from ${call.callerId}');
      _currentCall = call;
      notifyListeners();
    });
  }

  Future<void> initiateCall(String receiverId, CallType callType) async {
    try {
      print('📞 Initiating call to $receiverId');
      await _webrtcService.initialize();
      await _webrtcService.getUserMedia(
        video: callType == CallType.video,
        audio: true,
      );

      _currentCall = await _callRepository.initiateCall(receiverId, callType);
      print('✅ Call created: ${_currentCall!.id}');
      _isCallActive = true;
      
      _setupCallListeners();
      _setupWebRTCListeners();
      
      final offer = await _webrtcService.createOffer();
      await _callRepository.updateCallOffer(_currentCall!.id, offer.toMap());
      print('📤 Offer sent');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initiating call: $e');
      _isCallActive = false;
      notifyListeners();
    }
  }

  Future<void> acceptCall() async {
    if (_currentCall == null) return;
    
    try {
      await _webrtcService.initialize();
      await _webrtcService.getUserMedia(
        video: _currentCall!.callType == CallType.video,
        audio: true,
      );

      _setupCallListeners();
      _setupWebRTCListeners();

      if (_currentCall!.offer != null) {
        await _webrtcService.setRemoteDescription(
          RTCSessionDescription(_currentCall!.offer!['sdp'], _currentCall!.offer!['type'])
        );
      }

      final answer = await _webrtcService.createAnswer();
      await _callRepository.acceptCall(_currentCall!.id, answer.toMap());
      
      _isCallActive = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error accepting call: $e');
    }
  }

  Future<void> rejectCall() async {
    if (_currentCall == null) return;
    
    await _callRepository.rejectCall(_currentCall!.id);
    _cleanup();
  }

  Future<void> endCall() async {
    if (_currentCall == null) return;
    
    await _callRepository.endCall(_currentCall!.id);
    _cleanup();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _webrtcService.toggleMute();
    notifyListeners();
  }

  void toggleVideo() {
    _isVideoEnabled = !_isVideoEnabled;
    _webrtcService.toggleVideo();
    notifyListeners();
  }

  void switchCamera() {
    _webrtcService.switchCamera();
  }

  void _setupCallListeners() {
    _callSubscription = _callRepository.watchCall(_currentCall!.id).listen((call) {
      _currentCall = call;
      
      if (call.status == CallStatus.accepted && call.answer != null) {
        _webrtcService.setRemoteDescription(
          RTCSessionDescription(call.answer!['sdp'], call.answer!['type'])
        );
      } else if (call.status == CallStatus.ended || call.status == CallStatus.rejected) {
        _cleanup();
      }
      
      notifyListeners();
    });

    _iceCandidateSubscription = _callRepository.watchIceCandidates(_currentCall!.id).listen((candidates) {
      for (final candidate in candidates) {
        _webrtcService.addIceCandidate(RTCIceCandidate(
          candidate.candidate['candidate'],
          candidate.candidate['sdpMid'],
          candidate.candidate['sdpMLineIndex'],
        ));
      }
    });
  }

  void _setupWebRTCListeners() {
    _webrtcIceCandidateSubscription = _webrtcService.iceCandidate.listen((candidate) {
      _callRepository.addIceCandidate(_currentCall!.id, {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    });
  }

  void _cleanup() {
    _currentCall = null;
    _isCallActive = false;
    _isMuted = false;
    _isVideoEnabled = true;
    
    _callSubscription?.cancel();
    _iceCandidateSubscription?.cancel();
    _webrtcIceCandidateSubscription?.cancel();
    
    _webrtcService.dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    _incomingCallSubscription?.cancel();
    _cleanup();
    super.dispose();
  }
}