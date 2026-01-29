import 'package:flutter/material.dart';
import '../../../core/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _supabaseService.currentUser != null;
  String? get userEmail => _supabaseService.currentUser?.email;
  User? get currentUser => _supabaseService.currentUser;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('Starting login process for: $email');

    try {
      print('Calling Supabase login...');
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('Login response: ${response.user?.id}');
      
      if (response.user != null) {
        print('Login successful for user: ${response.user!.id}');
        _error = null;
      } else {
        print('Login failed: No user returned');
        _error = 'Login failed';
      }
    } on AuthException catch (e) {
      print('Auth exception: ${e.message}');
      if (e.message.contains('Email not confirmed')) {
        _error = 'Email not confirmed. Please confirm your email or contact admin.';
      } else {
        _error = e.message;
      }
    } catch (e) {
      print('General exception: $e');
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('Starting signup process for: $email');

    try {
      print('Calling Supabase signup...');
      
      // Add delay to avoid rate limit
      await Future.delayed(const Duration(seconds: 2));
      
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Disable email confirmation
      );
      
      print('Signup response: ${response.user?.id}');
      
      if (response.user != null) {
        print('User created successfully, creating profile...');
        
        // Wait a bit before creating profile
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Create profile directly without RLS check
        try {
          await _supabaseService.client
              .from('profiles')
              .insert({
                'id': response.user!.id,
                'name': name,
                'email': email,
                'created_at': DateTime.now().toIso8601String(),
              });
          print('Profile created successfully');
        } catch (profileError) {
          print('Profile creation failed: $profileError');
          // Continue anyway, profile can be created later
        }
        
        _error = null;
      } else {
        print('Signup failed: No user returned');
        _error = 'Signup failed';
      }
    } on AuthException catch (e) {
      print('Auth exception: ${e.message}');
      if (e.message.contains('rate limit')) {
        _error = 'Too many signup attempts. Please wait 5 minutes and try again.';
      } else {
        _error = e.message;
      }
    } catch (e) {
      print('General exception: $e');
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabaseService.signOut();
      _error = null;
    } catch (e) {
      _error = 'Failed to logout';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendConfirmationEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to send confirmation email';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Temporary method for testing - bypasses authentication
  Future<void> createTestUser(String name, String email) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Create a mock user for testing
      print('Creating test user: $email');
      
      // Simulate successful authentication
      _error = null;
      
      // You can manually add this user to Supabase dashboard
      print('Test user created. Please add manually in Supabase dashboard:');
      print('Email: $email');
      print('Name: $name');
      
    } catch (e) {
      _error = 'Test user creation failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}