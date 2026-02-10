import '../../domain/entities/member_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityDataSource dataSource;

  CommunityRepositoryImpl(this.dataSource);

  @override
  Future<List<MemberEntity>> getMembers() async {
    return await dataSource.fetchMembers();
  }

  @override
  Future<int> getMemberCount() async {
    return await dataSource.fetchMemberCount();
  }

  @override
  Future<List<GroupEntity>> getAllGroups() async {
    return await dataSource.fetchAllGroups();
  }

  @override
  Future<void> updateMemberRole({
    required String groupId,
    required String memberId,
    required String role,
  }) async {
    return await dataSource.updateMemberRole(
      groupId: groupId,
      memberId: memberId,
      role: role,
    );
  }
}
