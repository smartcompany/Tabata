import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';
import '../services/routine_api_client.dart';

class RoutineRepository {
  RoutineRepository(this._prefs, this._apiClient);

  static const _localStorageKey = 'local_routines_v1';

  final SharedPreferences _prefs;
  final RoutineApiClient _apiClient;
  List<Routine> _remoteProfiles = [];

  static Future<RoutineRepository> create({
    RoutineApiClient? apiClient,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return RoutineRepository(
      prefs,
      apiClient ?? RoutineApiClient(),
    );
  }

  List<Routine> get remoteProfiles => List.unmodifiable(_remoteProfiles);

  Future<void> refreshRemoteProfiles() async {
    _remoteProfiles = await _apiClient.fetchAllProfiles();
  }

  List<Routine> loadAll() {
    final local = _loadLocal();
    final localById = {for (final routine in local) routine.id: routine};
    final remoteIds = _remoteProfiles.map((routine) => routine.id).toSet();

    final result = <Routine>[
      for (final remote in _remoteProfiles)
        localById[remote.id] ?? remote,
      for (final routine in local)
        if (!remoteIds.contains(routine.id)) routine,
    ];
    return result;
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
    }
    await saveAllLocal(routines);
  }

  Future<void> delete(String id) async {
    final routines = _loadLocal()..removeWhere((r) => r.id == id);
    await saveAllLocal(routines);
  }

  Routine? findById(String id) {
    for (final routine in loadAll()) {
      if (routine.id == id) return routine;
    }
    return null;
  }

  bool isRemoteProfile(String id) {
    return _remoteProfiles.any((routine) => routine.id == id) &&
        !_loadLocal().any((routine) => routine.id == id);
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
