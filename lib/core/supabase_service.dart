import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  // Auth methods
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;
  
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Database methods
  Future<List<Map<String, dynamic>>> select(String table) async {
    final response = await client.from(table).select();
    return response;
  }

  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  Future<Map<String, dynamic>> update(String table, String id, Map<String, dynamic> data) async {
    final response = await client.from(table).update(data).eq('id', id).select().single();
    return response;
  }

  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }
}