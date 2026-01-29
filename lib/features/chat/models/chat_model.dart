class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final MessageType type;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.type = MessageType.text,
    required this.isMe,
  });
}

enum MessageType { text, image, audio }

class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? profileImage;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.profileImage,
  });
}