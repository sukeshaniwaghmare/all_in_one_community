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
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().user;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

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
            title: 'Your channel',
            child: _actionRow(
              value: 'Personal channel',
              action: 'Add',
              onTap: () {},
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
            footer:
                'You can add a few lines about yourself. Choose who can see your bio in Settings.',
          ),

          _divider(),

          _section(
            title: 'Your birthday',
            child: _actionRow(
              value: 'Birthday',
              action: 'Add',
              onTap: () {},
            ),
            footer: 'Only your contacts can see your birthday.',
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

  // 🔹 Action row (Add / Change)
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
          name: _nameController.text,
          bio: _bioController.text,
        );
  }
}
