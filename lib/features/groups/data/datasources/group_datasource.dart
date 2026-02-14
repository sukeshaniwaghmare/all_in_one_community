import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';

class GroupDataSource {
  final _supabase = Supabase.instance.client;

  Future<List<GroupModel>> fetchAllGroups() async {
    final response = await _supabase
        .from('groups')
        .select('*, group_members(count)')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      json['member_count'] = json['group_members']?[0]?['count'] ?? 0;
      return GroupModel.fromJson(json);
    }).toList();
  }

  Future<List<GroupModel>> fetchGroupsByCommunity(String communityId) async {
    final response = await _supabase
        .from('groups')
        .select('*, group_members(count)')
        .eq('community_id', communityId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      json['member_count'] = json['group_members']?[0]?['count'] ?? 0;
      return GroupModel.fromJson(json);
    }).toList();
  }
}
