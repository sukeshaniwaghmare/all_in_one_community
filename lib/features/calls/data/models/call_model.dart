import '../../domain/entities/call.dart';

class CallModel extends Call {
  const CallModel({
    required super.id,
    required super.callerId,
    required super.receiverId,
    required super.callType,
    required super.status,
    super.offer,
    super.answer,
    required super.createdAt,
    super.startedAt,
    super.endedAt,
    super.duration,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'],
      callerId: json['caller_id'],
      receiverId: json['receiver_id'],
      callType: CallType.values.firstWhere(
        (e) => e.name == json['call_type'],
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      offer: json['offer'],
      answer: json['answer'],
      createdAt: DateTime.parse(json['created_at']),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caller_id': callerId,
      'receiver_id': receiverId,
      'call_type': callType.name,
      'status': status.name,
      'offer': offer,
      'answer': answer,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration': duration,
    };
  }
}

class IceCandidateModel extends IceCandidate {
  const IceCandidateModel({
    required super.id,
    required super.callId,
    required super.candidate,
    required super.senderId,
    required super.createdAt,
  });

  factory IceCandidateModel.fromJson(Map<String, dynamic> json) {
    return IceCandidateModel(
      id: json['id'],
      callId: json['call_id'],
      candidate: json['candidate'],
      senderId: json['sender_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_id': callId,
      'candidate': candidate,
      'sender_id': senderId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}