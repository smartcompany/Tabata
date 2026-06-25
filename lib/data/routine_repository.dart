import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';
import '../services/routine_api_client.dart';

class RoutineRepository {
  RoutineRepository(this._prefs, this._apiClient);

  static const _localStorageKey = 'local_routines_v1';
  static const _listOrderKey = 'routine_list_order_v1';

  final SharedPreferences _prefs;
  final RoutineApiClient _apiClient;
  List<Routine> _remoteProfiles = [];
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

  List<Routine> get remoteProfiles => List.unmodifiable(_remoteProfiles);

  /// Fetches the server profile list and downloads any profile not yet stored locally.
  Future<void> refreshRemoteProfiles() async {
    final ids = await _apiClient.fetchProfileIds();
    _serverProfileIds = ids.toSet();

    final localById = {for (final routine in _loadLocal()) routine.id: routine};
    final remoteRoutines = <Routine>[];

    for (final id in ids) {
      final cached = localById[id];
      if (cached != null) {
        remoteRoutines.add(cached);
        continue;
      }

      final fetched = await _apiClient.fetchProfile(id);
      await upsert(fetched);
      remoteRoutines.add(fetched);
    }

    _remoteProfiles = remoteRoutines;
  }

  List<Routine> loadAll() {
    final local = _loadLocal();
    final localById = {for (final routine in local) routine.id: routine};
    final remoteIds = _remoteProfiles.map((routine) => routine.id).toSet();

    final merged = <Routine>[
      for (final remote in _remoteProfiles)
        localById[remote.id] ?? remote,
      for (final routine in local)
        if (!remoteIds.contains(routine.id)) routine,
    ];
    return _applyListOrder(merged);
  }

  Future<void> saveListOrder(List<String> orderedIds) async {
    await _prefs.setStringList(_listOrderKey, orderedIds);
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
    for (final routine in loadAll()) {
      if (routine.id == id) return routine;
    }
    return null;
  }

  bool isServerProfile(String id) => _serverProfileIds.contains(id);

  bool isRemoteProfile(String id) {
    return isServerProfile(id);
  }

  Future<Routine> rollbackToServer(String id) async {
    if (!_serverProfileIds.contains(id)) {
      throw StateError('Not a server profile: $id');
    }

    final fresh = await _apiClient.fetchProfile(id);
    await upsert(fresh);

    final index = _remoteProfiles.indexWhere((routine) => routine.id == id);
    if (index >= 0) {
      _remoteProfiles[index] = fresh;
    }

    return fresh;
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
