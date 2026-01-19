import 'package:flutter/material.dart';
import '../../community/domain/community_type.dart';
import '../provider/announcements_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class AnnouncementsScreen extends StatefulWidget {
  final CommunityType communityType;

  const AnnouncementsScreen({super.key, required this.communityType});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementsProvider>().loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Announcements',
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'filter', child: Text('Filter')),
              const PopupMenuItem(value: 'sort', child: Text('Sort By')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: Consumer<AnnouncementsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final announcement = provider.announcements[index];
              return _AnnouncementCard(announcement: announcement);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "announcements_fab",
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getPriorityColor(announcement.priority),
                  child: Icon(_getPriorityIcon(announcement.priority), color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('By ${announcement.author} • ${announcement.time}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(announcement.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement.priority.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getPriorityColor(announcement.priority)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(announcement.content, style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textPrimary)),
            if (announcement.hasAttachment) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text('Attachment.pdf', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Consumer<AnnouncementsProvider>(
                  builder: (context, provider, child) {
                    return TextButton.icon(
                      onPressed: () => provider.toggleLike(announcement.id),
                      icon: Icon(announcement.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 16, color: announcement.isLiked ? AppTheme.primaryColor : AppTheme.textSecondary),
                      label: Text('${announcement.likes}', style: TextStyle(color: announcement.isLiked ? AppTheme.primaryColor : AppTheme.textSecondary)),
                    );
                  },
                ),
                Consumer<AnnouncementsProvider>(
                  builder: (context, provider, child) {
                    return TextButton.icon(
                      onPressed: () => provider.addComment(announcement.id),
                      icon: const Icon(Icons.comment_outlined, size: 16, color: AppTheme.textSecondary),
                      label: Text('${announcement.comments}', style: const TextStyle(color: AppTheme.textSecondary)),
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 16, color: AppTheme.textSecondary),
                  label: const Text('Share', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return AppTheme.primaryColor;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Icons.priority_high;
      case 'medium': return Icons.info;
      case 'low': return Icons.info_outline;
      default: return Icons.campaign;
    }
  }
}