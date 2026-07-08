import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

/// Full-screen overlay while AI builds a routine.
/// Cycles stage copy and slowly advances a determinate progress bar
/// so waiting feels like work is finishing.
class AiRoutineGeneratingOverlay extends StatefulWidget {
  const AiRoutineGeneratingOverlay({super.key});

  @override
  State<AiRoutineGeneratingOverlay> createState() =>
      _AiRoutineGeneratingOverlayState();
}

class _AiRoutineGeneratingOverlayState extends State<AiRoutineGeneratingOverlay>
    with SingleTickerProviderStateMixin {
  static const _stageInterval = Duration(milliseconds: 2600);
  static const _progressTick = Duration(milliseconds: 120);
  static const _maxIndeterminateProgress = 0.92;

  late final AnimationController _pulse;
  Timer? _stageTimer;
  Timer? _progressTimer;
  var _stageIndex = 0;
  var _progress = 0.08;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _stageTimer = Timer.periodic(_stageInterval, (_) {
      if (!mounted) return;
      setState(() => _stageIndex += 1);
    });
    _progressTimer = Timer.periodic(_progressTick, (_) {
      if (!mounted) return;
      setState(() {
        // Ease toward ~92% then stall; real completion dismisses the overlay.
        final remaining = _maxIndeterminateProgress - _progress;
        if (remaining <= 0.002) return;
        _progress += remaining * 0.035;
      });
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _progressTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  List<String> _stages(AppLocalizations l10n) => [
        l10n.aiRoutineCreateLoadingStage1,
        l10n.aiRoutineCreateLoadingStage2,
        l10n.aiRoutineCreateLoadingStage3,
        l10n.aiRoutineCreateLoadingStage4,
        l10n.aiRoutineCreateLoadingStage5,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stages = _stages(l10n);
    final stage = stages[_stageIndex % stages.length];
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final t = _pulse.value;
                      return Transform.scale(
                        scale: 0.94 + (t * 0.08),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 30,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.aiRoutineCreateLoading,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor:
                          colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      stage,
                      key: ValueKey<String>(stage),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.78),
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.aiRoutineCreateLoadingFooter,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9E9EA7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
