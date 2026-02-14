import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupProvider with ChangeNotifier {
  final Set<String> _favoriteGroups = {};

  Set<String> get favoriteGroups => _favoriteGroups;

  GroupProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_groups') ?? [];
    _favoriteGroups.addAll(favorites);
    notifyListeners();
  }

  bool isFavorite(String groupId) => _favoriteGroups.contains(groupId);

  Future<void> toggleFavorite(String groupId) async {
    if (_favoriteGroups.contains(groupId)) {
      _favoriteGroups.remove(groupId);
    } else {
      _favoriteGroups.add(groupId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_groups', _favoriteGroups.toList());
    notifyListeners();
  }
}
