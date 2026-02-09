import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/user.dart';
import '../data/user_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAvatarFromPath(String imagePath) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateAvatar(_user!.id, imagePath);
      await loadUser();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && _user != null) {
      _isLoading = true;
      notifyListeners();

      try {
        await _repository.updateAvatar(_user!.id, image.path);
        await loadUser(); // Reload user to get updated avatar URL
      } catch (e) {
        _error = e.toString();
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? phone,
    String? email,
    String? location,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        fullName: fullName,
        bio: bio,
        phone: phone,
        email: email,
        location: location,
      );

      await _repository.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(isDarkMode: !_user!.isDarkMode);
    await _repository.updateUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(language: language);
    await _repository.updateUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _repository.signOut();
    _user = null;

    _isLoading = false;
    notifyListeners();
  }
}