class MemberEntity {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final bool isOnline;

  const MemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    this.isOnline = false,
  });
}
