import 'routine.dart';

/// A routine stored on device, optionally forked from a server catalog entry.
class LocalRoutineRecord {
  const LocalRoutineRecord({
    required this.routine,
    this.forkedFromCatalogId,
    this.forkedFromOwnerId,
  });

  final Routine routine;
  final String? forkedFromCatalogId;
  final String? forkedFromOwnerId;

  LocalRoutineRecord copyWith({
    Routine? routine,
    String? forkedFromCatalogId,
    String? forkedFromOwnerId,
  }) {
    return LocalRoutineRecord(
      routine: routine ?? this.routine,
      forkedFromCatalogId: forkedFromCatalogId ?? this.forkedFromCatalogId,
      forkedFromOwnerId: forkedFromOwnerId ?? this.forkedFromOwnerId,
    );
  }

  Map<String, dynamic> toJson() => {
        'routine': routine.toJson(),
        if (forkedFromCatalogId != null)
          'forkedFromCatalogId': forkedFromCatalogId,
        if (forkedFromOwnerId != null) 'forkedFromOwnerId': forkedFromOwnerId,
      };

  factory LocalRoutineRecord.fromJson(Map<String, dynamic> json) {
    return LocalRoutineRecord(
      routine: Routine.fromJson(json['routine'] as Map<String, dynamic>),
      forkedFromCatalogId: json['forkedFromCatalogId'] as String?,
      forkedFromOwnerId: json['forkedFromOwnerId'] as String?,
    );
  }
}
