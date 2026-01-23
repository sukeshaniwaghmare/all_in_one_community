import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class LinkedDevicesScreen extends StatelessWidget {
  const LinkedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
        title: Text('Linked Devices', style: TextStyle(color: AppTheme.primaryColor)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.devices, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Use Community on other devices',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Link this account to use Community on other devices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _linkDevice(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Link a Device'),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Device Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.smartphone, color: Colors.green),
                  title: const Text('This Device'),
                  subtitle: const Text('Active now'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
                ListTile(
                  leading: const Icon(Icons.computer, color: Colors.grey),
                  title: const Text('Community Web'),
                  subtitle: const Text('Last seen 2 hours ago'),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showDeviceOptions(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _linkDevice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Device'),
        content: const Text('Scan QR code with your other device to link it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Device linking initiated')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showDeviceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Device logged out')),
              );
            },
          ),
        ],
      ),
    );
  }
}