class User {
  final String id;
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const User({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['user_id']) as String,
      fullName: (json['full_name'] as String?) ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
