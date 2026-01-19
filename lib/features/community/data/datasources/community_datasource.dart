import '../../../community/provider/community_provider.dart';

class CommunityDataSource {
  static List<Member> getMockMembers() {
    return [
      Member(
        id: '1',
        name: 'John Doe',
        role: 'Admin',
        avatar: 'JD',
        isOnline: true,
      ),
      Member(
        id: '2',
        name: 'Jane Smith',
        role: 'Moderator',
        avatar: 'JS',
        isOnline: false,
      ),
      Member(
        id: '3',
        name: 'Mike Wilson',
        role: 'Member',
        avatar: 'MW',
        isOnline: true,
      ),
      Member(
        id: '4',
        name: 'Sarah Johnson',
        role: 'Member',
        avatar: 'SJ',
        isOnline: false,
      ),
    ];
  }

  static Future<List<Member>> fetchMembers() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return getMockMembers();
  }

  static Future<int> fetchMemberCount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 1234;
  }
}