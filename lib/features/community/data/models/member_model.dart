import '../../domain/entities/member_entity.dart';

class MemberModel extends MemberEntity {
  const MemberModel({
    required super.id,
    required super.name,
    required super.role,
    required super.avatar,
    super.isOnline,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? 'User',
      role: 'Member',
      avatar: (json['full_name'] as String?)?.substring(0, 2).toUpperCase() ?? 'U',
      isOnline: false,
    );
  }
}
