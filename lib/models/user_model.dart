class AppUser {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.bio,
    required this.isOnline,
    required this.lastSeen,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        isOnline: json['is_online'] as bool? ?? false,
        lastSeen: DateTime.parse(json['last_seen'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
        'bio': bio,
        'is_online': isOnline,
        'last_seen': lastSeen.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
