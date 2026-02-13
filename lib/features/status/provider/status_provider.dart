import 'package:flutter/material.dart';
import '../data/models/status_model.dart';

class StatusProvider extends ChangeNotifier {
  final List<Status> _statuses = [];

  List<Status> get statuses => _statuses;

  void addStatus(String imagePath) {
    final status = Status(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'My status',
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );
    _statuses.insert(0, status);
    notifyListeners();
  }

  String getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
