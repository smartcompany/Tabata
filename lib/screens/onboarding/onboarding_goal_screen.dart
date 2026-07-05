import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

enum _GoalOption {
  weightLoss,
  strength,
  flexibility,
  fullBody,
  upperBody,
  lowerBody,
  core,
}

enum _DurationOption { min5, min10, min15, min20 }

enum _LevelOption { beginner, intermediate }

class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  final _pageController = PageController();
  int _page = 0;

  _GoalOption _goal = _GoalOption.fullBody;
  _DurationOption _duration = _DurationOption.min10;
  _LevelOption _level = _LevelOption.beginner;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _goalLabel(AppLocalizations l10n, _GoalOption option) {
    return switch (option) {
      _GoalOption.weightLoss => l10n.onboardingGoalOptionWeightLoss,
      _GoalOption.strength => l10n.onboardingGoalOptionStrength,
      _GoalOption.flexibility => l10n.onboardingGoalOptionFlexibility,
      _GoalOption.fullBody => l10n.onboardingGoalOptionFullBody,
      _GoalOption.upperBody => l10n.onboardingGoalOptionUpperBody,
      _GoalOption.lowerBody => l10n.onboardingGoalOptionLowerBody,
      _GoalOption.core => l10n.onboardingGoalOptionCore,
    };
  }

  String _durationLabel(AppLocalizations l10n, _DurationOption option) {
    return switch (option) {
      _DurationOption.min5 => l10n.onboardingGoalDuration5,
      _DurationOption.min10 => l10n.onboardingGoalDuration10,
      _DurationOption.min15 => l10n.onboardingGoalDuration15,
      _DurationOption.min20 => l10n.onboardingGoalDuration20,
    };
  }

  int _durationMinutes(_DurationOption option) {
    return switch (option) {
      _DurationOption.min5 => 5,
      _DurationOption.min10 => 10,
      _DurationOption.min15 => 15,
      _DurationOption.min20 => 20,
    };
  }

  String _levelLabel(AppLocalizations l10n, _LevelOption option) {
    return switch (option) {
      _LevelOption.beginner => l10n.onboardingGoalLevelBeginner,
      _LevelOption.intermediate => l10n.onboardingGoalLevelIntermediate,
    };
  }

  void _nextPage() {
    if (_page >= 2) {
      _submit();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final prompt = l10n.onboardingAiGoalPrompt(
      _goalLabel(l10n, _goal),
      _durationMinutes(_duration).toString(),
      _levelLabel(l10n, _level),
    );
    Navigator.of(context).pop(prompt);
  }

  Widget _chipPage<T>({
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T) labelFor,
    required ValueChanged<T> onSelected,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(labelFor(option)),
                selected: selected == option,
                onSelected: (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingGoalTitle),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_page + 1) / 3,
            minHeight: 3,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _page = index),
              children: [
                _chipPage<_GoalOption>(
                  title: l10n.onboardingGoalStepGoal,
                  options: _GoalOption.values,
                  selected: _goal,
                  labelFor: (option) => _goalLabel(l10n, option),
                  onSelected: (value) => setState(() => _goal = value),
                ),
                _chipPage<_DurationOption>(
                  title: l10n.onboardingGoalStepDuration,
                  options: _DurationOption.values,
                  selected: _duration,
                  labelFor: (option) => _durationLabel(l10n, option),
                  onSelected: (value) => setState(() => _duration = value),
                ),
                _chipPage<_LevelOption>(
                  title: l10n.onboardingGoalStepLevel,
                  options: _LevelOption.values,
                  selected: _level,
                  labelFor: (option) => _levelLabel(l10n, option),
                  onSelected: (value) => setState(() => _level = value),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: [
                if (_page > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Text(l10n.back),
                  )
                else
                  const Spacer(),
                const Spacer(),
                FilledButton(
                  onPressed: _nextPage,
                  child: Text(
                    _page >= 2
                        ? l10n.onboardingGoalCreate
                        : l10n.onboardingGoalNext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
