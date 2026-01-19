import 'package:flutter/material.dart';

class AnnouncementsProvider extends ChangeNotifier {
  List<Announcement> _announcements = [];
  bool _isLoading = false;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;

  void loadAnnouncements() {
    _isLoading = true;
    notifyListeners();
    
    _announcements = [
      Announcement(
        id: '1',
        title: 'Monthly Maintenance Due',
        content: 'Dear residents, please note that the monthly maintenance fee is due by the end of this month.',
        author: 'Society Admin',
        time: '2 hours ago',
        priority: 'high',
        likes: 12,
        comments: 3,
        hasAttachment: true,
      ),
      Announcement(
        id: '2',
        title: 'Water Supply Interruption',
        content: 'Water supply will be interrupted tomorrow from 10 AM to 2 PM for maintenance work.',
        author: 'Maintenance Team',
        time: '5 hours ago',
        priority: 'medium',
        likes: 8,
        comments: 1,
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  void toggleLike(String id) {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index != -1) {
      _announcements[index] = _announcements[index].copyWith(
        isLiked: !_announcements[index].isLiked,
        likes: _announcements[index].isLiked 
            ? _announcements[index].likes - 1 
            : _announcements[index].likes + 1,
      );
      notifyListeners();
    }
  }

  void addComment(String id) {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index != -1) {
      _announcements[index] = _announcements[index].copyWith(
        comments: _announcements[index].comments + 1,
      );
      notifyListeners();
    }
  }
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final String author;
  final String time;
  final String priority;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool hasAttachment;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.time,
    required this.priority,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.hasAttachment = false,
  });

  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? time,
    String? priority,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? hasAttachment,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      hasAttachment: hasAttachment ?? this.hasAttachment,
    );
  }
}