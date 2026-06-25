import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_summary.dart';
import '../models/routine.dart';
import '../services/routine_api_client.dart';

class RoutineRepository {
  RoutineRepository(this._prefs, this._apiClient);

  static const _localStorageKey = 'local_routines_v1';
  static const _listOrderKey = 'routine_list_order_v1';

  final SharedPreferences _prefs;
  final RoutineApiClient _apiClient;
  List<ProfileSummary> _officialSummaries = [];
  List<ProfileSummary> _sharedSummaries = [];
  Set<String> _serverProfileIds = {};

  static Future<RoutineRepository> create({
    RoutineApiClient? apiClient,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return RoutineRepository(
      prefs,
      apiClient ?? RoutineApiClient(),
    );
  }

  List<ProfileSummary> get catalogSummaries =>
      List.unmodifiable(_officialSummaries);

  List<ProfileSummary> get sharedCatalogSummaries =>
      List.unmodifiable(_sharedSummaries);

  /// Fetches server catalog metadata without downloading full routines.
  Future<void> refreshRemoteProfiles() async {
    final results = await Future.wait([
      _apiClient.fetchProfileSummaries(official: true),
      _apiClient.fetchProfileSummaries(official: false),
    ]);
    _officialSummaries = results[0];
    _sharedSummaries = results[1];
    _serverProfileIds = {
      for (final summary in [..._officialSummaries, ..._sharedSummaries])
        summary.id,
    };
  }

  bool isServerProfile(String id) => _serverProfileIds.contains(id);

  bool isDownloadedLocally(String id) {
    return _loadLocal().any((routine) => routine.id == id);
  }

  bool isCatalogStub(Routine routine) {
    return isServerProfile(routine.id) && !isDownloadedLocally(routine.id);
  }

  Future<Routine> downloadCatalogProfile(String id) async {
    if (!_serverProfileIds.contains(id)) {
      throw StateError('Not a catalog profile: $id');
    }
    final routine = await _apiClient.fetchProfile(id);
    await upsert(routine);
    return routine;
  }

  List<Routine> loadAll({bool official = true}) {
    final summaries =
        official ? _officialSummaries : _sharedSummaries;
    final local = _loadLocal();
    final localById = {for (final routine in local) routine.id: routine};

    final downloaded = <Routine>[];
    final undownloaded = <Routine>[];

    for (final summary in summaries) {
      final cached = localById[summary.id];
      if (cached != null) {
        downloaded.add(cached);
      } else {
        undownloaded.add(_stubFromSummary(summary));
      }
    }

    if (official) {
      for (final routine in local) {
        if (!_serverProfileIds.contains(routine.id)) {
          downloaded.add(routine);
        }
      }
    }

    return [
      ..._applyListOrder(downloaded),
      ...undownloaded,
    ];
  }

  Future<void> saveListOrder(List<String> orderedIds) async {
    await _prefs.setStringList(_listOrderKey, orderedIds);
  }

  List<String> downloadedIdsInDisplayOrder(List<Routine> routines) {
    return [
      for (final routine in routines)
        if (isDownloadedLocally(routine.id)) routine.id,
    ];
  }

  List<Routine> loadLocalOnly() => _loadLocal();

  Future<void> saveAllLocal(List<Routine> routines) async {
    final encoded = jsonEncode(routines.map((r) => r.toJson()).toList());
    await _prefs.setString(_localStorageKey, encoded);
  }

  Future<void> upsert(Routine routine) async {
    final routines = _loadLocal();
    final index = routines.indexWhere((r) => r.id == routine.id);
    if (index >= 0) {
      routines[index] = routine;
    } else {
      routines.add(routine);
      await _appendToListOrder(routine.id);
    }
    await saveAllLocal(routines);
  }

  Future<void> delete(String id) async {
    final routines = _loadLocal()..removeWhere((r) => r.id == id);
    await saveAllLocal(routines);
    final order = _loadListOrder()..remove(id);
    await saveListOrder(order);
  }

  Routine? findById(String id) {
    for (final routine in _loadLocal()) {
      if (routine.id == id) return routine;
    }
    for (final summary in [..._officialSummaries, ..._sharedSummaries]) {
      if (summary.id == id) return _stubFromSummary(summary);
    }
    return null;
  }

  int? catalogExerciseCount(String id) {
    for (final summary in [..._officialSummaries, ..._sharedSummaries]) {
      if (summary.id == id) return summary.exerciseCount;
    }
    return null;
  }

  Future<Routine> rollbackToServer(String id) async {
    if (!_serverProfileIds.contains(id)) {
      throw StateError('Not a server profile: $id');
    }

    final fresh = await _apiClient.fetchProfile(id);
    await upsert(fresh);
    return fresh;
  }

  Routine _stubFromSummary(ProfileSummary summary) {
    return Routine(
      id: summary.id,
      title: summary.title,
      description: summary.description,
      exercises: const [],
    );
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

  List<Routine> _loadLocal() {
    final raw = _prefs.getString(_localStorageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Routine.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
