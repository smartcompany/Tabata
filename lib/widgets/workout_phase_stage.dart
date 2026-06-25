import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../engine/workout_timer_engine.dart';
import '../l10n/l10n_extensions.dart';
import '../utils/duration_format.dart';

class WorkoutPhaseTheme {
  const WorkoutPhaseTheme({
    required this.gradientTop,
    required this.gradientBottom,
    required this.glowColor,
    required this.accentColor,
  });

  final Color gradientTop;
  final Color gradientBottom;
  final Color glowColor;
  final Color accentColor;

  static WorkoutPhaseTheme forKind(WorkoutPhaseKind kind) {
    return switch (kind) {
      WorkoutPhaseKind.prepare => const WorkoutPhaseTheme(
          gradientTop: Color(0xFF2A3358),
          gradientBottom: Color(0xFF101525),
          glowColor: Color(0xFF9FA8DA),
          accentColor: Color(0xFFB8C0FF),
        ),
      WorkoutPhaseKind.work => const WorkoutPhaseTheme(
          gradientTop: Color(0xFF3D4E18),
          gradientBottom: Color(0xFF151A08),
          glowColor: Color(0xFFCDDC39),
          accentColor: Color(0xFFE6F06A),
        ),
      WorkoutPhaseKind.relax => const WorkoutPhaseTheme(
          gradientTop: Color(0xFF1A4A52),
          gradientBottom: Color(0xFF0B1E22),
          glowColor: Color(0xFF4DD0E1),
          accentColor: Color(0xFF80DEEA),
        ),
      WorkoutPhaseKind.completed => const WorkoutPhaseTheme(
          gradientTop: Color(0xFF1E1E1E),
          gradientBottom: Color(0xFF0A0A0A),
          glowColor: Color(0xFFCDDC39),
          accentColor: Color(0xFFCDDC39),
        ),
    };
  }
}

String workoutPhaseIdentity(WorkoutTimerSnapshot snap) {
  if (snap.isCompleted) return 'completed';
  if (snap.phase.isCountRep) {
    return '${snap.exerciseIndex}-${snap.setIndex}-${snap.repIndex}-'
        'count-${snap.phase.phaseGroupKey}';
  }
  return '${snap.exerciseIndex}-${snap.setIndex}-${snap.repIndex}-'
      '${snap.phase.kind.name}-${snap.phase.label}';
}

WorkoutPhase finishNextPhase(AppLocalizations l10n) {
  return WorkoutPhase(
    kind: WorkoutPhaseKind.completed,
    label: l10n.nextPhaseFinish,
    durationSec: 0,
  );
}

WorkoutPhase previewNextPhase(WorkoutPhase? nextPhase, AppLocalizations l10n) {
  return nextPhase ?? finishNextPhase(l10n);
}

String phaseDisplayTitle(WorkoutPhase phase, AppLocalizations l10n) {
  if (phase.kind == WorkoutPhaseKind.completed) {
    return phase.label;
  }
  return phase.kind.title(l10n);
}

class WorkoutPhaseStage extends StatefulWidget {
  const WorkoutPhaseStage({
    super.key,
    required this.snap,
    required this.nextPhase,
    required this.l10n,
    required this.completedAccent,
  });

  final WorkoutTimerSnapshot snap;
  final WorkoutPhase? nextPhase;
  final AppLocalizations l10n;
  final Color completedAccent;

  @override
  State<WorkoutPhaseStage> createState() => _WorkoutPhaseStageState();
}

class _WorkoutPhaseStageState extends State<WorkoutPhaseStage>
    with SingleTickerProviderStateMixin {
  static const _transitionDuration = Duration(milliseconds: 560);
  static const _chipReservedHeight = 80.0;

  AnimationController? _controller;
  WorkoutPhase? _outgoingPhase;
  WorkoutPhaseTheme? _outgoingTheme;
  WorkoutPhase? _incomingPhase;
  WorkoutPhaseTheme? _incomingTheme;
  WorkoutPhase? _revealedNextPhase;

  @override
  void didUpdateWidget(covariant WorkoutPhaseStage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.snap.isCompleted) {
      _controller?.reset();
      _clearTransition();
      return;
    }

    if (workoutPhaseIdentity(widget.snap) !=
            workoutPhaseIdentity(oldWidget.snap) &&
        !oldWidget.snap.isCompleted) {
      _outgoingPhase = oldWidget.snap.phase;
      _outgoingTheme = WorkoutPhaseTheme.forKind(oldWidget.snap.phase.kind);
      _incomingPhase = previewNextPhase(oldWidget.nextPhase, widget.l10n);
      _incomingTheme = WorkoutPhaseTheme.forKind(_incomingPhase!.kind);
      _revealedNextPhase = widget.snap.isCompleted
          ? null
          : previewNextPhase(widget.nextPhase, widget.l10n);
      _controller ??= AnimationController(
        vsync: this,
        duration: _transitionDuration,
      );
      _controller!
        ..reset()
        ..forward().whenComplete(() {
          if (mounted) setState(_clearTransition);
        });
    }
  }

  void _clearTransition() {
    _outgoingPhase = null;
    _outgoingTheme = null;
    _incomingPhase = null;
    _incomingTheme = null;
    _revealedNextPhase = null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool get _isTransitioning => _outgoingPhase != null;

  @override
  Widget build(BuildContext context) {
    final snap = widget.snap;
    final theme = WorkoutPhaseTheme.forKind(snap.phase.kind);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (snap.isCompleted) {
            return _PhaseCardShell(
              theme: theme,
              height: constraints.maxHeight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: widget.completedAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snap.phase.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final fromTheme =
              _isTransitioning ? _outgoingTheme! : theme;
          final controller = _controller;

          return AnimatedBuilder(
            animation: controller ?? kAlwaysCompleteAnimation,
            builder: (context, child) {
              final t = _isTransitioning && controller != null
                  ? controller.value
                  : 1.0;
              final displayTheme = _isTransitioning && controller != null
                  ? WorkoutPhaseTheme(
                      gradientTop: Color.lerp(
                        fromTheme.gradientTop,
                        theme.gradientTop,
                        t,
                      )!,
                      gradientBottom: Color.lerp(
                        fromTheme.gradientBottom,
                        theme.gradientBottom,
                        t,
                      )!,
                      glowColor: Color.lerp(
                        fromTheme.glowColor,
                        theme.glowColor,
                        t,
                      )!,
                      accentColor: Color.lerp(
                        fromTheme.accentColor,
                        theme.accentColor,
                        t,
                      )!,
                    )
                  : theme;

              return _PhaseCardShell(
                theme: displayTheme,
                height: constraints.maxHeight,
                child: _isTransitioning && controller != null
                    ? _TransitioningCardContent(
                        controller: controller,
                        chipReservedHeight: _chipReservedHeight,
                        l10n: widget.l10n,
                        outgoingPhase: _outgoingPhase!,
                        outgoingTheme: _outgoingTheme!,
                        incomingPhase: _incomingPhase!,
                        incomingTheme: _incomingTheme!,
                        incomingRemainingSec: snap.remainingSec,
                        revealedNextPhase: _revealedNextPhase,
                      )
                    : _IdleCardContent(
                        l10n: widget.l10n,
                        phase: snap.phase,
                        theme: theme,
                        remainingSec: snap.remainingSec,
                        nextPhase: widget.nextPhase,
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PhaseCardShell extends StatelessWidget {
  const _PhaseCardShell({
    required this.theme,
    required this.height,
    required this.child,
  });

  final WorkoutPhaseTheme theme;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.gradientTop, theme.gradientBottom],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.glowColor.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: 24,
            child: Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.accessibility_new_rounded,
                size: 180,
                color: theme.accentColor,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _IdleCardContent extends StatelessWidget {
  const _IdleCardContent({
    required this.l10n,
    required this.phase,
    required this.theme,
    required this.remainingSec,
    required this.nextPhase,
  });

  final AppLocalizations l10n;
  final WorkoutPhase phase;
  final WorkoutPhaseTheme theme;
  final int remainingSec;
  final WorkoutPhase? nextPhase;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _MainPhaseContent(
            phase: phase,
            theme: theme,
            l10n: l10n,
            remainingSec: remainingSec,
            styleT: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _NextPhaseChip(
            phase: previewNextPhase(nextPhase, l10n),
            l10n: l10n,
          ),
        ),
      ],
    );
  }
}

class _TransitioningCardContent extends StatelessWidget {
  const _TransitioningCardContent({
    required this.controller,
    required this.chipReservedHeight,
    required this.l10n,
    required this.outgoingPhase,
    required this.outgoingTheme,
    required this.incomingPhase,
    required this.incomingTheme,
    required this.incomingRemainingSec,
    required this.revealedNextPhase,
  });

  final AnimationController controller;
  final double chipReservedHeight;
  final AppLocalizations l10n;
  final WorkoutPhase outgoingPhase;
  final WorkoutPhaseTheme outgoingTheme;
  final WorkoutPhase incomingPhase;
  final WorkoutPhaseTheme incomingTheme;
  final int incomingRemainingSec;
  final WorkoutPhase? revealedNextPhase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(controller.value);
        final outgoingFade =
            (1 - Curves.easeIn.transform(t.clamp(0, 1))).clamp(0.0, 1.0);
        final outgoingSlide = -28.0 * t;
        final revealOpacity = Curves.easeOut.transform(
          ((t - 0.5) / 0.5).clamp(0.0, 1.0),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final mainAreaHeight =
                constraints.maxHeight - chipReservedHeight - 16;
            final mainCenterY = mainAreaHeight / 2;
            final chipCenterY =
                mainAreaHeight + 16 + chipReservedHeight / 2;
            final incomingCenterY =
                chipCenterY + (mainCenterY - chipCenterY) * t;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: mainAreaHeight,
                  child: Opacity(
                    opacity: outgoingFade,
                    child: Transform.translate(
                      offset: Offset(0, outgoingSlide),
                      child: _MainPhaseContent(
                        phase: outgoingPhase,
                        theme: outgoingTheme,
                        l10n: l10n,
                        remainingSec: 0,
                        styleT: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: incomingCenterY,
                  child: Transform.translate(
                    offset: Offset(0, -_contentHeight(t) / 2),
                    child: _MorphingPhaseContent(
                      phase: incomingPhase,
                      theme: incomingTheme,
                      l10n: l10n,
                      remainingSec: incomingRemainingSec,
                      styleT: t,
                      showNextLabel: t < 0.2,
                    ),
                  ),
                ),
                if (revealedNextPhase != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Opacity(
                      opacity: revealOpacity,
                      child: _NextPhaseChip(
                        phase: revealedNextPhase!,
                        l10n: l10n,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  double _contentHeight(double t) {
    final chipContent = 72.0;
    final mainContent = 220.0;
    return chipContent + (mainContent - chipContent) * t;
  }
}

class _MainPhaseContent extends StatelessWidget {
  const _MainPhaseContent({
    required this.phase,
    required this.theme,
    required this.l10n,
    required this.remainingSec,
    required this.styleT,
  });

  final WorkoutPhase phase;
  final WorkoutPhaseTheme theme;
  final AppLocalizations l10n;
  final int remainingSec;
  final double styleT;

  @override
  Widget build(BuildContext context) {
    return _MorphingPhaseContent(
      phase: phase,
      theme: theme,
      l10n: l10n,
      remainingSec: remainingSec,
      styleT: styleT,
    );
  }
}

class _MorphingPhaseContent extends StatelessWidget {
  const _MorphingPhaseContent({
    required this.phase,
    required this.theme,
    required this.l10n,
    required this.remainingSec,
    required this.styleT,
    this.showNextLabel = false,
  });

  final WorkoutPhase phase;
  final WorkoutPhaseTheme theme;
  final AppLocalizations l10n;
  final int remainingSec;
  final double styleT;
  final bool showNextLabel;

  double _lerp(double a, double b) => a + (b - a) * styleT;

  @override
  Widget build(BuildContext context) {
    final phaseTitle = phaseDisplayTitle(phase, l10n);
    final showPhaseLabel = phase.kind != WorkoutPhaseKind.completed &&
        phase.label.isNotEmpty &&
        phase.label != phaseTitle;
    final isCountRep = phase.isCountRep;
    final showTimer =
        phase.kind != WorkoutPhaseKind.completed && phase.durationSec > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showNextLabel) ...[
            Text(
              l10n.workoutNext,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            phaseTitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: _lerp(0.65, 1)),
              fontSize: _lerp(18, 24),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          if (showPhaseLabel && styleT > 0.2) ...[
            SizedBox(height: _lerp(2, 6)),
            Opacity(
              opacity: ((styleT - 0.2) / 0.8).clamp(0, 1),
              child: Text(
                phase.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: _lerp(13, 15),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (isCountRep) ...[
            SizedBox(height: _lerp(8, 20)),
            Text(
              '${phase.countRepNumber}',
              style: TextStyle(
                color: theme.glowColor,
                fontSize: _lerp(36, 72),
                height: 1,
                fontWeight: FontWeight.w300,
                fontFeatures: const [FontFeature.tabularFigures()],
                shadows: [
                  Shadow(
                    color: theme.glowColor.withValues(alpha: 0.65),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.repCountProgress(
                phase.countRepNumber,
                phase.totalCountReps,
              ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: _lerp(14, 18),
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
          if (showTimer && isCountRep) ...[
            SizedBox(height: _lerp(6, 12)),
            Text(
              formatDurationClock(remainingSec),
              style: TextStyle(
                color: theme.glowColor.withValues(alpha: 0.75),
                fontSize: _lerp(18, 28),
                height: 1,
                fontWeight: FontWeight.w300,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ] else if (showTimer) ...[
            SizedBox(height: _lerp(8, 20)),
            _GlowingTimer(
              remainingSec: remainingSec,
              glowColor: theme.glowColor,
              fontSize: _lerp(22, 72),
            ),
          ],
        ],
      ),
    );
  }
}

class _GlowingTimer extends StatelessWidget {
  const _GlowingTimer({
    required this.remainingSec,
    required this.glowColor,
    required this.fontSize,
  });

  final int remainingSec;
  final Color glowColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fontSize * 1.35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (fontSize > 40) ...[
            for (final size in [fontSize * 1.6, fontSize * 1.2, fontSize * 0.9])
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: glowColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
          ],
          Text(
            formatDurationClock(remainingSec),
            style: TextStyle(
              color: glowColor,
              fontSize: fontSize,
              height: 1,
              fontWeight: FontWeight.w300,
              fontFeatures: const [FontFeature.tabularFigures()],
              shadows: [
                Shadow(
                  color: glowColor.withValues(alpha: 0.65),
                  blurRadius: 24,
                ),
                Shadow(
                  color: glowColor.withValues(alpha: 0.35),
                  blurRadius: 48,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPhaseChip extends StatelessWidget {
  const _NextPhaseChip({
    required this.phase,
    required this.l10n,
  });

  final WorkoutPhase phase;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = WorkoutPhaseTheme.forKind(phase.kind);
    final phaseTitle = phaseDisplayTitle(phase, l10n);
    final showDuration =
        phase.kind != WorkoutPhaseKind.completed && phase.durationSec > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.workoutNext,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            phaseTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showDuration) ...[
            const SizedBox(height: 2),
            Text(
              formatDurationClock(phase.durationSec),
              style: TextStyle(
                color: theme.glowColor.withValues(alpha: 0.85),
                fontSize: 15,
                height: 1.2,
                fontWeight: FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
