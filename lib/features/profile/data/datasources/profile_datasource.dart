import '../../../profile/domain/user.dart';

class ProfileDataSource {
  static User getMockUser() {
    return User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@email.com',
      role: 'Admin',
      isDarkMode: false,
      language: 'English',
    );
  }

  static Future<User> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getMockUser();
  }

  static Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate API call
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate sign out process
  }
}