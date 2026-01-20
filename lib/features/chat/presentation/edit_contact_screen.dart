import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class EditContactScreen extends StatefulWidget {
  final String contactName;
  
  const EditContactScreen({super.key, required this.contactName});

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.contactName;
    _phoneController.text = '+1 234 567 8900';
    _emailController.text = 'contact@example.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Edit Contact',
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  enabled: true,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveContact() {
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newEmail = _emailController.text.trim();
    
    
    // Return the updated data back to previous screen
    Navigator.pop(context, {
      'name': newName,
      'phone': newPhone,
      'email': newEmail,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact updated successfully')),
    );
  }
}