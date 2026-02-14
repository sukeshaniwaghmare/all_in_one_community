import '../../domain/entities/community_entity.dart';

class CommunityModel extends CommunityEntity {
  const CommunityModel({
    required super.id,
    required super.name,
    super.description,
    required super.type,
    super.icon,
    required super.createdBy,
    super.memberCount,
    super.isPublic,
    required super.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      createdBy: json['created_by'] as String,
      memberCount: json['member_count'] ?? 0,
      isPublic: json['is_public'] ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
