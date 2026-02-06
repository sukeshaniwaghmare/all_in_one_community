import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../../../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          _section(
            title: 'Your name',
            child: _editableRow(
              controller: _nameController,
              hint: 'Enter name',
            ),
          ),

          _divider(),

          _section(
            title: 'Phone',
            child: _editableRow(
              controller: _phoneController,
              hint: 'Enter phone number',
            ),
          ),

          _divider(),

          _section(
            title: 'Email',
            child: _editableRow(
              controller: _emailController,
              hint: 'Enter email',
            ),
          ),

          _divider(),

          _section(
            title: 'Location',
            child: _editableRow(
              controller: _locationController,
              hint: 'Enter location',
            ),
          ),

          _divider(),

          _section(
            title: 'Your bio',
            child: _editableRow(
              controller: _bioController,
              hint: 'Add a few words about yourself',
              maxLength: 50,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Section Wrapper
  Widget _section({
    required String title,
    required Widget child,
    String? footer,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          child,
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(
              footer,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // 🔹 Editable text row
  Widget _editableRow({
    required TextEditingController controller,
    required String hint,
    int? maxLength,
    String? prefix,
  }) {
    return Row(
      children: [
        if (prefix != null)
          Text(prefix, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Expanded(
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16),
            onSubmitted: (_) => _saveProfile(),
          ),
        ),
      ],
    );
  }

  //  Action row (Add / Change)
  Widget _actionRow({
    required String value,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 1);
  }

  void _saveProfile() {
    context.read<ProfileProvider>().updateProfile(
          fullName: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          location: _locationController.text,
          bio: _bioController.text,
        );
    Navigator.pop(context);
  }
}
