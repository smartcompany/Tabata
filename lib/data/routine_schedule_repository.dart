import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine_schedule.dart';

class RoutineScheduleRepository {
  RoutineScheduleRepository(this._prefs);

  static const _storageKey = 'routine_schedules_v1';

  final SharedPreferences _prefs;
  final Map<String, RoutineSchedule> _schedules = {};

  static Future<RoutineScheduleRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = RoutineScheduleRepository(prefs);
    await repository._load();
    return repository;
  }

  Future<void> _load() async {
    _schedules.clear();
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      final schedule = RoutineSchedule.fromJson(item);
      _schedules[schedule.routineId] = schedule;
    }
  }

  Future<void> _save() async {
    final payload = jsonEncode(
      _schedules.values.map((schedule) => schedule.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, payload);
  }

  List<RoutineSchedule> all() =>
      _schedules.values.toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  RoutineSchedule? forRoutine(String routineId) => _schedules[routineId];

  Future<void> upsert(RoutineSchedule schedule) async {
    _schedules[schedule.routineId] = schedule;
    await _save();
  }

  Future<void> remove(String routineId) async {
    if (!_schedules.containsKey(routineId)) return;
    _schedules.remove(routineId);
    await _save();
  }
}
