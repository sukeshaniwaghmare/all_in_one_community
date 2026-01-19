import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class SecurityCodeScreen extends StatelessWidget {
  final String contactName;
  
  const SecurityCodeScreen({super.key, required this.contactName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(title: 'Security Code'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Verify security code with $contactName',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code, size: 150, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Security Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  '12345 67890 12345 67890 12345 67890',
                  style: TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Compare this code with the one on your contact\'s phone to verify that your messages are end-to-end encrypted.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
              title: const Text('Learn more'),
              subtitle: const Text('About end-to-end encryption'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Learn more about encryption')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}