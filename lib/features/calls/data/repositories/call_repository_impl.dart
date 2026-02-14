import '../../domain/entities/call.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/call_remote_data_source.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource _remoteDataSource;

  CallRepositoryImpl(this._remoteDataSource);

  @override
  Future<Call> initiateCall(String receiverId, CallType callType) {
    return _remoteDataSource.initiateCall(receiverId, callType);
  }

  @override
  Future<void> acceptCall(String callId, Map<String, dynamic> answer) {
    return _remoteDataSource.acceptCall(callId, answer);
  }

  @override
  Future<void> rejectCall(String callId) {
    return _remoteDataSource.rejectCall(callId);
  }

  @override
  Future<void> endCall(String callId) {
    return _remoteDataSource.endCall(callId);
  }

  @override
  Future<void> updateCallOffer(String callId, Map<String, dynamic> offer) {
    return _remoteDataSource.updateCallOffer(callId, offer);
  }

  @override
  Future<void> addIceCandidate(String callId, Map<String, dynamic> candidate) {
    return _remoteDataSource.addIceCandidate(callId, candidate);
  }

  @override
  Stream<Call> watchCall(String callId) {
    return _remoteDataSource.watchCall(callId);
  }

  @override
  Stream<List<IceCandidate>> watchIceCandidates(String callId) {
    return _remoteDataSource.watchIceCandidates(callId);
  }

  @override
  Stream<Call> watchIncomingCalls() {
    return _remoteDataSource.watchIncomingCalls();
  }
}