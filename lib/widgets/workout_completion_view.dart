import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/workout_completion_summary.dart';
import '../services/app_analytics_service.dart';
import '../services/routine_share_service.dart';
import '../utils/duration_format.dart';
import 'routine_share_sheet.dart';

class WorkoutCompletionView extends StatefulWidget {
  const WorkoutCompletionView({
    super.key,
    required this.summary,
    required this.onDone,
    this.showClose = false,
  });

  final WorkoutCompletionSummary summary;
  final VoidCallback onDone;
  final bool showClose;

  @override
  State<WorkoutCompletionView> createState() => _WorkoutCompletionViewState();
}

class _WorkoutCompletionViewState extends State<WorkoutCompletionView> {
  static const _accent = Color(0xFFE8F55A);
  static const _bg = Color(0xFF0A0A0A);
  static const _card = Color(0xFF161616);

  final _shareCardKey = GlobalKey();
  var _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final l10n = AppLocalizations.of(context);
    final summary = widget.summary;
    final text = l10n.workoutSummaryShareMessage(
      summary.routineTitle,
      formatDurationClock(summary.durationSec),
      summary.estimatedCaloriesKcal,
      summary.exerciseCount,
    );

    try {
      final imageBytes = await _captureShareCard();
      if (!mounted) return;

      // 운동 완료 공유: 루틴 열기 버튼 없음. 카드 탭 → 앱 다운로드 링크.
      await RoutineShareSheet.show(
        context: context,
        shareText: text,
        kakaoShareText: text,
        subject: summary.routineTitle,
        linkUrl: RoutineShareService.appShareLink,
        linkButtonTitle: '',
        shareType: 'workout_complete',
        imageBytes: imageBytes,
        systemShareImageOnly: true,
        kakaoFeedTitle:
            '${l10n.workoutCompleteShareTitle} - ${summary.routineTitle}',
        kakaoFeedDescription:
            '⏱ ${formatDurationClock(summary.durationSec)} · '
            '🔥 ${summary.estimatedCaloriesKcal} kcal · '
            '💪 ${summary.exerciseCount}',
      );

      await AppAnalyticsService.logProductEvent(
        'workout_complete_shared',
        properties: {
          'duration_sec': summary.durationSec,
          'calories': summary.estimatedCaloriesKcal,
          'exercise_count': summary.exerciseCount,
        },
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<Uint8List?> _captureShareCard() async {
    final boundary = _shareCardKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = widget.summary;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (widget.showClose)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: widget.onDone,
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: RepaintBoundary(
                  key: _shareCardKey,
                  child: ColoredBox(
                    color: _bg,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 56,
                          color: _accent.withValues(alpha: 0.95),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.workoutCompletedMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary.routineTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _ShareableSummaryCard(
                          summary: summary,
                          l10n: l10n,
                          accent: _accent,
                          cardColor: _card,
                        ),
                        if (summary.exerciseNames.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.workoutSummaryExercisesTitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...summary.exerciseNames.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _card,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key + 1}',
                                      style: TextStyle(
                                        color: _accent.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w700,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
              decoration: BoxDecoration(
                color: _bg,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _sharing ? null : _share,
                      icon: _sharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.ios_share),
                      label: Text(l10n.workoutSummaryShare),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onDone,
                      child: Text(
                        l10n.workoutDone,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareableSummaryCard extends StatelessWidget {
  const _ShareableSummaryCard({
    required this.summary,
    required this.l10n,
    required this.accent,
    required this.cardColor,
  });

  final WorkoutCompletionSummary summary;
  final AppLocalizations l10n;
  final Color accent;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final stats = <_StatItem>[
      _StatItem(
        value: formatDurationClock(summary.durationSec),
        label: l10n.workoutSummaryDuration,
      ),
      _StatItem(
        value: '${summary.estimatedCaloriesKcal}',
        label: l10n.workoutSummaryCalories,
        suffix: 'kcal',
      ),
      _StatItem(
        value: '${summary.exerciseCount}',
        label: l10n.workoutSummaryExercises,
      ),
      if (summary.avgHeartRateBpm > 0)
        _StatItem(
          value: '${summary.avgHeartRateBpm.round()}',
          label: l10n.workoutSummaryAvgHeartRate,
          suffix: 'bpm',
        )
      else if (summary.maxHeartRateBpm > 0)
        _StatItem(
          value: '${summary.maxHeartRateBpm.round()}',
          label: l10n.workoutSummaryMaxHeartRate,
          suffix: 'bpm',
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.routineTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final stat in stats)
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(stat: stat, accent: accent),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            l10n.workoutSummaryCaloriesHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.value,
    required this.label,
    this.suffix,
  });

  final String value;
  final String label;
  final String? suffix;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, required this.accent});

  final _StatItem stat;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  stat.value,
                  style: TextStyle(
                    color: accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (stat.suffix != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    stat.suffix!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Full-screen host for debug / standalone preview.
class WorkoutCompletionScreen extends StatelessWidget {
  const WorkoutCompletionScreen({
    super.key,
    required this.summary,
  });

  final WorkoutCompletionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: WorkoutCompletionView(
        summary: summary,
        showClose: true,
        onDone: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
