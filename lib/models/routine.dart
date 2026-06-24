import 'exercise.dart';
import 'json_field.dart';

class Routine {
  const Routine({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final String id;
  final String title;
  final String description;
  final List<Exercise> exercises;

  List<Exercise> get orderedExercises {
    final copy = List<Exercise>.from(exercises);
    copy.sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'id': id,
        'title': title,
        'description': description,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory Routine.fromJson(Map<String, dynamic> json) {
    final schemaVersion = JsonField.requiredInt(json, 'schemaVersion');
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException('Unsupported schemaVersion: $schemaVersion');
    }

    final exercisesJson = JsonField.requiredList(json, 'exercises');
    return Routine(
      schemaVersion: schemaVersion,
      id: JsonField.requiredString(json, 'id'),
      title: JsonField.requiredString(json, 'title'),
      description: JsonField.optionalString(json, 'description'),
      exercises: exercisesJson
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Routine copyWith({
    int? schemaVersion,
    String? id,
    String? title,
    String? description,
    List<Exercise>? exercises,
  }) {
    return Routine(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
    );
  }

  Routine forSingleExercise(Exercise exercise) {
    return copyWith(exercises: [exercise.copyWith(order: 0)]);
  }
}
