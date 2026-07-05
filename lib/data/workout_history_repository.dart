import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session_record.dart';

class WorkoutHistoryRepository {
  WorkoutHistoryRepository(this._prefs);

  static const _storageKey = 'workout_history_records_v1';

  final SharedPreferences _prefs;
  List<WorkoutSessionRecord> _records = [];

  static Future<WorkoutHistoryRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = WorkoutHistoryRepository(prefs);
    repository._records = repository._loadRecords();
    return repository;
  }

  List<WorkoutSessionRecord> get allRecords {
    final sorted = List<WorkoutSessionRecord>.from(_records)
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return List.unmodifiable(sorted);
  }

  Future<void> add(WorkoutSessionRecord record) async {
    _records.insert(0, record);
    await _saveRecords();
  }

  Future<void> updateHealthSynced(String id, bool synced) async {
    final index = _records.indexWhere((record) => record.id == id);
    if (index < 0) return;
    _records[index] = _records[index].copyWith(healthSynced: synced);
    await _saveRecords();
  }

  WorkoutSessionRecord? findById(String id) {
    for (final record in _records) {
      if (record.id == id) return record;
    }
    return null;
  }

  List<WorkoutSessionRecord> recordsForDay(DateTime day) {
    final target = _localDate(day);
    return allRecords
        .where((record) => _localDate(record.endedAt) == target)
        .toList();
  }

  List<WorkoutDailyStats> dailyStatsForMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final stats = <WorkoutDailyStats>[];
    for (var day = 1; day <= daysInMonth; day++) {
      final sessions = recordsForDay(DateTime(year, month, day));
      if (sessions.isEmpty) continue;
      stats.add(
        WorkoutDailyStats(
          day: day,
          sessionCount: sessions.length,
          totalDurationSec: sessions.fold<int>(
            0,
            (sum, session) => sum + session.durationSec,
          ),
        ),
      );
    }
    return stats;
  }

  int sessionCountForMonth(int year, int month) {
    return _recordsInMonth(year, month).length;
  }

  int totalDurationSecForMonth(int year, int month) {
    return _recordsInMonth(year, month).fold<int>(
      0,
      (sum, record) => sum + record.durationSec,
    );
  }

  Set<int> daysWithWorkoutsInMonth(int year, int month) {
    return _recordsInMonth(year, month)
        .map((record) => record.endedAt.day)
        .toSet();
  }

  List<WorkoutSessionRecord> _recordsInMonth(int year, int month) {
    return _records.where((record) {
      final ended = record.endedAt.toLocal();
      return ended.year == year && ended.month == month;
    }).toList();
  }

  List<WorkoutSessionRecord> _loadRecords() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in list)
        WorkoutSessionRecord.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> _saveRecords() async {
    final encoded = jsonEncode(_records.map((record) => record.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  static DateTime _localDate(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
