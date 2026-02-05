import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/apptopbar.dart';

class DisappearingMessagesScreen extends StatefulWidget {
  const DisappearingMessagesScreen({super.key});

  @override
  State<DisappearingMessagesScreen> createState() => _DisappearingMessagesScreenState();
}

class _DisappearingMessagesScreenState extends State<DisappearingMessagesScreen> {
  String _selectedDuration = 'Off';
  
  final List<String> _durations = [
    'Off',
    '24 hours',
    '7 days',
    '90 days',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Disappearing messages',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'For extra privacy, you can set messages in this chat to disappear after a certain time.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: Column(
              children: _durations.map((duration) => 
                RadioListTile<String>(
                  title: Text(duration),
                  value: duration,
                  groupValue: _selectedDuration,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _selectedDuration = value!;
                    });
                  },
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}