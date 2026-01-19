import '../../../announcements/provider/announcements_provider.dart';

class AnnouncementsDataSource {
  static List<Announcement> getMockAnnouncements() {
    return [
      Announcement(
        id: '1',
        title: 'Monthly Maintenance Due',
        content: 'Dear residents, please note that the monthly maintenance fee is due by the end of this month.',
        author: 'Society Admin',
        time: '2 hours ago',
        priority: 'high',
        likes: 12,
        comments: 3,
        hasAttachment: true,
      ),
      Announcement(
        id: '2',
        title: 'Water Supply Interruption',
        content: 'Water supply will be interrupted tomorrow from 10 AM to 2 PM for maintenance work.',
        author: 'Maintenance Team',
        time: '5 hours ago',
        priority: 'medium',
        likes: 8,
        comments: 1,
      ),
      Announcement(
        id: '3',
        title: 'Community Event - Diwali Celebration',
        content: 'Join us for the annual Diwali celebration in the community hall.',
        author: 'Event Committee',
        time: '1 day ago',
        priority: 'low',
        likes: 25,
        comments: 7,
        isLiked: true,
      ),
    ];
  }

  static Future<List<Announcement>> fetchAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return getMockAnnouncements();
  }
}