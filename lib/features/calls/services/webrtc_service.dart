import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  RtcEngine? _engine;
  String? _currentChannelId;
  bool _isInCall = false;

  static const String appId = 'e8f6f0c6b8d04d0fa5e3c8b9d7f6e5c4';

  Future<void> initialize() async {
    if (_engine != null) return;
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(appId: appId));
  }

  Future<String> startCall({required String receiverId, required String receiverName, required bool isVideo}) async {
    await initialize();
    final channelId = 'call_${DateTime.now().millisecondsSinceEpoch}';
    final userId = Supabase.instance.client.auth.currentUser?.id;
    await Supabase.instance.client.from('call_notifications').insert({
      'channel_id': channelId, 'caller_id': userId, 'receiver_id': receiverId,
      'receiver_name': receiverName, 'is_video': isVideo, 'status': 'ringing',
      'created_at': DateTime.now().toIso8601String(),
    });
    return channelId;
  }

  Future<void> joinCall(String channelId, int uid, {bool isVideo = false}) async {
    _currentChannelId = channelId;
    _isInCall = true;
    if (isVideo) await _engine!.enableVideo();
    await _engine!.joinChannel(token: '', channelId: channelId, uid: uid, options: const ChannelMediaOptions());
  }

  Future<void> endCall() async {
    if (_engine != null && _isInCall) await _engine!.leaveChannel();
    if (_currentChannelId != null) {
      await Supabase.instance.client.from('call_notifications')
          .update({'status': 'ended', 'ended_at': DateTime.now().toIso8601String()})
          .eq('channel_id', _currentChannelId!);
    }
    _isInCall = false;
    _currentChannelId = null;
  }

  Future<void> toggleMute(bool mute) async => await _engine?.muteLocalAudioStream(mute);
  Future<void> toggleVideo(bool enabled) async => await _engine?.muteLocalVideoStream(!enabled);
  Future<void> switchCamera() async => await _engine?.switchCamera();

  void registerEventHandler({Function(RtcConnection, int, int)? onUserJoined, Function(RtcConnection, int, UserOfflineReasonType)? onUserOffline}) {
    _engine?.registerEventHandler(RtcEngineEventHandler(onUserJoined: onUserJoined, onUserOffline: onUserOffline));
  }

  RtcEngine? get engine => _engine;
  bool get isInCall => _isInCall;
}
