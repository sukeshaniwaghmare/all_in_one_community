import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../search/presentation/search_screen.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Status',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const SearchScreen()
              ));
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          _buildMyStatus(),
          const Divider(height: 8, thickness: 8, color: Color(0xFFF0F0F0)),
          _buildRecentUpdates(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "text_status",
            mini: true,
            backgroundColor: Colors.grey[600],
            onPressed: () {},
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "camera_status",
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const CameraScreen()
              ));
            },
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMyStatus() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor,
                child: Text('M', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('Tap to add status update', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdates() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Recent updates', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ),
          ...List.generate(5, (index) => _buildStatusTile('User ${index + 1}', '${index + 1} minutes ago')),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String name, String time) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          child: Text(name[0], style: const TextStyle(fontSize: 18)),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }
}