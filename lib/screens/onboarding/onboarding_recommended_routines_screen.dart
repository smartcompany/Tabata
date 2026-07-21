import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../../data/routine_repository.dart';
import '../../models/profile_summary.dart';
import '../../services/app_analytics_service.dart';
import '../../services/app_settings_service.dart';

/// Returns the local routine id to open after onboarding, if any.
typedef OnboardingRecommendedCompleteCallback = Future<void> Function(
  String? openRoutineId,
);

class OnboardingRecommendedRoutinesScreen extends StatefulWidget {
  const OnboardingRecommendedRoutinesScreen({
    super.key,
    required this.repository,
    required this.onComplete,
    this.compactActivationMode = false,
  });

  final RoutineRepository repository;
  final OnboardingRecommendedCompleteCallback onComplete;

  /// Skip-path activation: one short routine, no multi-select.
  final bool compactActivationMode;

  @override
  State<OnboardingRecommendedRoutinesScreen> createState() =>
      _OnboardingRecommendedRoutinesScreenState();
}

class _OnboardingRecommendedRoutinesScreenState
    extends State<OnboardingRecommendedRoutinesScreen> {
  bool _loading = true;
  String? _error;
  List<ProfileSummary> _summaries = [];
  final Set<String> _selectedIds = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (widget.repository.officialCatalogSummaries.isEmpty) {
        await widget.repository.refreshRemoteProfiles();
      }

      final ids = await AppSettingsService.onboardingRecommendedRoutineIds();
      const preferredIds = [
        'first-try',
        'tabata-basic',
        'upper-body-warmup',
      ];
      final orderedIds = <String>{
        ...preferredIds,
        ...ids,
      }.toList();
      final summaries = <ProfileSummary>[];
      for (final id in orderedIds) {
        final summary = widget.repository.catalogSummaryFor(id);
        if (summary != null) {
          summaries.add(summary);
        }
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        final visible = widget.compactActivationMode
            ? summaries.take(1).toList(growable: false)
            : summaries;
        _summaries = visible;
        _selectedIds
          ..clear()
          ..addAll(visible.take(1).map((summary) => summary.id));
        if (visible.isEmpty) {
          _error = AppLocalizations.of(context).onboardingRecommendedLoadError;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).onboardingRecommendedLoadError;
      });
    }
  }

  Future<void> _saveSelected() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingRecommendedSelectAtLeastOne)),
      );
      return;
    }

    setState(() => _saving = true);
    var failed = false;
    String? firstOpenRoutineId;

    for (final summary in _summaries) {
      if (!_selectedIds.contains(summary.id)) continue;
      try {
        if (widget.repository.hasDownloadedCatalog(summary.id)) {
          final existing =
              widget.repository.myRoutinesForkedFromCatalog(summary.id);
          firstOpenRoutineId ??=
              existing.isNotEmpty ? existing.first.id : null;
          continue;
        }
        final forked = await widget.repository.forkCatalogProfile(summary.id);
        firstOpenRoutineId ??= forked.id;
      } catch (_) {
        failed = true;
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (failed || firstOpenRoutineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingRecommendedDownloadFailed)),
      );
      return;
    }

    await AppAnalyticsService.logRoutineDownload(
      source: widget.compactActivationMode ? 'onboarding_skip' : 'onboarding',
      count: _selectedIds.length,
    );

    await widget.onComplete(firstOpenRoutineId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final compact = widget.compactActivationMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          compact ? l10n.onboardingActivationTitle : l10n.onboardingRecommendedTitle,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: theme.colorScheme.errorContainer,
                      child: ListTile(
                        title: Text(_error!),
                        trailing: TextButton(
                          onPressed: _load,
                          child: Text(l10n.retry),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    compact
                        ? l10n.onboardingActivationSubtitle
                        : l10n.onboardingRecommendedSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: _summaries.length,
                    itemBuilder: (context, index) {
                      final summary = _summaries[index];
                      if (compact) {
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.fitness_center_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(
                              summary.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(summary.description),
                          ),
                        );
                      }
                      final selected = _selectedIds.contains(summary.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: CheckboxListTile(
                            value: selected,
                            onChanged: _saving
                                ? null
                                : (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedIds.add(summary.id);
                                      } else {
                                        _selectedIds.remove(summary.id);
                                      }
                                    });
                                  },
                            title: Text(
                              summary.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              l10n.routineCountOnly(summary.exerciseCount),
                            ),
                            secondary: Icon(
                              Icons.fitness_center_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: FilledButton(
                    onPressed: _saving || _summaries.isEmpty
                        ? null
                        : _saveSelected,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            compact
                                ? l10n.onboardingActivationStart
                                : l10n.onboardingRecommendedSave,
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
