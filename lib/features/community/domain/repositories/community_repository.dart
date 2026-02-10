import '../entities/member_entity.dart';
import '../entities/group_entity.dart';

abstract class CommunityRepository {
  Future<List<MemberEntity>> getMembers();
  Future<int> getMemberCount();
  Future<List<GroupEntity>> getAllGroups();
  Future<void> updateMemberRole({
    required String groupId,
    required String memberId,
    required String role,
  });
}
