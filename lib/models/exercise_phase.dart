import 'package:uuid/uuid.dart';

import 'exercise_limits.dart';
import 'json_field.dart';

const _uuid = Uuid();

enum ExercisePhaseKind {
  work,
  relax;

  static ExercisePhaseKind fromJson(String value) {
    return switch (value) {
      'work' => ExercisePhaseKind.work,
      'relax' => ExercisePhaseKind.relax,
      _ => throw FormatException('Unknown phase kind: $value'),
    };
  }

  String toJson() => name;
}

enum PhaseTimingMode {
  duration,
  count;

  static PhaseTimingMode fromJson(String? value) {
    return switch (value) {
      'count' => PhaseTimingMode.count,
      _ => PhaseTimingMode.duration,
    };
  }

  String toJson() => name;
}

enum CountOrder {
  ascending,
  descending;

  static CountOrder fromJson(String? value) {
    return switch (value) {
      'descending' => CountOrder.descending,
      'ascending' => CountOrder.ascending,
      // Legacy records without countOrder were ascending.
      _ => CountOrder.ascending,
    };
  }

  String toJson() => name;
}

class ExercisePhase {
  const ExercisePhase({
    required this.id,
    required this.kind,
    required this.label,
    required this.durationSec,
    required this.order,
    this.timingMode = PhaseTimingMode.duration,
    this.countReps = ExerciseLimits.defaultCountReps,
    this.secondsPerRep = ExerciseLimits.defaultSecondsPerRep,
    this.countOrder = CountOrder.descending,
  });

  final String id;
  final ExercisePhaseKind kind;
  final String label;
  final int durationSec;
  final int order;
  final PhaseTimingMode timingMode;
  final int countReps;
  final int secondsPerRep;
  final CountOrder countOrder;

  bool get isCountMode => timingMode == PhaseTimingMode.count;

  List<int> get countRepSequence {
    if (!isCountMode || countReps <= 0) return const [];
    if (countOrder == CountOrder.descending) {
      return [for (var n = countReps; n >= 1; n--) n];
    }
    return [for (var n = 1; n <= countReps; n++) n];
  }

  int get effectiveDurationSec {
    if (isCountMode) {
      return countReps * secondsPerRep;
    }
    return durationSec;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'kind': kind.toJson(),
      'label': label,
      'durationSec': durationSec,
      'order': order,
    };
    if (isCountMode) {
      json['timingMode'] = timingMode.toJson();
      json['countReps'] = countReps;
      json['secondsPerRep'] = secondsPerRep;
      if (countOrder == CountOrder.descending) {
        json['countOrder'] = countOrder.toJson();
      }
    }
    return json;
  }

  factory ExercisePhase.fromJson(Map<String, dynamic> json) {
    final timingMode = PhaseTimingMode.fromJson(
      JsonField.optionalString(json, 'timingMode'),
    );
    return ExercisePhase(
      id: JsonField.requiredString(json, 'id'),
      kind: ExercisePhaseKind.fromJson(JsonField.requiredString(json, 'kind')),
      label: JsonField.requiredString(json, 'label'),
      durationSec: JsonField.requiredInt(
        json,
        'durationSec',
        min: ExerciseLimits.minWorkRelaxDurationSec,
      ),
      order: JsonField.requiredInt(json, 'order', min: 0),
      timingMode: timingMode,
      countReps: JsonField.optionalInt(
            json,
            'countReps',
            min: ExerciseLimits.minCountReps,
          ) ??
          ExerciseLimits.defaultCountReps,
      secondsPerRep: JsonField.optionalInt(
            json,
            'secondsPerRep',
            min: ExerciseLimits.minSecondsPerRep,
          ) ??
          ExerciseLimits.defaultSecondsPerRep,
      countOrder: timingMode == PhaseTimingMode.count
          ? CountOrder.fromJson(
              JsonField.optionalString(json, 'countOrder'),
            )
          : CountOrder.descending,
    );
  }

  ExercisePhase copyWith({
    String? id,
    ExercisePhaseKind? kind,
    String? label,
    int? durationSec,
    int? order,
    PhaseTimingMode? timingMode,
    int? countReps,
    int? secondsPerRep,
    CountOrder? countOrder,
  }) {
    return ExercisePhase(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      durationSec: durationSec ?? this.durationSec,
      order: order ?? this.order,
      timingMode: timingMode ?? this.timingMode,
      countReps: countReps ?? this.countReps,
      secondsPerRep: secondsPerRep ?? this.secondsPerRep,
      countOrder: countOrder ?? this.countOrder,
    );
  }
}

ExercisePhase createEmptyPhase({
  required ExercisePhaseKind kind,
  required int order,
  String label = '',
}) {
  return ExercisePhase(
    id: _uuid.v4(),
    kind: kind,
    label: label,
    durationSec: ExerciseLimits.defaultWorkRelaxDurationSec,
    order: order,
  );
}

List<ExercisePhase> reindexPhases(List<ExercisePhase> phases) {
  return [
    for (var i = 0; i < phases.length; i++) phases[i].copyWith(order: i),
  ];
}

List<ExercisePhase> parseExercisePhases(Map<String, dynamic> json) {
  if (json.containsKey('phases')) {
    final list = JsonField.requiredList(json, 'phases');
    if (list.isEmpty) {
      throw const FormatException('phases must not be empty');
    }
    final phases = list
        .map((item) => ExercisePhase.fromJson(item as Map<String, dynamic>))
        .toList();
    phases.sort((a, b) => a.order.compareTo(b.order));
    return phases;
  }

  final legacy = <ExercisePhase>[];
  if (json.containsKey('work')) {
    final work = json['work'] as Map<String, dynamic>;
    legacy.add(
      ExercisePhase(
        id: _uuid.v4(),
        kind: ExercisePhaseKind.work,
        label: JsonField.requiredString(work, 'label'),
        durationSec: JsonField.requiredInt(
          work,
          'durationSec',
          min: ExerciseLimits.minWorkRelaxDurationSec,
        ),
        order: 0,
      ),
    );
  }
  if (json.containsKey('relax')) {
    final relax = json['relax'] as Map<String, dynamic>;
    legacy.add(
      ExercisePhase(
        id: _uuid.v4(),
        kind: ExercisePhaseKind.relax,
        label: JsonField.requiredString(relax, 'label'),
        durationSec: JsonField.requiredInt(
          relax,
          'durationSec',
          min: ExerciseLimits.minWorkRelaxDurationSec,
        ),
        order: legacy.length,
      ),
    );
  }
  if (legacy.isEmpty) {
    throw const FormatException('phases or work/relax required');
  }
  return legacy;
}
