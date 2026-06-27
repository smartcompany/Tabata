import 'dart:ui';

import '../models/description_block.dart';
import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import '../models/profile_summary.dart';
import '../models/routine.dart';
import '../utils/content_language.dart';
import 'content_settings.dart';
import 'content_translation_service.dart';

class RoutineContentLocalizer {
  RoutineContentLocalizer({
    required ContentSettings contentSettings,
    ContentTranslationService? translationService,
  })  : _contentSettings = contentSettings,
        _translationService =
            translationService ?? ContentTranslationService();

  final ContentSettings _contentSettings;
  final ContentTranslationService _translationService;

  Future<List<ProfileSummary>> localizeSummaries(
    List<ProfileSummary> summaries, {
    Locale? systemLocale,
  }) async {
    if (!_contentSettings.autoTranslateContent) return summaries;

    final target = _targetLanguage(systemLocale);
    final strings = <String>{};
    for (final summary in summaries) {
      if (ContentLanguage.matchesTarget(summary.contentLanguage, target)) {
        continue;
      }
      _collectSummaryStrings(summary, strings);
    }

    if (strings.isEmpty) return summaries;

    final map = await _translationService.translateMap(
      texts: strings,
      targetLanguage: target,
    );

    return [
      for (final summary in summaries) _applySummary(summary, map),
    ];
  }

  Future<Routine> localizeRoutine(
    Routine routine, {
    Locale? systemLocale,
  }) async {
    final results = await localizeRoutines([routine], systemLocale: systemLocale);
    return results.first;
  }

  Future<List<Routine>> localizeRoutines(
    List<Routine> routines, {
    Locale? systemLocale,
  }) async {
    if (!_contentSettings.autoTranslateContent || routines.isEmpty) {
      return routines;
    }

    final target = _targetLanguage(systemLocale);
    final strings = <String>{};
    for (final routine in routines) {
      if (ContentLanguage.matchesTarget(routine.contentLanguage, target)) {
        continue;
      }
      _collectRoutineStrings(routine, strings);
    }

    if (strings.isEmpty) return routines;

    final map = await _translationService.translateMap(
      texts: strings,
      targetLanguage: target,
    );

    return [for (final routine in routines) _applyRoutine(routine, map)];
  }

  String _targetLanguage(Locale? systemLocale) {
    return _translationService.resolveTargetLanguage(
      systemLocale: systemLocale ?? PlatformDispatcher.instance.locale,
    );
  }

  void _collectSummaryStrings(ProfileSummary summary, Set<String> strings) {
    _add(strings, summary.title);
    _add(strings, summary.description);
  }

  void _collectRoutineStrings(Routine routine, Set<String> strings) {
    _add(strings, routine.title);
    for (final block in routine.effectiveDescriptionBlocks) {
      _collectBlockStrings(block, strings);
    }
    for (final exercise in routine.exercises) {
      _add(strings, exercise.name);
      for (final block in exercise.effectiveInstructionBlocks) {
        _collectBlockStrings(block, strings);
      }
      for (final phase in exercise.phases) {
        _add(strings, phase.label);
      }
    }
  }

  void _collectBlockStrings(DescriptionBlock block, Set<String> strings) {
    switch (block) {
      case TextDescriptionBlock(:final text):
        _add(strings, text);
      case ImageDescriptionBlock(:final alt):
        if (alt != null) _add(strings, alt);
      case VideoDescriptionBlock():
        break;
    }
  }

  ProfileSummary _applySummary(
    ProfileSummary summary,
    Map<String, String> map,
  ) {
    return ProfileSummary(
      id: summary.id,
      title: map[summary.title] ?? summary.title,
      description: map[summary.description] ?? summary.description,
      exerciseCount: summary.exerciseCount,
      ownerId: summary.ownerId,
      ownerName: summary.ownerName,
      contentLanguage: summary.contentLanguage,
    );
  }

  Routine _applyRoutine(Routine routine, Map<String, String> map) {
    final descriptionBlocks = _applyBlocks(
      routine.effectiveDescriptionBlocks,
      map,
    );

    return routine.copyWith(
      title: map[routine.title] ?? routine.title,
      description: DescriptionBlock.plainText(descriptionBlocks),
      descriptionBlocks: routine.descriptionBlocks.isNotEmpty
          ? descriptionBlocks
          : routine.descriptionBlocks,
      exercises: [
        for (final exercise in routine.exercises) _applyExercise(exercise, map),
      ],
    );
  }

  Exercise _applyExercise(Exercise exercise, Map<String, String> map) {
    final instructionBlocks = _applyBlocks(
      exercise.effectiveInstructionBlocks,
      map,
    );

    return exercise.copyWith(
      name: map[exercise.name] ?? exercise.name,
      instruction: DescriptionBlock.plainText(instructionBlocks),
      instructionBlocks: exercise.instructionBlocks.isNotEmpty
          ? instructionBlocks
          : exercise.instructionBlocks,
      phases: [
        for (final phase in exercise.phases) _applyPhase(phase, map),
      ],
    );
  }

  ExercisePhase _applyPhase(ExercisePhase phase, Map<String, String> map) {
    return phase.copyWith(label: map[phase.label] ?? phase.label);
  }

  List<DescriptionBlock> _applyBlocks(
    List<DescriptionBlock> blocks,
    Map<String, String> map,
  ) {
    return [
      for (final block in blocks)
        switch (block) {
          TextDescriptionBlock(:final text) => TextDescriptionBlock(
              text: map[text] ?? text,
            ),
          ImageDescriptionBlock(:final url, :final localPath, :final alt) =>
            ImageDescriptionBlock(
              url: url,
              localPath: localPath,
              alt: alt == null ? null : (map[alt] ?? alt),
            ),
          VideoDescriptionBlock(:final url, :final provider) =>
            VideoDescriptionBlock(url: url, provider: provider),
        },
    ];
  }

  void _add(Set<String> strings, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) strings.add(value);
  }
}
