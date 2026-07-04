enum ScheduleRecurrence {
  none,
  daily,
  weekly,
  monthly;

  String get storageId => name;

  static ScheduleRecurrence fromId(String? id) {
    return ScheduleRecurrence.values.firstWhere(
      (value) => value.name == id,
      orElse: () => ScheduleRecurrence.none,
    );
  }
}
