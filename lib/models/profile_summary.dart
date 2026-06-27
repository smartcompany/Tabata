import '../utils/content_language.dart';

class ProfileSummary {
  const ProfileSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.exerciseCount,
    this.ownerId = officialCatalogOwner,
    this.ownerName,
    this.contentLanguage,
  });

  static const officialCatalogOwner = 'admin';

  final String id;
  final String title;
  final String description;
  final int exerciseCount;
  final String ownerId;
  final String? ownerName;
  final String? contentLanguage;

  bool get isOfficialCatalog => ownerId == officialCatalogOwner;

  bool get isSharedCatalog => !isOfficialCatalog;

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      exerciseCount: json['exerciseCount'] as int? ?? 0,
      ownerId: json['ownerId'] as String? ?? officialCatalogOwner,
      ownerName: json['ownerName'] as String?,
      contentLanguage: ContentLanguage.resolve(
        json['contentLanguage'] as String?,
      ),
    );
  }
}
