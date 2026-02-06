import '../domain/user.dart';
import '../../../core/supabase_service.dart';
import 'datasources/profile_datasource.dart';

class UserRepository {
  final ProfileDataSource _dataSource = ProfileDataSource();

  Future<User?> getCurrentUser() async {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return null;
    return await _dataSource.fetchUserProfile(userId);
  }

  Future<void> updateUser(User user) async {
    await _dataSource.updateUserProfile(user);
  }

  Future<void> updateAvatar(String userId, String avatarUrl) async {
    await _dataSource.updateAvatar(userId, avatarUrl);
  }

  Future<void> signOut() async {
    await SupabaseService.instance.signOut();
  }
}