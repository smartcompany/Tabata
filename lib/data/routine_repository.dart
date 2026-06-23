import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_routines.dart';
import '../models/routine.dart';

class RoutineRepository {
  RoutineRepository(this._prefs);

  static const _storageKey = 'routines_v2';
  static const _seededKey = 'routines_seeded_v2';

  final SharedPreferences _prefs;

  static Future<RoutineRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = RoutineRepository(prefs);
    await repo._ensureSeed();
    return repo;
  }

  List<Routine> loadAll() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Routine.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Routine> routines) async {
    final encoded = jsonEncode(routines.map((r) => r.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> upsert(Routine routine) async {
    final routines = loadAll();
    final index = routines.indexWhere((r) => r.id == routine.id);
    if (index >= 0) {
      routines[index] = routine;
    } else {
      routines.add(routine);
    }
    await saveAll(routines);
  }

  Future<void> delete(String id) async {
    final routines = loadAll()..removeWhere((r) => r.id == id);
    await saveAll(routines);
  }

  Routine? findById(String id) {
    for (final routine in loadAll()) {
      if (routine.id == id) return routine;
    }
    return null;
  }

  Future<void> _ensureSeed() async {
    if (_prefs.getBool(_seededKey) == true) return;
    final seed = createRotatorCuffRoutine();
    await saveAll([seed]);
    await _prefs.setBool(_seededKey, true);
  }
}
