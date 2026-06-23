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

class ExercisePhase {
  const ExercisePhase({
    required this.id,
    required this.kind,
    required this.label,
    required this.durationSec,
    required this.order,
  });

  final String id;
  final ExercisePhaseKind kind;
  final String label;
  final int durationSec;
  final int order;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.toJson(),
        'label': label,
        'durationSec': durationSec,
        'order': order,
      };

  factory ExercisePhase.fromJson(Map<String, dynamic> json) {
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
    );
  }

  ExercisePhase copyWith({
    String? id,
    ExercisePhaseKind? kind,
    String? label,
    int? durationSec,
    int? order,
  }) {
    return ExercisePhase(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      durationSec: durationSec ?? this.durationSec,
      order: order ?? this.order,
    );
  }
}

ExercisePhase createEmptyPhase({
  required ExercisePhaseKind kind,
  required int order,
}) {
  return ExercisePhase(
    id: _uuid.v4(),
    kind: kind,
    label: '',
    durationSec: ExerciseLimits.minWorkRelaxDurationSec,
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
