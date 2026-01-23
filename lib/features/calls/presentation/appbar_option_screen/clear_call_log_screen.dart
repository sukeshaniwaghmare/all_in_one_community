import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ClearCallLogScreen extends StatefulWidget {
  const ClearCallLogScreen({super.key});

  @override
  State<ClearCallLogScreen> createState() => _ClearCallLogScreenState();
}

class _ClearCallLogScreenState extends State<ClearCallLogScreen> {
  final List<Map<String, dynamic>> _callLogs = [
    {'name': 'Mom', 'time': '2 minutes ago', 'type': 'incoming'},
    {'name': 'Dad', 'time': '1 hour ago', 'type': 'outgoing'},
    {'name': 'Best Friend', 'time': 'Yesterday', 'type': 'missed'},
    {'name': 'Office', 'time': 'Yesterday', 'type': 'outgoing'},
    {'name': 'Brother', 'time': '2 days ago', 'type': 'incoming'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
        title: Text('Clear Call Log', style: TextStyle(color: AppTheme.primaryColor)),
        actions: [
          TextButton(
            onPressed: _callLogs.isNotEmpty ? _showClearDialog : null,
            child: Text('CLEAR ALL', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
      body: _callLogs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No call logs', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _callLogs.length,
              itemBuilder: (context, index) {
                final call = _callLogs[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(call['name'][0]),
                  ),
                  title: Text(call['name']),
                  subtitle: Text(call['time']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCallLog(index),
                  ),
                );
              },
            ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Call Log'),
        content: const Text('Are you sure you want to clear all call logs? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllLogs();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearAllLogs() {
    setState(() => _callLogs.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All call logs cleared')),
    );
  }

  void _deleteCallLog(int index) {
    setState(() => _callLogs.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call log deleted')),
    );
  }
}