import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.description,
    required super.createdBy,
    required super.createdAt,
    super.memberCount,
    super.communityId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberCount: json['member_count'] ?? 0,
      communityId: json['community_id'] as String?,
    );
  }
}
