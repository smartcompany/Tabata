import 'routine.dart';

/// A routine stored on device, optionally forked from a server catalog entry.
class LocalRoutineRecord {
  const LocalRoutineRecord({
    required this.routine,
    this.forkedFromCatalogId,
    this.forkedFromOwnerId,
    this.uploadedServerProfileId,
  });

  final Routine routine;
  final String? forkedFromCatalogId;
  final String? forkedFromOwnerId;
  /// Server copy id when this local routine was uploaded (local id stays unchanged).
  final String? uploadedServerProfileId;

  LocalRoutineRecord copyWith({
    Routine? routine,
    String? forkedFromCatalogId,
    String? forkedFromOwnerId,
    String? uploadedServerProfileId,
    bool clearUploadedServerProfileId = false,
  }) {
    return LocalRoutineRecord(
      routine: routine ?? this.routine,
      forkedFromCatalogId: forkedFromCatalogId ?? this.forkedFromCatalogId,
      forkedFromOwnerId: forkedFromOwnerId ?? this.forkedFromOwnerId,
      uploadedServerProfileId: clearUploadedServerProfileId
          ? null
          : (uploadedServerProfileId ?? this.uploadedServerProfileId),
    );
  }

  Map<String, dynamic> toJson() => {
        'routine': routine.toJson(),
        if (forkedFromCatalogId != null)
          'forkedFromCatalogId': forkedFromCatalogId,
        if (forkedFromOwnerId != null) 'forkedFromOwnerId': forkedFromOwnerId,
        if (uploadedServerProfileId != null)
          'uploadedServerProfileId': uploadedServerProfileId,
      };

  factory LocalRoutineRecord.fromJson(Map<String, dynamic> json) {
    return LocalRoutineRecord(
      routine: Routine.fromJson(json['routine'] as Map<String, dynamic>),
      forkedFromCatalogId: json['forkedFromCatalogId'] as String?,
      forkedFromOwnerId: json['forkedFromOwnerId'] as String?,
      uploadedServerProfileId: json['uploadedServerProfileId'] as String?,
    );
  }
}
