class CommunityEntity {
  final String id;
  final String name;
  final String? description;
  final String type;
  final String? icon;
  final String createdBy;
  final int memberCount;
  final bool isPublic;
  final DateTime createdAt;

  const CommunityEntity({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.icon,
    required this.createdBy,
    this.memberCount = 0,
    this.isPublic = true,
    required this.createdAt,
  });
}
