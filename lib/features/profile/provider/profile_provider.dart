import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/user.dart';
import '../data/user_repository.dart';
import '../../../core/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  User _user = UserRepository.getCurrentUser();
  bool _isLoading = false;

  User get user => _user;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    loadUser(); // Auto-load user data on initialization
  }

  void loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    print('Loading user from database...');
    
    // Try to load from database first
    final dbUser = await UserRepository.loadUserFromDatabase();
    if (dbUser != null) {
      print('User loaded from database: ${dbUser.name}');
      _user = dbUser;
    } else {
      print('No user found in database, using default');
      _user = UserRepository.getCurrentUser();
    }
    
    _isLoading = false;
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
  }) async {
    // Check if user is authenticated
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser == null) {
      print('User not authenticated! Please login first.');
      // Show error or redirect to login
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    print('Updating profile: name=$name, email=$email, bio=$bio');
    print('Authenticated user ID: ${currentUser.id}');

    final updatedUser = _user.copyWith(
      id: currentUser.id, // Use authenticated user ID
      name: name ?? _user.name,
      email: email ?? _user.email ?? currentUser.email,
      bio: bio ?? _user.bio,
    );

    print('Updated user object created: ${updatedUser.name}');
    await UserRepository.updateUser(updatedUser);
    _user = updatedUser;
    
    _isLoading = false;
    notifyListeners();
    print('Profile update completed');
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

  // Create initial profile for authenticated user
  Future<void> createInitialProfile() async {
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser == null) {
      print('No authenticated user to create profile for');
      return;
    }
    
    print('Creating initial profile for user: ${currentUser.id}');
    
    final initialUser = User(
      id: currentUser.id,
      name: currentUser.userMetadata?['name'] ?? 'User',
      email: currentUser.email ?? '',
      role: 'User',
      phone: '',
      bio: '',
    );
    
    await UserRepository.updateUser(initialUser);
    _user = initialUser;
    notifyListeners();
    
    print('Initial profile created successfully');
  }
}