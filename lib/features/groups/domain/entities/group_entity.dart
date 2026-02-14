class GroupEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? description;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final String? communityId;

  const GroupEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.description,
    required this.createdBy,
    required this.createdAt,
    this.memberCount = 0,
    this.communityId,
  });
}
