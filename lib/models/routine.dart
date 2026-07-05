import 'exercise.dart';
import 'description_block.dart';
import 'json_field.dart';
import '../utils/content_language.dart';

const _copyWithSentinel = Object();

class Routine {
  const Routine({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    this.descriptionBlocks = const [],
    this.schemaVersion = currentSchemaVersion,
    this.contentLanguage,
    this.healthActivityType,
  });

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final String id;
  final String title;
  final String description;
  final List<DescriptionBlock> descriptionBlocks;
  final List<Exercise> exercises;
  final String? contentLanguage;
  /// Apple Health workout type id. Null means do not save to Health.
  final String? healthActivityType;

  List<DescriptionBlock> get effectiveDescriptionBlocks {
    if (descriptionBlocks.isNotEmpty) return descriptionBlocks;
    return DescriptionBlock.fromLegacyDescription(description);
  }

  String get descriptionPlainText =>
      DescriptionBlock.plainText(effectiveDescriptionBlocks);

  List<Exercise> get orderedExercises {
    final copy = List<Exercise>.from(exercises);
    copy.sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'id': id,
        'title': title,
        'description': descriptionPlainText,
        if (contentLanguage != null) 'contentLanguage': contentLanguage,
        if (descriptionBlocks.isNotEmpty)
          'descriptionBlocks': DescriptionBlock.listToJson(descriptionBlocks),
        if (healthActivityType != null) 'healthActivityType': healthActivityType,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory Routine.fromJson(Map<String, dynamic> json) {
    final schemaVersion = JsonField.requiredInt(json, 'schemaVersion');
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException('Unsupported schemaVersion: $schemaVersion');
    }

    final exercisesJson = JsonField.requiredList(json, 'exercises');
    final legacyDescription = JsonField.optionalString(json, 'description');
    final blocks = DescriptionBlock.listFromJson(json['descriptionBlocks']);
    final effectiveBlocks = blocks.isNotEmpty
        ? blocks
        : DescriptionBlock.fromLegacyDescription(legacyDescription);

    return Routine(
      schemaVersion: schemaVersion,
      id: JsonField.requiredString(json, 'id'),
      title: JsonField.requiredString(json, 'title'),
      description: DescriptionBlock.plainText(effectiveBlocks),
      descriptionBlocks: blocks,
      contentLanguage: ContentLanguage.resolve(
        json['contentLanguage'] as String?,
      ),
      healthActivityType: JsonField.optionalNullableString(json, 'healthActivityType'),
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
    List<DescriptionBlock>? descriptionBlocks,
    List<Exercise>? exercises,
    String? contentLanguage,
    Object? healthActivityType = _copyWithSentinel,
  }) {
    return Routine(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      descriptionBlocks: descriptionBlocks ?? this.descriptionBlocks,
      exercises: exercises ?? this.exercises,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      healthActivityType: identical(healthActivityType, _copyWithSentinel)
          ? this.healthActivityType
          : healthActivityType as String?,
    );
  }

  Routine forSingleExercise(Exercise exercise) {
    return copyWith(exercises: [exercise.copyWith(order: 0)]);
  }
}
