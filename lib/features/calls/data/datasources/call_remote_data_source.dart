import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/call_model.dart';
import '../../domain/entities/call.dart';

class CallRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<CallModel> initiateCall(String receiverId, CallType callType) async {
    final response = await _supabase.from('calls').insert({
      'caller_id': _supabase.auth.currentUser!.id,
      'receiver_id': receiverId,
      'call_type': callType.name,
      'status': CallStatus.ringing.name,
    }).select().single();

    return CallModel.fromJson(response);
  }

  Future<void> acceptCall(String callId, Map<String, dynamic> answer) async {
    await _supabase.from('calls').update({
      'status': CallStatus.accepted.name,
      'answer': answer,
      'started_at': DateTime.now().toIso8601String(),
    }).eq('id', callId);
  }

  Future<void> rejectCall(String callId) async {
    await _supabase.from('calls').update({
      'status': CallStatus.rejected.name,
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', callId);
  }

  Future<void> endCall(String callId) async {
    final call = await _supabase.from('calls').select().eq('id', callId).single();
    final startedAt = call['started_at'] != null ? DateTime.parse(call['started_at']) : null;
    final duration = startedAt != null ? DateTime.now().difference(startedAt).inSeconds : 0;

    await _supabase.from('calls').update({
      'status': CallStatus.ended.name,
      'ended_at': DateTime.now().toIso8601String(),
      'duration': duration,
    }).eq('id', callId);
  }

  Future<void> updateCallOffer(String callId, Map<String, dynamic> offer) async {
    await _supabase.from('calls').update({'offer': offer}).eq('id', callId);
  }

  Future<void> addIceCandidate(String callId, Map<String, dynamic> candidate) async {
    await _supabase.from('ice_candidates').insert({
      'call_id': callId,
      'candidate': candidate,
      'sender_id': _supabase.auth.currentUser!.id,
    });
  }

  Stream<CallModel> watchCall(String callId) {
    return _supabase
        .from('calls')
        .stream(primaryKey: ['id'])
        .map((data) {
          final filtered = data.where((item) => item['id'] == callId).toList();
          return filtered.isNotEmpty ? CallModel.fromJson(filtered.first) : null;
        })
        .where((call) => call != null)
        .cast<CallModel>();
  }

  Stream<List<IceCandidateModel>> watchIceCandidates(String callId) {
    return _supabase
        .from('ice_candidates')
        .stream(primaryKey: ['id'])
        .map((data) {
          final filtered = data.where((item) => item['call_id'] == callId).toList();
          return filtered.map((json) => IceCandidateModel.fromJson(json)).toList();
        });
  }

  Stream<CallModel> watchIncomingCalls() {
    final userId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('calls')
        .stream(primaryKey: ['id'])
        .map((data) {
          final filtered = data.where((item) => 
            item['receiver_id'] == userId && 
            item['caller_id'] != userId &&
            item['status'] == CallStatus.ringing.name
          ).toList();
          return filtered.isNotEmpty ? CallModel.fromJson(filtered.first) : null;
        })
        .where((call) => call != null)
        .cast<CallModel>();
  }
}