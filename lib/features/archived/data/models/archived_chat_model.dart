class ArchivedChat {
  final String id;
  final String chatId;
  final String userId;
  final DateTime archivedAt;

  ArchivedChat({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.archivedAt,
  });

  factory ArchivedChat.fromJson(Map<String, dynamic> json) {
    return ArchivedChat(
      id: json['id'].toString(),
      chatId: json['chat_id'],
      userId: json['user_id'],
      archivedAt: DateTime.parse(json['archived_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'user_id': userId,
      'archived_at': archivedAt.toIso8601String(),
    };
  }
}
