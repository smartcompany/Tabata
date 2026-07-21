import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../../data/routine_factory.dart';
import '../../data/routine_repository.dart';
import '../../models/routine.dart';
import '../../services/ai_routine_service.dart';
import '../ai_routine_create_screen.dart';
import '../routine_editor_screen.dart';
import 'onboarding_goal_screen.dart';
import 'onboarding_recommended_routines_screen.dart';

typedef OnboardingCompleteCallback = Future<void> Function({
  required String path,
  String? openRoutineId,
});

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.onComplete,
  });

  final RoutineRepository repository;
  final OnboardingCompleteCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _finish({
    required String path,
    String? openRoutineId,
  }) async {
    await widget.onComplete(path: path, openRoutineId: openRoutineId);
  }

  Future<void> _openQuickStart() async {
    final openRoutineId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (routeContext) => OnboardingRecommendedRoutinesScreen(
          repository: widget.repository,
          onComplete: (routineId) async {
            Navigator.of(routeContext).pop(routineId);
          },
        ),
      ),
    );
    if (openRoutineId != null && mounted) {
      await _finish(path: 'quick_start', openRoutineId: openRoutineId);
    }
  }

  Future<void> _openYoutubeAi() async {
    final saved = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => AiRoutineCreateScreen(
          repository: widget.repository,
          aiRoutineService: AiRoutineService(),
          autoSaveWithoutEditor: true,
        ),
      ),
    );
    if (!mounted || saved == null) return;
    await _finish(path: 'youtube_ai', openRoutineId: saved.id);
  }

  Future<void> _openGoalFlow() async {
    final prompt = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const OnboardingGoalScreen(),
      ),
    );
    if (!mounted || prompt == null) return;

    final saved = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => AiRoutineCreateScreen(
          repository: widget.repository,
          aiRoutineService: AiRoutineService(),
          initialPrompt: prompt,
          autoSaveWithoutEditor: true,
        ),
      ),
    );
    if (!mounted || saved == null) return;
    await _finish(path: 'goal_ai', openRoutineId: saved.id);
  }

  Future<void> _openCreateRoutine() async {
    final l10n = AppLocalizations.of(context);
    final routine = createEmptyRoutine().copyWith(
      title: l10n.defaultRoutineName,
    );
    final saved = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
          isNew: true,
        ),
      ),
    );
    if (!mounted || saved == null) return;
    await _finish(path: 'create', openRoutineId: saved.id);
  }

  Future<void> _skipWithSeededRoutine() async {
    final openRoutineId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (routeContext) => OnboardingRecommendedRoutinesScreen(
          repository: widget.repository,
          compactActivationMode: true,
          onComplete: (routineId) async {
            Navigator.of(routeContext).pop(routineId);
          },
        ),
      ),
    );
    if (openRoutineId != null && mounted) {
      await _finish(path: 'skip', openRoutineId: openRoutineId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text(
              l10n.onboardingWelcomeTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingWelcomeSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 28),
            _OnboardingOptionCard(
              icon: Icons.directions_run_outlined,
              title: l10n.onboardingOptionQuickStartTitle,
              subtitle: l10n.onboardingOptionQuickStartSubtitle,
              onTap: _openQuickStart,
            ),
            _OnboardingOptionCard(
              icon: Icons.play_circle_outline,
              title: l10n.onboardingOptionYoutubeTitle,
              subtitle: l10n.onboardingOptionYoutubeSubtitle,
              onTap: _openYoutubeAi,
            ),
            _OnboardingOptionCard(
              icon: Icons.track_changes_outlined,
              title: l10n.onboardingOptionGoalTitle,
              subtitle: l10n.onboardingOptionGoalSubtitle,
              onTap: _openGoalFlow,
            ),
            _OnboardingOptionCard(
              icon: Icons.edit_outlined,
              title: l10n.onboardingOptionCreateTitle,
              subtitle: l10n.onboardingOptionCreateSubtitle,
              onTap: _openCreateRoutine,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _skipWithSeededRoutine,
                child: Text(l10n.onboardingSkip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingOptionCard extends StatelessWidget {
  const _OnboardingOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
