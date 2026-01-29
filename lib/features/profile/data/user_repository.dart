import '../domain/user.dart';
import '../../../core/supabase_service.dart';

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

  // Load user from Supabase database
  static Future<User?> loadUserFromDatabase() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      print('Current user ID: $userId');
      
      if (userId == null) {
        print('No authenticated user found');
        return null;
      }
      
      print('Fetching profile from database for user: $userId');
      
      final response = await SupabaseService.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      print('Database response: $response');
      
      _currentUser = User(
        id: response['id'],
        name: response['name'] ?? '',
        email: response['email'] ?? '',
        role: 'User',
        phone: response['phone'] ?? '',
        bio: response['bio'] ?? '',
        username: response['username'] ?? '',
        profileImage: response['avatar_url'],
        isDarkMode: response['is_dark_mode'] ?? false,
        language: response['language'] ?? 'English',
      );
      
      print('User loaded successfully: ${_currentUser!.name}');
      return _currentUser;
    } catch (e) {
      print('Error loading user from database: $e');
      return null;
    }
  }

  static Future<void> updateUser(User user) async {
    try {
      // Update in database
      await _saveToDatabase(user);
      // Update local cache
      _currentUser = user;
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Save user to Supabase database
  static Future<void> _saveToDatabase(User user) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      print('Saving user to database. User ID: $userId');
      
      if (userId == null) {
        print('No authenticated user, cannot save to database');
        return;
      }
      
      final userData = {
        'id': userId,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'bio': user.bio,
        'username': user.username,
        'avatar_url': user.profileImage,
        'is_dark_mode': user.isDarkMode,
        'language': user.language,
      };
      
      print('User data to save: $userData');
      
      // Try to update first, if not exists then insert
      final existing = await SupabaseService.instance.client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      
      if (existing != null) {
        print('Updating existing profile');
        await SupabaseService.instance.client
            .from('profiles')
            .update(userData)
            .eq('id', userId);
        print('Profile updated successfully');
      } else {
        print('Inserting new profile');
        await SupabaseService.instance.client
            .from('profiles')
            .insert(userData);
        print('Profile inserted successfully');
      }
    } catch (e) {
      print('Error saving user to database: $e');
    }
  }

  static Future<void> signOut() async {
    await SupabaseService.instance.signOut();
    _currentUser = null;
  }
}