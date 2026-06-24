import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../engine/workout_timer_engine.dart';
import '../l10n/l10n_extensions.dart';
import '../utils/duration_format.dart';

class WorkoutPhasePalette {
  const WorkoutPhasePalette({required this.panel, required this.onPanel});

  final Color panel;
  final Color onPanel;
}

WorkoutPhasePalette paletteForPhaseKind(WorkoutPhaseKind kind) {
  return switch (kind) {
    WorkoutPhaseKind.prepare => const WorkoutPhasePalette(
        panel: Color(0xFF9FA8DA),
        onPanel: Colors.black,
      ),
    WorkoutPhaseKind.work => const WorkoutPhasePalette(
        panel: Color(0xFFCDDC39),
        onPanel: Colors.black,
      ),
    WorkoutPhaseKind.relax => const WorkoutPhasePalette(
        panel: Color(0xFF80DEEA),
        onPanel: Colors.black,
      ),
    WorkoutPhaseKind.completed => const WorkoutPhasePalette(
        panel: Color(0xFF1B1B1B),
        onPanel: Colors.white,
      ),
  };
}

String workoutPhaseIdentity(WorkoutTimerSnapshot snap) {
  if (snap.isCompleted) return 'completed';
  return '${snap.exerciseIndex}-${snap.setIndex}-${snap.repIndex}-'
      '${snap.phase.kind.name}-${snap.phase.label}';
}

class _PhaseLayoutMetrics {
  const _PhaseLayoutMetrics({
    required this.mainAnchorY,
    required this.previewAnchorY,
    required this.mainSlotHeight,
    required this.previewSlotHeight,
    required this.scrollStep,
  });

  final double mainAnchorY;
  final double previewAnchorY;
  final double mainSlotHeight;
  final double previewSlotHeight;
  final double scrollStep;

  static _PhaseLayoutMetrics fromViewport(double height) {
    const bottomPadding = 52.0;
    const mainSlotHeight = 210.0;
    const previewSlotHeight = 96.0;
    final mainAnchorY = height * 0.36;
    final previewAnchorY = height - bottomPadding - previewSlotHeight / 2;
    return _PhaseLayoutMetrics(
      mainAnchorY: mainAnchorY,
      previewAnchorY: previewAnchorY,
      mainSlotHeight: mainSlotHeight,
      previewSlotHeight: previewSlotHeight,
      scrollStep: previewAnchorY - mainAnchorY,
    );
  }

  double incomingSlotHeight(double t) {
    return previewSlotHeight + (mainSlotHeight - previewSlotHeight) * t;
  }
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

  AnimationController? _controller;
  WorkoutPhase? _outgoingPhase;
  WorkoutPhasePalette? _outgoingPalette;
  WorkoutPhase? _incomingPhase;
  WorkoutPhasePalette? _incomingPalette;
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
      _outgoingPalette = paletteForPhaseKind(oldWidget.snap.phase.kind);
      _incomingPhase = oldWidget.nextPhase ?? widget.snap.phase;
      _incomingPalette = paletteForPhaseKind(_incomingPhase!.kind);
      _revealedNextPhase = widget.nextPhase;
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
    _outgoingPalette = null;
    _incomingPhase = null;
    _incomingPalette = null;
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
    final palette = paletteForPhaseKind(snap.phase.kind);

    if (snap.isCompleted) {
      return ColoredBox(
        color: palette.panel,
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
                style: TextStyle(
                  color: palette.onPanel,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final fromColor =
        _isTransitioning ? _outgoingPalette!.panel : palette.panel;
    final toColor = palette.panel;
    final controller = _controller;

    return AnimatedBuilder(
      animation: controller ?? kAlwaysCompleteAnimation,
      builder: (context, child) {
        final bg = _isTransitioning && controller != null
            ? Color.lerp(fromColor, toColor, controller.value) ?? toColor
            : toColor;
        return ColoredBox(color: bg, child: child);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics =
              _PhaseLayoutMetrics.fromViewport(constraints.maxHeight);

          if (_isTransitioning && _controller != null) {
            return _TransitioningPhaseStrip(
              controller: _controller!,
              metrics: metrics,
              l10n: widget.l10n,
              outgoingPhase: _outgoingPhase!,
              outgoingPalette: _outgoingPalette!,
              incomingPhase: _incomingPhase!,
              incomingPalette: _incomingPalette!,
              incomingRemainingSec: snap.remainingSec,
              revealedNextPhase: _revealedNextPhase,
            );
          }

          return _IdlePhaseStrip(
            metrics: metrics,
            l10n: widget.l10n,
            phase: snap.phase,
            palette: palette,
            remainingSec: snap.remainingSec,
            nextPhase: widget.nextPhase,
          );
        },
      ),
    );
  }
}

class _IdlePhaseStrip extends StatelessWidget {
  const _IdlePhaseStrip({
    required this.metrics,
    required this.l10n,
    required this.phase,
    required this.palette,
    required this.remainingSec,
    required this.nextPhase,
  });

  final _PhaseLayoutMetrics metrics;
  final AppLocalizations l10n;
  final WorkoutPhase phase;
  final WorkoutPhasePalette palette;
  final int remainingSec;
  final WorkoutPhase? nextPhase;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _anchoredSlot(
          anchorY: metrics.mainAnchorY,
          height: metrics.mainSlotHeight,
          child: _PhaseSlot(
            height: metrics.mainSlotHeight,
            phase: phase,
            palette: palette,
            l10n: l10n,
            styleT: 1,
            remainingSec: remainingSec,
          ),
        ),
        if (nextPhase != null)
          _anchoredSlot(
            anchorY: metrics.previewAnchorY,
            height: metrics.previewSlotHeight,
            child: _PhaseSlot(
              height: metrics.previewSlotHeight,
              phase: nextPhase!,
              palette: palette,
              l10n: l10n,
              styleT: 0,
              remainingSec: nextPhase!.durationSec,
              showNextLabel: true,
            ),
          ),
      ],
    );
  }
}

class _TransitioningPhaseStrip extends StatelessWidget {
  const _TransitioningPhaseStrip({
    required this.controller,
    required this.metrics,
    required this.l10n,
    required this.outgoingPhase,
    required this.outgoingPalette,
    required this.incomingPhase,
    required this.incomingPalette,
    required this.incomingRemainingSec,
    required this.revealedNextPhase,
  });

  final AnimationController controller;
  final _PhaseLayoutMetrics metrics;
  final AppLocalizations l10n;
  final WorkoutPhase outgoingPhase;
  final WorkoutPhasePalette outgoingPalette;
  final WorkoutPhase incomingPhase;
  final WorkoutPhasePalette incomingPalette;
  final int incomingRemainingSec;
  final WorkoutPhase? revealedNextPhase;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = Curves.easeInOutCubic.transform(controller.value);
          final outgoingCenterY = metrics.mainAnchorY - t * metrics.scrollStep;
          final incomingCenterY =
              metrics.previewAnchorY - t * metrics.scrollStep;
          final incomingHeight = metrics.incomingSlotHeight(t);
          final outgoingFade =
              (1 - Curves.easeIn.transform(t.clamp(0, 1))).clamp(0.0, 1.0);
          final revealOpacity = Curves.easeOut.transform(
            ((t - 0.5) / 0.5).clamp(0.0, 1.0),
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              _anchoredSlot(
                anchorY: outgoingCenterY,
                height: metrics.mainSlotHeight,
                child: Opacity(
                  opacity: outgoingFade,
                  child: _PhaseSlot(
                    height: metrics.mainSlotHeight,
                    phase: outgoingPhase,
                    palette: outgoingPalette,
                    l10n: l10n,
                    styleT: 1,
                    remainingSec: 0,
                  ),
                ),
              ),
              _anchoredSlot(
                anchorY: incomingCenterY,
                height: incomingHeight,
                child: _PhaseSlot(
                  height: incomingHeight,
                  phase: incomingPhase,
                  palette: incomingPalette,
                  l10n: l10n,
                  styleT: t,
                  remainingSec: incomingRemainingSec,
                  showNextLabel: t < 0.18,
                ),
              ),
              if (revealedNextPhase != null)
                _anchoredSlot(
                  anchorY: metrics.previewAnchorY,
                  height: metrics.previewSlotHeight,
                  child: Opacity(
                    opacity: revealOpacity,
                    child: _PhaseSlot(
                      height: metrics.previewSlotHeight,
                      phase: revealedNextPhase!,
                      palette: incomingPalette,
                      l10n: l10n,
                      styleT: 0,
                      remainingSec: revealedNextPhase!.durationSec,
                      showNextLabel: true,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

Widget _anchoredSlot({
  required double anchorY,
  required double height,
  required Widget child,
}) {
  return Positioned(
    left: 0,
    right: 0,
    top: anchorY - height / 2,
    child: child,
  );
}

class _PhaseSlot extends StatelessWidget {
  const _PhaseSlot({
    required this.height,
    required this.phase,
    required this.palette,
    required this.l10n,
    required this.styleT,
    required this.remainingSec,
    this.showNextLabel = false,
  });

  final double height;
  final WorkoutPhase phase;
  final WorkoutPhasePalette palette;
  final AppLocalizations l10n;
  final double styleT;
  final int remainingSec;
  final bool showNextLabel;

  double _lerp(double from, double to) => from + (to - from) * styleT;

  @override
  Widget build(BuildContext context) {
    final phaseTitle = phase.kind.title(l10n);
    final showPhaseLabel =
        phase.label.isNotEmpty && phase.label != phaseTitle;
    final color = palette.onPanel;
    final muted = color.withValues(alpha: 0.55);
    final textColor = Color.lerp(muted, color, styleT) ?? color;
    final titleSize = _lerp(22, 34);
    final labelSize = _lerp(16, 20);
    final timerSize = _lerp(18, 88);
    final titleWeight = styleT < 0.5 ? FontWeight.w700 : FontWeight.w800;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showNextLabel) ...[
              Text(
                l10n.workoutNext,
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              phaseTitle,
              style: TextStyle(
                color: textColor,
                fontSize: titleSize,
                fontWeight: titleWeight,
                letterSpacing: 0.5,
              ),
            ),
            if (showPhaseLabel && styleT > 0.25) ...[
              SizedBox(height: _lerp(4, 8)),
              Opacity(
                opacity: ((styleT - 0.25) / 0.75).clamp(0.0, 1.0),
                child: Text(
                  phase.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.72),
                    fontSize: labelSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            SizedBox(height: _lerp(8, 20)),
            Text(
              formatDurationClock(remainingSec),
              style: TextStyle(
                color: textColor,
                fontSize: timerSize,
                height: 1,
                fontWeight: FontWeight.w300,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
