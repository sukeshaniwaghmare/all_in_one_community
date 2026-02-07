import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisappearingMessagesScreen extends StatefulWidget {
  const DisappearingMessagesScreen({super.key});

  @override
  State<DisappearingMessagesScreen> createState() => _DisappearingMessagesScreenState();
}

class _DisappearingMessagesScreenState extends State<DisappearingMessagesScreen> {
  int _selectedOption = 0; // 0=Off, 1=24h, 2=7d, 3=90d
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption = prefs.getInt('disappearing_messages') ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('disappearing_messages', value);
  }

  String _getDurationText(int option) {
    switch (option) {
      case 1:
        return '24 hours';
      case 2:
        return '7 days';
      case 3:
        return '90 days';
      default:
        return 'Off';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Disappearing messages'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disappearing messages'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.grey[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Messages will disappear after the selected time',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Off'),
            trailing: Radio(
              value: 0,
              groupValue: _selectedOption,
              onChanged: (value) async {
                setState(() => _selectedOption = value as int);
                await _saveSetting(value as int);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Disappearing messages turned off'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('24 hours'),
            trailing: Radio(
              value: 1,
              groupValue: _selectedOption,
              onChanged: (value) async {
                setState(() => _selectedOption = value as int);
                await _saveSetting(value as int);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messages will disappear after 24 hours'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('7 days'),
            trailing: Radio(
              value: 2,
              groupValue: _selectedOption,
              onChanged: (value) async {
                setState(() => _selectedOption = value as int);
                await _saveSetting(value as int);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messages will disappear after 7 days'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('90 days'),
            trailing: Radio(
              value: 3,
              groupValue: _selectedOption,
              onChanged: (value) async {
                setState(() => _selectedOption = value as int);
                await _saveSetting(value as int);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messages will disappear after 90 days'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
