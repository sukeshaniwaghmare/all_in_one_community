import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase_service.dart';
import '../models/member_model.dart';
import '../models/community_model.dart';
import '../../../groups/data/models/group_model.dart' as groupsModel;

class CommunityDataSource {
  final _supabase = SupabaseService.instance.client;

  Future<List<CommunityModel>> fetchAllCommunities() async {
    final response = await _supabase
        .from('communities')
        .select()
        .order('created_at', ascending: false);

    print('Fetched communities: $response');
    
    return (response as List)
        .map((json) => CommunityModel.fromJson({
          ...json,
          'member_count': json['member_count'] ?? 0,
        }))
        .toList();
  }

  Future<List<groupsModel.GroupModel>> fetchGroupsByCommunity(String communityId) async {
    try {
      final response = await _supabase
          .from('groups')
          .select('*')
          .eq('community_id', communityId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => groupsModel.GroupModel.fromJson({
            ...json,
            'member_count': json['member_count'] ?? 0,
          }))
          .toList();
    } catch (e) {
      print('Error fetching groups: $e');
      return [];
    }
  }

  Future<List<MemberModel>> fetchMembers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .limit(50);

      return (response as List)
          .map((json) => MemberModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }

  Future<int> fetchMemberCount() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .count(CountOption.exact);
      return response.count ?? 0;
    } catch (e) {
      print('Error fetching member count: $e');
      return 0;
    }
  }

  Future<List<groupsModel.GroupModel>> fetchAllGroups() async {
    final response = await _supabase
        .from('groups')
        .select()
        .order('created_at', ascending: false);

    final groupsList = <groupsModel.GroupModel>[];
    
    for (var json in response as List) {
      final groupId = json['id'] as String;
      
      final memberCountResponse = await _supabase
          .from('group_members')
          .select('id')
          .eq('group_id', groupId)
          .count(CountOption.exact);
      
      groupsList.add(groupsModel.GroupModel.fromJson({
        ...json,
        'member_count': memberCountResponse.count ?? 0,
      }));
    }
    
    return groupsList;
  }

  Future<void> updateMemberRole({
    required String groupId,
    required String memberId,
    required String role,
  }) async {
    await _supabase
        .from('group_members')
        .update({'role': role})
        .eq('group_id', groupId)
        .eq('user_id', memberId);
  }
}