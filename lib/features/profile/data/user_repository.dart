import '../domain/user.dart';

class UserRepository {
  static User? _currentUser;

  static User getCurrentUser() {
    return _currentUser ?? User(
      id: '1',
      name: 'Sukeshani Waghmare',
      email: 'sukeshani@email.com',
      role: 'Admin',
      phone: '+91 9102251845',
      bio: 'software engineer 😎',
      username: 'sukeshaniwaghmare',
    );
  }

  static Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = user;
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}