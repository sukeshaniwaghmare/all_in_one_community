import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/audio_call_screen.dart';
import '../presentation/video_call_screen.dart';

class CallNotificationService {
  static final CallNotificationService _instance = CallNotificationService._internal();
  factory CallNotificationService() => _instance;
  CallNotificationService._internal();

  RealtimeChannel? _channel;

  void initialize(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('call_notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'call_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            _handleIncomingCall(context, data);
          },
        )
        .subscribe();
  }

  void _handleIncomingCall(BuildContext context, Map<String, dynamic> data) {
    final isVideo = data['is_video'] as bool;
    final callerName = data['receiver_name'] as String;
    final channelId = data['channel_id'] as String;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isVideo
            ? VideoCallScreen(
                contactName: callerName,
                isIncoming: true,
                channelId: channelId,
              )
            : AudioCallScreen(
                contactName: callerName,
                isIncoming: true,
                channelId: channelId,
              ),
      ),
    );
  }

  void dispose() {
    _channel?.unsubscribe();
  }
}
