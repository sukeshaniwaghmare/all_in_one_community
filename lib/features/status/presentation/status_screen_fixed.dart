import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppTopBar(
        title: 'Status',
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          _buildMyStatus(),
          Container(height: 8, color: const Color(0xFFF0F2F5)),
          _buildRecentUpdates(),
          Container(height: 8, color: const Color(0xFFF0F2F5)),
          _buildViewedUpdates(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF54656F),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyStatus() {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: const CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryColor,
                child: Text('M', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
        title: const Text('My status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        subtitle: const Text('Tap to add status update', style: TextStyle(color: Color(0xFF667781), fontSize: 14)),
        onTap: () {},
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
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Recent updates', style: TextStyle(color: Color(0xFF667781), fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          ...List.generate(3, (index) => _buildStatusTile(
            'Contact ${index + 1}',
            '${index + 2} minutes ago',
            hasUpdate: true,
          )),
        ],
      ),
    );
  }

  Widget _buildViewedUpdates() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Viewed updates', style: TextStyle(color: Color(0xFF667781), fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          ...List.generate(2, (index) => _buildStatusTile(
            'Contact ${index + 4}',
            'Today, ${index + 1}:30 PM',
            hasUpdate: false,
          )),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String name, String time, {required bool hasUpdate}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasUpdate ? const Color(0xFF25D366) : Colors.grey[300]!,
            width: hasUpdate ? 2.5 : 1,
          ),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: _getAvatarColor(name),
          child: Text(
            name[0],
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(color: Color(0xFF667781), fontSize: 14),
      ),
      onTap: () {},
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF7C4DFF),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}