import '../entities/call.dart';

abstract class CallRepository {
  Future<Call> initiateCall(String receiverId, CallType callType);
  Future<void> acceptCall(String callId, Map<String, dynamic> answer);
  Future<void> rejectCall(String callId);
  Future<void> endCall(String callId);
  Future<void> updateCallOffer(String callId, Map<String, dynamic> offer);
  Future<void> addIceCandidate(String callId, Map<String, dynamic> candidate);
  Stream<Call> watchCall(String callId);
  Stream<List<IceCandidate>> watchIceCandidates(String callId);
  Stream<Call> watchIncomingCalls();
}