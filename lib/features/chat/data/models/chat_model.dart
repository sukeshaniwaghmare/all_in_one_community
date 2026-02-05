class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final String senderName;
  final DateTime timestamp;
  final MessageType type;
  final bool isMe;
  final bool isRead;
  final String status;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final bool isDeleted;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.timestamp,
    this.type = MessageType.text,
    required this.isMe,
    this.isRead = false,
    this.status = 'sent',
    this.mediaUrl,
    this.thumbnailUrl,
    this.isDeleted = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    return ChatMessage(
      id: json['id'].toString(),
      text: json['content'] ?? json['message'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      senderName: json['sender_name'] ?? 'Unknown',
      timestamp: DateTime.parse(json['created_at']),
      type: _getMessageType(json['message_type']),
      isMe: json['sender_id'] == currentUserId,
      isRead: json['is_read'] ?? false,
      status: json['status'] ?? 'sent',
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  static MessageType _getMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }
}

enum MessageType { text, image, audio, video, file }

class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? profileImage;
  final String? bio;
  final String? phone;
  final String? email;
  final String? username;
  final bool isGroup;
  final String receiverUserId;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.profileImage,
    this.bio,
    this.phone,
    this.email,
    this.username,
    this.isGroup = false,
    required this.receiverUserId,
  });

  Chat copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return Chat(
      id: id,
      name: name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      profileImage: profileImage,
      bio: bio,
      phone: phone,
      email: email,
      username: username,
      isGroup: isGroup,
      receiverUserId: receiverUserId,
    );
  }

  factory Chat.fromUserProfile(Map<String, dynamic> json) {
    final userId = json['id'];
    final username = json['username'];
    print('Creating chat - ID: $userId, Username: $username');
    
    // Ensure we use the actual UUID ID, not username
    return Chat(
      id: userId.toString(), // This should be UUID
      name: json['full_name'] ?? json['username'] ?? 'Unknown User',
      lastMessage: 'Tap to start conversation',
      lastMessageTime: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      unreadCount: 0,
      profileImage: json['avatar_url'],
      bio: json['bio'],
      phone: json['phone'],
      email: json['email'],
      username: json['username'],
      isGroup: false,
      receiverUserId: userId.toString(),
    );
  }
}