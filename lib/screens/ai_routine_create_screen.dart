import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_lib/share_lib.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../models/routine.dart';
import '../services/app_analytics_service.dart';
import '../services/ai_routine_service.dart';
import '../services/routine_api_client.dart';
import '../utils/content_language.dart';
import '../widgets/ai_routine_generating_overlay.dart';
import 'routine_editor_screen.dart';

class AiRoutineCreateScreen extends StatefulWidget {
  const AiRoutineCreateScreen({
    super.key,
    required this.repository,
    required this.aiRoutineService,
    this.initialPrompt,
    /// When true, save the generated routine and pop immediately (no editor).
    /// Used by onboarding so the user can start the workout right away.
    this.autoSaveWithoutEditor = false,
  });

  final RoutineRepository repository;
  final AiRoutineService aiRoutineService;
  final String? initialPrompt;
  final bool autoSaveWithoutEditor;

  @override
  State<AiRoutineCreateScreen> createState() => _AiRoutineCreateScreenState();
}

class _AiRoutineCreateScreenState extends State<AiRoutineCreateScreen> {
  late final TextEditingController _promptController;
  bool _loading = false;
  bool _loadingAd = false;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.initialPrompt ?? '');
    unawaited(
      AppAnalyticsService.logProductEvent(
        'ai_create_opened',
        properties: {
          'source': widget.initialPrompt == null ? 'home' : 'onboarding',
        },
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _showConfiguredAd() async {
    final completer = Completer<void>();
    await AppAnalyticsService.logProductEvent('ai_ad_requested');
    try {
      await AdService.shared.showAd(
        onAdDismissed: () {
          unawaited(
            AppAnalyticsService.logProductEvent('ai_ad_dismissed'),
          );
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToShow: () {
          unawaited(AppAnalyticsService.logProductEvent('ai_ad_failed'));
          if (!completer.isCompleted) completer.complete();
        },
        onUserEarnedReward: (_) {
          // Reward is optional for AI flow; dismiss still completes the gate.
        },
      );
      await completer.future.timeout(const Duration(seconds: 90));
    } catch (error) {
      await AppAnalyticsService.logProductEvent('ai_ad_failed');
      // Ad failures must not block routine generation.
      debugPrint('[AiRoutineCreate] AdService.showAd error: $error');
      if (!completer.isCompleted) completer.complete();
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context);
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiRoutineCreatePromptRequired)),
      );
      return;
    }
    await AppAnalyticsService.logProductEvent(
      'ai_prompt_submitted',
      properties: {
        'prompt_length_bucket': prompt.length <= 100
            ? '1_to_100'
            : prompt.length <= 300
                ? '101_to_300'
                : '301_plus',
        'has_video_url': prompt.contains('youtu'),
      },
    );

    setState(() => _loadingAd = true);
    try {
      await _showConfiguredAd();
    } finally {
      if (mounted) {
        setState(() => _loadingAd = false);
      }
    }
    if (!mounted) return;

    setState(() => _loading = true);
    await AppAnalyticsService.logProductEvent('ai_generation_started');
    if (!mounted) return;
    try {
      final contentLanguage = ContentLanguage.current(
        systemLocale: Localizations.localeOf(context),
      );
      final routine = await widget.aiRoutineService.generateRoutine(
        prompt: prompt,
        contentLanguage: contentLanguage,
      );
      await AppAnalyticsService.logProductEvent(
        'ai_generation_succeeded',
        properties: {
          'exercise_count_bucket': routine.exercises.length <= 3
              ? '1_to_3'
              : routine.exercises.length <= 6
                  ? '4_to_6'
                  : '7_plus',
        },
      );
      if (!mounted) return;
      setState(() => _loading = false);

      if (widget.autoSaveWithoutEditor) {
        if (routine.exercises.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.requireAtLeastOneExercise)),
          );
          return;
        }
        await widget.repository.upsert(routine);
        await AppAnalyticsService.logProductEvent(
          'ai_routine_saved',
          properties: {'edited_before_save': false},
        );
        if (!mounted) return;
        Navigator.of(context).pop(routine);
        return;
      }

      await AppAnalyticsService.logProductEvent('ai_editor_opened');
      if (!mounted) return;
      final saved = await Navigator.of(context).push<Routine>(
        MaterialPageRoute(
          builder: (_) => RoutineEditorScreen(
            repository: widget.repository,
            routine: routine,
            isNew: true,
          ),
        ),
      );
      if (!mounted) return;
      if (saved != null) {
        await AppAnalyticsService.logProductEvent(
          'ai_routine_saved',
          properties: {'edited_before_save': true},
        );
        if (!mounted) return;
        Navigator.of(context).pop(saved);
      } else {
        await AppAnalyticsService.logProductEvent('ai_routine_abandoned');
      }
    } on RoutineApiException catch (error) {
      await AppAnalyticsService.logProductEvent(
        'ai_generation_failed',
        properties: {'reason': 'api'},
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      await AppAnalyticsService.logProductEvent(
        'ai_generation_failed',
        properties: {'reason': 'unknown'},
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiRoutineCreateError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 22,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.aiRoutineCreateTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const _AiPromptHero(),
              const SizedBox(height: 20),
              TextField(
                controller: _promptController,
                minLines: 8,
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.aiRoutineCreatePromptHint,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF9E9EA7),
                  ),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: (_loading || _loadingAd) ? null : _submit,
                child: Text(l10n.aiRoutineCreateSubmit),
              ),
            ],
          ),
          if (_loadingAd)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.25),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.aiRoutineCreateAdLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_loading) const AiRoutineGeneratingOverlay(),
        ],
      ),
    );
  }
}

class _AiPromptHero extends StatelessWidget {
  const _AiPromptHero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      height: 148,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.16),
              scheme.tertiary.withValues(alpha: 0.18),
              scheme.primary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -28,
                top: -36,
                child: _HeroBlob(
                  size: 120,
                  color: scheme.primary.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                right: 36,
                bottom: -40,
                child: _HeroBlob(
                  size: 100,
                  color: scheme.tertiary.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -24,
                child: _HeroBlob(
                  size: 88,
                  color: scheme.primary.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          Icons.smart_toy_rounded,
                          size: 40,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.aiRoutineCreateTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.aiRoutineCreatePromptLead,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 28,
                      color: scheme.tertiary.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBlob extends StatelessWidget {
  const _HeroBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
