import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditInfoScreen extends StatefulWidget {
  final String groupName;
  final String? description;
  final String? groupId;
  
  const EditInfoScreen({
    super.key,
    required this.groupName,
    this.description,
    this.groupId,
  });

  @override
  State<EditInfoScreen> createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.groupName);
    _descriptionController = TextEditingController(text: widget.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF128C7E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Group Info', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFDADADA),
                        backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                        child: _profileImage == null ? const Icon(Icons.group, size: 60, color: Colors.white) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF128C7E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF128C7E), width: 2)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF128C7E), width: 2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  void _saveChanges() async {
    final newName = _nameController.text.trim();
    final newDescription = _descriptionController.text.trim();
    
    if (newName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group name cannot be empty')),
        );
      }
      return;
    }
    
    print('📝 Saving changes...');
    print('   Group ID: ${widget.groupId}');
    print('   Old Name: ${widget.groupName}');
    print('   New Name: $newName');
    
    try {
      String? avatarUrl;
      
      // Upload avatar if selected
      if (_profileImage != null) {
        print('📤 Uploading avatar...');
        final file = File(_profileImage!.path);
        final fileName = 'groups/${widget.groupId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        await Supabase.instance.client.storage
            .from('chat-media')
            .upload(fileName, file);
        
        avatarUrl = Supabase.instance.client.storage
            .from('chat-media')
            .getPublicUrl(fileName);
        
        print('✅ Avatar uploaded: $avatarUrl');
      }
      
      if (widget.groupId != null && widget.groupId!.isNotEmpty) {
        print('🔄 Updating group in Supabase...');
        
        final updateData = {
          'name': newName,
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        if (avatarUrl != null) {
          updateData['avatar_url'] = avatarUrl;
        }
        
        final response = await Supabase.instance.client
            .from('groups')
            .update(updateData)
            .eq('id', widget.groupId!)
            .select();
        
        print('✅ Supabase response: $response');
      } else {
        print('⚠️ No valid groupId provided: ${widget.groupId}');
      }
    } catch (e) {
      print('❌ Error updating Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving changes: $e')),
        );
      }
      return;
    }
    
    if (mounted) {
      Navigator.pop(context, {
        'name': newName,
        'description': newDescription,
        'groupId': widget.groupId,
      });
    }
  }
}
