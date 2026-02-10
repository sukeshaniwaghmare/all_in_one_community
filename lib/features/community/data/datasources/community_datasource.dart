import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase_service.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';

class CommunityDataSource {
  final _supabase = SupabaseService.instance.client;

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

  Future<List<GroupModel>> fetchAllGroups() async {
    final response = await _supabase
        .from('groups')
        .select()
        .order('created_at', ascending: false);

    final groups = <GroupModel>[];
    
    for (var json in response as List) {
      final groupId = json['id'] as String;
      
      // Fetch member count for each group
      final memberCountResponse = await _supabase
          .from('group_members')
          .select('id')
          .eq('group_id', groupId)
          .count(CountOption.exact);
      
      groups.add(GroupModel.fromJson({
        ...json,
        'member_count': memberCountResponse.count ?? 0,
      }));
    }
    
    return groups;
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