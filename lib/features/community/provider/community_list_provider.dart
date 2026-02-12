import 'package:flutter/material.dart';

class CommunityListProvider extends ChangeNotifier {
  final Map<String, String> _communityLists = {};

  void addToList(String communityName, String listName) {
    _communityLists[communityName] = listName;
    notifyListeners();
  }

  String? getList(String communityName) {
    return _communityLists[communityName];
  }

  List<String> getCommunitiesByList(String listName) {
    return _communityLists.entries
        .where((entry) => entry.value == listName)
        .map((entry) => entry.key)
        .toList();
  }
}
