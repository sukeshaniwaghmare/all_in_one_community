import 'package:supabase_flutter/supabase_flutter.dart';

class UserHelper {
  static Future<String?> getUserIdByName(String fullName) async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('id')
          .eq('full_name', fullName)
          .maybeSingle();
      
      return response?['id'];
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }
}
