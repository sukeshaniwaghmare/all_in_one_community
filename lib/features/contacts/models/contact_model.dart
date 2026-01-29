class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isAppUser;
  final String? profileImage;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isAppUser = false,
    this.profileImage,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      isAppUser: json['isAppUser'] ?? false,
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'isAppUser': isAppUser,
      'profileImage': profileImage,
    };
  }

  // Add copyWith method here
  Contact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    bool? isAppUser,
    String? profileImage,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAppUser: isAppUser ?? this.isAppUser,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}