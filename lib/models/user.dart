enum UserRole { admin, editor, viewer }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.admin,
    this.avatarUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get canEdit => role == UserRole.admin || role == UserRole.editor;
  bool get canDelete => role == UserRole.admin;
  bool get canManageUsers => role == UserRole.admin;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.index,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: UserRole.values[json['role']],
        avatarUrl: json['avatarUrl'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
