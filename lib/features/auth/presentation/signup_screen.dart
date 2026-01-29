import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/multi_role_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;
  final bool addRoleMode;

  const SignupScreen({
    super.key,
    this.extraData,
    this.addRoleMode = false,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _error;

  late bool _isAddRoleMode;

  @override
  void initState() {
    super.initState();
    final data = widget.extraData;

    _isAddRoleMode = widget.addRoleMode;

    _nameController = TextEditingController(text: data?['name'] ?? '');
    _emailController = TextEditingController(text: data?['email'] ?? '');
    _phoneController = TextEditingController(text: data?['phone'] ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= SIGNUP / ADD ROLE =================
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final supabase = Supabase.instance.client;

    try {
      // -------- ADD ROLE MODE --------
      if (_isAddRoleMode) {
        final user = supabase.auth.currentUser;
        if (user == null) {
          setState(() => _error = 'User not logged in');
          return;
        }

        final service = MultiRoleService();
        final success = await service.addUserRole(user.id, 'MEMBER');

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('MEMBER role added successfully')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() => _error = 'Failed to add role');
        }
        return;
      }

      // -------- NORMAL SIGNUP --------
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'MEMBER',
        },
      );

      if (response.user != null) {
        final service = MultiRoleService();
        await service.addUserRole(response.user!.id, 'MEMBER');
      }

      await supabase.auth.resend(
        type: OtpType.email,
        email: email,
      );

      if (!mounted) return;

      await _showConfirmationDialog(email);
      await supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showConfirmationDialog(String email) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verify your email'),
        content: Text(
          'Verification link sent to:\n\n$email',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add,
                    size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                _isAddRoleMode ? 'Add MEMBER Role' : 'Create Account',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join our community',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      _nameController,
                      'Full Name',
                      Icons.person_outline,
                      enabled: !_isAddRoleMode,
                      validator: (v) =>
                          !_isAddRoleMode && v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      _phoneController,
                      'Phone',
                      Icons.phone,
                      enabled: !_isAddRoleMode,
                      validator: (v) {
                        if (_isAddRoleMode) return null;
                        if (v == null || v.isEmpty) return 'Required';
                        if (!RegExp(r'^[0-9]{10,15}$').hasMatch(v)) {
                          return 'Invalid phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      _emailController,
                      'Email',
                      Icons.email_outlined,
                      enabled: !_isAddRoleMode,
                      validator: (v) =>
                          v!.contains('@') ? null : 'Invalid email',
                    ),

                    if (!_isAddRoleMode) ...[
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 16),
                      _buildConfirmPasswordField(),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],

                    const SizedBox(height: 24),
                    _buildButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String label,
    IconData icon, {
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      validator: (v) =>
          v != _passwordController.text ? 'Passwords do not match' : null,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () => setState(
              () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _isAddRoleMode ? 'Add Role' : 'Sign Up',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}