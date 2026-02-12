import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('New broadcast'),
      ),
      body: const Center(
        child: Text('Broadcast Screen'),
      ),
    );
  }
}
