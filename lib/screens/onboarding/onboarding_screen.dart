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

typedef OnboardingCompleteCallback = Future<void> Function({required String path});

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.onComplete,
  });

  final RoutineRepository repository;
  final OnboardingCompleteCallback onComplete;

  Future<void> _finish(BuildContext context, {required String path}) async {
    await onComplete(path: path);
  }

  Future<void> _openQuickStart(BuildContext context) async {
    final finished = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (routeContext) => OnboardingRecommendedRoutinesScreen(
          repository: repository,
          onComplete: () async {
            Navigator.of(routeContext).pop(true);
          },
        ),
      ),
    );
    if (finished == true && context.mounted) {
      await onComplete(path: 'quick_start');
    }
  }

  Future<void> _openYoutubeAi(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AiRoutineCreateScreen(
          repository: repository,
          aiRoutineService: AiRoutineService(),
          initialPrompt: l10n.onboardingAiYoutubeInitialPrompt,
        ),
      ),
    );
    if (!context.mounted) return;
    await _finish(context, path: 'youtube_ai');
  }

  Future<void> _openGoalFlow(BuildContext context) async {
    final prompt = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const OnboardingGoalScreen(),
      ),
    );
    if (!context.mounted || prompt == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AiRoutineCreateScreen(
          repository: repository,
          aiRoutineService: AiRoutineService(),
          initialPrompt: prompt,
        ),
      ),
    );
    if (!context.mounted) return;
    await _finish(context, path: 'goal_ai');
  }

  Future<void> _openCreateRoutine(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final routine = createEmptyRoutine().copyWith(
      title: l10n.defaultRoutineName,
    );
    await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: repository,
          routine: routine,
          isNew: true,
        ),
      ),
    );
    if (!context.mounted) return;
    await _finish(context, path: 'create');
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
              onTap: () => _openQuickStart(context),
            ),
            _OnboardingOptionCard(
              icon: Icons.play_circle_outline,
              title: l10n.onboardingOptionYoutubeTitle,
              subtitle: l10n.onboardingOptionYoutubeSubtitle,
              onTap: () => _openYoutubeAi(context),
            ),
            _OnboardingOptionCard(
              icon: Icons.track_changes_outlined,
              title: l10n.onboardingOptionGoalTitle,
              subtitle: l10n.onboardingOptionGoalSubtitle,
              onTap: () => _openGoalFlow(context),
            ),
            _OnboardingOptionCard(
              icon: Icons.edit_outlined,
              title: l10n.onboardingOptionCreateTitle,
              subtitle: l10n.onboardingOptionCreateSubtitle,
              onTap: () => _openCreateRoutine(context),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => _finish(context, path: 'skip'),
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
  final VoidCallback onTap;

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
