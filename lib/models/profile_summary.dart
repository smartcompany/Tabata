class ProfileSummary {
  const ProfileSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.exerciseCount,
  });

  final String id;
  final String title;
  final String description;
  final int exerciseCount;

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      exerciseCount: json['exerciseCount'] as int? ?? 0,
    );
  }
}
