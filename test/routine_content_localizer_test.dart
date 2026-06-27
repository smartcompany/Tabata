import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/models/description_block.dart';
import 'package:tabata_timer/models/exercise.dart';
import 'package:tabata_timer/models/exercise_phase.dart';
import 'package:tabata_timer/models/phase_config.dart';
import 'package:tabata_timer/models/profile_summary.dart';
import 'package:tabata_timer/models/routine.dart';
import 'package:tabata_timer/services/content_settings.dart';
import 'package:tabata_timer/services/content_translation_service.dart';
import 'package:tabata_timer/services/routine_content_localizer.dart';

class _FakeTranslationService extends ContentTranslationService {
  _FakeTranslationService(this._map);

  final Map<String, String> _map;

  @override
  Future<Map<String, String>> translateMap({
    required Iterable<String> texts,
    required String targetLanguage,
  }) async {
    return {
      for (final text in texts) text: _map[text] ?? text,
    };
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('localizer translates routine and summary text fields', () async {
    final contentSettings = await ContentSettings.load();
    final localizer = RoutineContentLocalizer(
      contentSettings: contentSettings,
      translationService: _FakeTranslationService({
        '한국어 제목': 'Korean title',
        '한국어 설명': 'Korean description',
        '팔 벌리기': 'Arm raise',
        '운동': 'Work',
      }),
    );

    final summary = await localizer.localizeSummaries(
      [
        const ProfileSummary(
          id: 'p1',
          title: '한국어 제목',
          description: '한국어 설명',
          exerciseCount: 1,
        ),
      ],
      systemLocale: const Locale('en'),
    );
    expect(summary.first.title, 'Korean title');
    expect(summary.first.description, 'Korean description');

    final routine = await localizer.localizeRoutine(
      Routine(
        id: 'r1',
        title: '한국어 제목',
        description: '한국어 설명',
        descriptionBlocks: const [
          TextDescriptionBlock(text: '한국어 설명'),
        ],
        exercises: [
          Exercise(
            id: 'e1',
            name: '팔 벌리기',
            instruction: '',
            order: 0,
            prepare: const TimedPhase(durationSec: 3),
            phases: [
              ExercisePhase(
                id: 'ph1',
                kind: ExercisePhaseKind.work,
                label: '운동',
                durationSec: 8,
                order: 0,
              ),
            ],
            reps: 10,
            sets: 3,
          ),
        ],
      ),
      systemLocale: const Locale('en'),
    );

    expect(routine.title, 'Korean title');
    expect(routine.descriptionPlainText, 'Korean description');
    expect(routine.exercises.first.name, 'Arm raise');
    expect(routine.exercises.first.phases.first.label, 'Work');
  });

  test('localizer skips translation when contentLanguage matches app language',
      () async {
    final contentSettings = await ContentSettings.load();
    final localizer = RoutineContentLocalizer(
      contentSettings: contentSettings,
      translationService: _FakeTranslationService({
        '한국어 제목': 'Korean title',
      }),
    );

    final summary = await localizer.localizeSummaries(
      [
        const ProfileSummary(
          id: 'p1',
          title: '한국어 제목',
          description: '한국어 설명',
          exerciseCount: 1,
          contentLanguage: 'ko',
        ),
      ],
      systemLocale: const Locale('ko'),
    );

    expect(summary.first.title, '한국어 제목');
  });

  test('localizer skips translation for legacy summaries without contentLanguage',
      () async {
    final contentSettings = await ContentSettings.load();
    final localizer = RoutineContentLocalizer(
      contentSettings: contentSettings,
      translationService: _FakeTranslationService({
        '한국어 제목': 'Korean title',
      }),
    );

    final summary = await localizer.localizeSummaries(
      [
        const ProfileSummary(
          id: 'p1',
          title: '한국어 제목',
          description: '한국어 설명',
          exerciseCount: 1,
        ),
      ],
      systemLocale: const Locale('ko'),
    );

    expect(summary.first.title, '한국어 제목');
  });

  test('localizer skips translation when setting is off', () async {
    final contentSettings = await ContentSettings.load();
    await contentSettings.setAutoTranslateContent(false);

    final localizer = RoutineContentLocalizer(
      contentSettings: contentSettings,
      translationService: _FakeTranslationService({
        '한국어 제목': 'Korean title',
      }),
    );

    final summary = await localizer.localizeSummaries(
      [
        const ProfileSummary(
          id: 'p1',
          title: '한국어 제목',
          description: '',
          exerciseCount: 0,
        ),
      ],
      systemLocale: const Locale('en'),
    );

    expect(summary.first.title, '한국어 제목');
  });
}
