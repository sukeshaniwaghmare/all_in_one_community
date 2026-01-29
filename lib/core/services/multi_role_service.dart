import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole {
  superAdmin('SUPER_ADMIN', 5),
  admin('ADMIN', 4),
  moderator('MODERATOR', 3),
  member('MEMBER', 2),
  guest('GUEST', 1);

  const UserRole(this.name, this.level);
  final String name;
  final int level;

  static UserRole? fromString(String roleName) {
    for (UserRole role in UserRole.values) {
      if (role.name == roleName) return role;
    }
    return null;
  }
}

class MultiRoleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add role to user
  Future<bool> addUserRole(String userId, String roleName) async {
    try {
      final role = UserRole.fromString(roleName);
      if (role == null) return false;

      await _supabase.from('user_roles').insert({
        'user_id': userId,
        'role': role.name,
        'role_level': role.level,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error adding role: $e');
      return false;
    }
  }

  // Check if user has specific role
  Future<bool> userHasRole(String userId, String roleName) async {
    try {
      final response = await _supabase
          .from('user_roles')
          .select()
          .eq('user_id', userId)
          .eq('role', roleName)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking role: $e');
      return false;
    }
  }

  // Get user's highest role
  Future<UserRole?> getUserHighestRole(String userId) async {
    try {
      final response = await _supabase
          .from('user_roles')
          .select()
          .eq('user_id', userId)
          .order('role_level', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return UserRole.fromString(response['role']);
      }
      return null;
    } catch (e) {
      print('Error getting highest role: $e');
      return null;
    }
  }

  // Get all user roles
  Future<List<UserRole>> getUserRoles(String userId) async {
    try {
      final response = await _supabase
          .from('user_roles')
          .select()
          .eq('user_id', userId)
          .order('role_level', ascending: false);

      return response
          .map<UserRole?>((role) => UserRole.fromString(role['role']))
          .where((role) => role != null)
          .cast<UserRole>()
          .toList();
    } catch (e) {
      print('Error getting user roles: $e');
      return [];
    }
  }

  // Remove role from user
  Future<bool> removeUserRole(String userId, String roleName) async {
    try {
      await _supabase
          .from('user_roles')
          .delete()
          .eq('user_id', userId)
          .eq('role', roleName);

      return true;
    } catch (e) {
      print('Error removing role: $e');
      return false;
    }
  }

  // Check if user has permission (role level >= required level)
  Future<bool> hasPermission(String userId, UserRole requiredRole) async {
    try {
      final userRole = await getUserHighestRole(userId);
      if (userRole == null) return false;
      
      return userRole.level >= requiredRole.level;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  // Promote user to higher role
  Future<bool> promoteUser(String userId, UserRole newRole) async {
    try {
      final currentRole = await getUserHighestRole(userId);
      if (currentRole != null && currentRole.level >= newRole.level) {
        return false; // Cannot promote to same or lower role
      }

      return await addUserRole(userId, newRole.name);
    } catch (e) {
      print('Error promoting user: $e');
      return false;
    }
  }

  // Demote user to lower role
  Future<bool> demoteUser(String userId, UserRole newRole) async {
    try {
      final currentRole = await getUserHighestRole(userId);
      if (currentRole != null && currentRole.level <= newRole.level) {
        return false; // Cannot demote to same or higher role
      }

      // Remove current highest role and add new role
      if (currentRole != null) {
        await removeUserRole(userId, currentRole.name);
      }
      return await addUserRole(userId, newRole.name);
    } catch (e) {
      print('Error demoting user: $e');
      return false;
    }
  }
}