import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_routine_record.dart';
import '../models/profile_summary.dart';
import '../models/routine.dart';
import '../services/routine_api_client.dart';
import '../services/routine_description_media_service.dart';
import 'routine_fork.dart';

class RoutineRepository {
  RoutineRepository(this._prefs, this._apiClient);

  static const _legacyStorageKey = 'local_routines_v1';
  static const _recordsStorageKey = 'local_routine_records_v1';
  static const _listOrderKey = 'routine_list_order_v1';

  final SharedPreferences _prefs;
  final RoutineApiClient _apiClient;
  List<ProfileSummary> _officialSummaries = [];
  List<ProfileSummary> _sharedSummaries = [];
  Set<String> _catalogIds = {};
  List<LocalRoutineRecord> _records = [];

  static Future<RoutineRepository> create({
    RoutineApiClient? apiClient,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final repository = RoutineRepository(
      prefs,
      apiClient ?? RoutineApiClient(),
    );
    final migrated = repository._loadRecords();
    repository._records = migrated;
    if (prefs.getString(_recordsStorageKey) == null && migrated.isNotEmpty) {
      await repository._saveRecords();
    }
    return repository;
  }

  List<ProfileSummary> get officialCatalogSummaries =>
      List.unmodifiable(_officialSummaries);

  List<ProfileSummary> get sharedCatalogSummaries =>
      List.unmodifiable(_sharedSummaries);

  List<Routine> get myRoutines {
    final ordered = _applyListOrder(_records.map((r) => r.routine).toList());
    return ordered;
  }

  bool isCatalogId(String id) => _catalogIds.contains(id);

  bool isLocalRoutine(String id) =>
      _records.any((record) => record.routine.id == id);

  ProfileSummary? catalogSummaryFor(String catalogId) {
    for (final summary in [..._officialSummaries, ..._sharedSummaries]) {
      if (summary.id == catalogId) return summary;
    }
    return null;
  }

  int? catalogExerciseCount(String catalogId) =>
      catalogSummaryFor(catalogId)?.exerciseCount;

  LocalRoutineRecord? recordFor(String localRoutineId) {
    for (final record in _records) {
      if (record.routine.id == localRoutineId) return record;
    }
    return null;
  }

  List<Routine> myRoutinesForkedFromCatalog(String catalogId) => _records
      .where((record) => record.forkedFromCatalogId == catalogId)
      .map((record) => record.routine)
      .toList();

  bool hasDownloadedCatalog(String catalogId) =>
      myRoutinesForkedFromCatalog(catalogId).isNotEmpty;

  Future<Routine> fetchCatalogRoutine(String catalogId) async {
    if (!_catalogIds.contains(catalogId)) {
      throw StateError('Not a catalog profile: $catalogId');
    }
    return _apiClient.fetchProfile(catalogId);
  }

  /// Fetches server catalog metadata without downloading full routines.
  Future<void> refreshRemoteProfiles() async {
    final results = await Future.wait([
      _apiClient.fetchProfileSummaries(official: true),
      _apiClient.fetchProfileSummaries(official: false),
    ]);
    _officialSummaries = results[0]
        .where((summary) => summary.isOfficialCatalog)
        .toList();
    final officialIds = _officialSummaries.map((summary) => summary.id).toSet();
    _sharedSummaries = results[1]
        .where(
          (summary) =>
              summary.isSharedCatalog && !officialIds.contains(summary.id),
        )
        .toList();
    _catalogIds = {
      for (final summary in [..._officialSummaries, ..._sharedSummaries])
        summary.id,
    };
    await _reconcileForkMetadata();
  }

  Future<void> _reconcileForkMetadata() async {
    var changed = false;
    _records = _records.map((record) {
      if (record.forkedFromCatalogId != null) return record;
      if (!_catalogIds.contains(record.routine.id)) return record;
      changed = true;
      return record.copyWith(
        forkedFromCatalogId: record.routine.id,
        forkedFromOwnerId:
            summaryOwner(record.routine.id) ??
                ProfileSummary.officialCatalogOwner,
      );
    }).toList();
    if (changed) await _saveRecords();
  }

  /// Downloads a catalog entry and saves it locally as a new forked routine.
  Future<Routine> forkCatalogProfile(String catalogId) async {
    if (!_catalogIds.contains(catalogId)) {
      throw StateError('Not a catalog profile: $catalogId');
    }
    final summary = catalogSummaryFor(catalogId);
    if (summary == null) {
      throw StateError('Catalog summary missing: $catalogId');
    }

    final remote = await _apiClient.fetchProfile(catalogId);
    var forked = forkRoutine(remote);
    forked = await RoutineDescriptionMediaService().localizeDescriptionImages(
      forked,
    );
    final record = LocalRoutineRecord(
      routine: forked,
      forkedFromCatalogId: catalogId,
      forkedFromOwnerId: summary.ownerId,
    );
    await _upsertRecord(record);
    return forked;
  }

  String? summaryOwner(String catalogId) =>
      catalogSummaryFor(catalogId)?.ownerId;

  Routine? findById(String id) {
    for (final record in _records) {
      if (record.routine.id == id) return record.routine;
    }
    return null;
  }

  List<Routine> loadLocalOnly() => myRoutines;

  String? uploadedServerProfileIdFor(String localRoutineId) =>
      recordFor(localRoutineId)?.uploadedServerProfileId;

  /// Deep-clones [routine] with a new server profile id (or reuses [existingServerProfileId] to update).
  Routine copyForServerUpload(
    Routine routine, {
    String? existingServerProfileId,
    String? contentLanguage,
  }) {
    final forked = forkRoutine(routine, newRoutineId: existingServerProfileId);
    if (contentLanguage == null) return forked;
    return forked.copyWith(contentLanguage: contentLanguage);
  }

  Future<void> setUploadedServerProfileId({
    required String localRoutineId,
    required String serverProfileId,
  }) async {
    final record = recordFor(localRoutineId);
    if (record == null) return;
    await _upsertRecord(
      record.copyWith(uploadedServerProfileId: serverProfileId),
    );
  }

  Future<void> clearUploadedServerProfileLink(String serverProfileId) async {
    var changed = false;
    _records = _records.map((record) {
      if (record.uploadedServerProfileId != serverProfileId) return record;
      changed = true;
      return record.copyWith(clearUploadedServerProfileId: true);
    }).toList();
    if (changed) await _saveRecords();
  }

  Future<void> saveListOrder(List<String> orderedIds) async {
    await _prefs.setStringList(_listOrderKey, orderedIds);
  }

  List<String> localIdsInDisplayOrder(List<Routine> routines) {
    return [for (final routine in routines) routine.id];
  }

  Future<void> upsert(Routine routine) async {
    final existing = recordFor(routine.id);
    await _upsertRecord(
      LocalRoutineRecord(
        routine: routine,
        forkedFromCatalogId: existing?.forkedFromCatalogId,
        forkedFromOwnerId: existing?.forkedFromOwnerId,
        uploadedServerProfileId: existing?.uploadedServerProfileId,
      ),
    );
  }

  Future<void> delete(String id) async {
    _records = _records.where((record) => record.routine.id != id).toList();
    await _saveRecords();
    final order = _loadListOrder()..remove(id);
    await saveListOrder(order);
  }

  Routine catalogStub(ProfileSummary summary) {
    return Routine(
      id: summary.id,
      title: summary.title,
      description: summary.description,
      exercises: const [],
    );
  }

  Future<void> _upsertRecord(LocalRoutineRecord record) async {
    final index = _records.indexWhere(
      (item) => item.routine.id == record.routine.id,
    );
    if (index >= 0) {
      _records[index] = record;
    } else {
      _records.add(record);
      await _appendToListOrder(record.routine.id);
    }
    await _saveRecords();
  }

  List<String> _loadListOrder() => _prefs.getStringList(_listOrderKey) ?? [];

  Future<void> _appendToListOrder(String id) async {
    final order = _loadListOrder();
    if (order.contains(id)) return;
    await saveListOrder([...order, id]);
  }

  List<Routine> _applyListOrder(List<Routine> routines) {
    final order = _loadListOrder();
    if (order.isEmpty || routines.isEmpty) return routines;

    final byId = {for (final routine in routines) routine.id: routine};
    final result = <Routine>[];
    final seen = <String>{};

    for (final id in order) {
      final routine = byId[id];
      if (routine == null) continue;
      result.add(routine);
      seen.add(id);
    }
    for (final routine in routines) {
      if (!seen.contains(routine.id)) {
        result.add(routine);
      }
    }
    return result;
  }

  List<LocalRoutineRecord> _loadRecords() {
    final raw = _prefs.getString(_recordsStorageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (item) =>
                LocalRoutineRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    return _migrateLegacyRecords();
  }

  List<LocalRoutineRecord> _migrateLegacyRecords() {
    final raw = _prefs.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in list)
        LocalRoutineRecord(
          routine: Routine.fromJson(item as Map<String, dynamic>),
        ),
    ];
  }

  Future<void> _saveRecords() async {
    final encoded = jsonEncode(_records.map((record) => record.toJson()).toList());
    await _prefs.setString(_recordsStorageKey, encoded);
  }
}
