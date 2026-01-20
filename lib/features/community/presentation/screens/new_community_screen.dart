import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class NewCommunityScreen extends StatefulWidget {
  const NewCommunityScreen({super.key});

  @override
  State<NewCommunityScreen> createState() => _NewCommunityScreenState();
}

class _NewCommunityScreenState extends State<NewCommunityScreen> {
  final TextEditingController _communityNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('New Community'),
        actions: [
          TextButton(
            onPressed: _communityNameController.text.isNotEmpty ? _createCommunity : null,
            child: const Text('CREATE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Icon
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Community Name
            TextField(
              controller: _communityNameController,
              decoration: const InputDecoration(
                labelText: 'Community name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Guidelines
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community Guidelines',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Be respectful to all members'),
                  Text('• No spam or promotional content'),
                  Text('• Stay on topic'),
                  Text('• No hate speech or harassment'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Privacy Settings
            const Text(
              'Privacy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Public'),
              subtitle: const Text('Anyone can find and join this community'),
              trailing: Radio(
                value: true,
                groupValue: true,
                onChanged: (_) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Private'),
              subtitle: const Text('Only invited members can join'),
              trailing: Radio(
                value: false,
                groupValue: true,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createCommunity() {
    if (_communityNameController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community "${_communityNameController.text}" created')),
      );
      Navigator.pop(context);
    }
  }
}