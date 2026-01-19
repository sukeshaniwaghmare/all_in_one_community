import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/user.dart';
import '../data/user_repository.dart';

class ProfileProvider extends ChangeNotifier {
  User _user = UserRepository.getCurrentUser();
  bool _isLoading = false;

  User get user => _user;
  bool get isLoading => _isLoading;

  void loadUser() {
    _user = UserRepository.getCurrentUser();
    notifyListeners();
  }

  Future<void> updateProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      _user = _user.copyWith(profileImage: image.path);
      await UserRepository.updateUser(_user);
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? username,
  }) async {
    _isLoading = true;
    notifyListeners();

    final updatedUser = _user.copyWith(
      name: name,
      email: email,
      bio: bio,
      username: username,
    );

    await UserRepository.updateUser(updatedUser);
    _user = updatedUser;
    
    _isLoading = false;
    notifyListeners();
  }

  void toggleDarkMode() {
    _user = _user.copyWith(isDarkMode: !_user.isDarkMode);
    UserRepository.updateUser(_user);
    notifyListeners();
  }

  void updateLanguage(String language) {
    _user = _user.copyWith(language: language);
    UserRepository.updateUser(_user);
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await UserRepository.signOut();
    
    _isLoading = false;
    notifyListeners();
  }
}