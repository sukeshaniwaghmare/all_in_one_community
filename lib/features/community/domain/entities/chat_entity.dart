import 'package:flutter/material.dart';

class ChatEntity {
  final String initials;
  final String name;
  final String preview;
  final String time;
  final int unread;
  final Color avatarColor;
  final List<String>? members;

  const ChatEntity({
    required this.initials,
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.avatarColor,
    this.members,
  });
}
