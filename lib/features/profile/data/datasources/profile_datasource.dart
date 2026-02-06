import 'package:all_in_one_community/core/supabase_service.dart';

import '../../domain/user.dart';

class ProfileDataSource {
  final supabase = SupabaseService.instance.client;

  Future<User?> fetchUserProfile(String userId) async {
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return User.fromJson(response);
  }

  Future<void> updateUserProfile(User user) async {
    await supabase
        .from('user_profiles')
        .upsert(user.toJson())
        .eq('id', user.id);
  }

  Future<void> updateAvatar(String userId, String avatarUrl) async {
    await supabase
        .from('user_profiles')
        .update({'avatar_url': avatarUrl, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }
}