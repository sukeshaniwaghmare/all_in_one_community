class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final CallType callType;
  final CallStatus status;
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int duration;

  const Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.callType,
    required this.status,
    this.offer,
    this.answer,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.duration = 0,
  });

  Call copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    CallType? callType,
    CallStatus? status,
    Map<String, dynamic>? offer,
    Map<String, dynamic>? answer,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? duration,
  }) {
    return Call(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      offer: offer ?? this.offer,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
    );
  }
}

enum CallType { audio, video }

enum CallStatus { ringing, accepted, rejected, ended, missed }

class IceCandidate {
  final String id;
  final String callId;
  final Map<String, dynamic> candidate;
  final String senderId;
  final DateTime createdAt;

  const IceCandidate({
    required this.id,
    required this.callId,
    required this.candidate,
    required this.senderId,
    required this.createdAt,
  });
}