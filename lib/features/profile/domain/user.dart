class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? profileImage;
  final String? phone;
  final String? bio;
  final bool isDarkMode;
  final String language;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.profileImage,
    this.phone,
    this.bio,
    this.isDarkMode = false,
    this.language = 'English',
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatar,
    String? profileImage,
    String? phone,
    String? bio,
    bool? isDarkMode,
    String? language,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }
}