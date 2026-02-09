import 'dart:io';
import 'package:all_in_one_community/core/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

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

  Future<void> updateAvatar(String userId, String avatarPath) async {
    try {
      print('📸 Starting avatar upload for user: $userId');
      print('📸 Avatar path: $avatarPath');
      
      final file = File(avatarPath);
      if (!file.existsSync()) {
        print('❌ File does not exist at path: $avatarPath');
        return;
      }

      final fileName = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageBytes = await file.readAsBytes();
      print('📸 Uploading to storage: $fileName');
      
      // Upload with upsert to overwrite if exists
      await supabase.storage.from('chat-media').uploadBinary(
        fileName, 
        imageBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      
      final publicUrl = supabase.storage.from('chat-media').getPublicUrl(fileName);
      print('✅ Upload successful! Public URL: $publicUrl');

      await supabase
          .from('user_profiles')
          .update({'avatar_url': publicUrl, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
      print('✅ Database updated with avatar URL');
    } catch (e) {
      print('❌ Error updating avatar: $e');
      rethrow;
    }
  }
}