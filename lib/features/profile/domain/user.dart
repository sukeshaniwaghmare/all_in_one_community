class User {
  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final String? location;
  final String? role;
  final bool isDarkMode;
  final String language;
  final String? username;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.location,
    this.role,
    this.isDarkMode = false,
    this.language = 'English',
    this.username,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      phone: json['phone'],
      location: json['location'],
      role: json['role'],
      isDarkMode: json['is_dark_mode'] ?? false,
      language: json['language'] ?? 'English',
      username: json['username'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone': phone,
      'location': location,
      'role': role,
      'is_dark_mode': isDarkMode,
      'language': language,
      'username': username,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? bio,
    String? phone,
    String? location,
    String? role,
    bool? isDarkMode,
    String? language,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      role: role ?? this.role,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      username: username ?? this.username,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}