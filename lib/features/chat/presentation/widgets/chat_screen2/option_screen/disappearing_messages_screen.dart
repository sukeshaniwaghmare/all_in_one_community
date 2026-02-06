import 'package:flutter/material.dart';

class DisappearingMessagesScreen extends StatelessWidget {
  const DisappearingMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disappearing messages'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Off'),
            trailing: Radio(value: 0, groupValue: 0, onChanged: (v) {}),
          ),
          ListTile(
            title: const Text('24 hours'),
            trailing: Radio(value: 1, groupValue: 0, onChanged: (v) {}),
          ),
          ListTile(
            title: const Text('7 days'),
            trailing: Radio(value: 2, groupValue: 0, onChanged: (v) {}),
          ),
          ListTile(
            title: const Text('90 days'),
            trailing: Radio(value: 3, groupValue: 0, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}
