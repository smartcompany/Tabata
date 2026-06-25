import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../models/routine.dart';
import '../services/locale_settings.dart';
import '../utils/duration_calculator.dart';
import 'import_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';
import '../widgets/app_settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.localeSettings,
    required this.onLocaleChanged,
  });

  final RoutineRepository repository;
  final LocaleSettings localeSettings;
  final VoidCallback onLocaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Routine> _routines = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      await widget.repository.refreshRemoteProfiles();
      if (!mounted) return;
      setState(() {
        _routines = widget.repository.loadAll();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _routines = widget.repository.loadAll();
        _loading = false;
        _loadError = AppLocalizations.of(context).profileLoadError;
      });
    }
  }

  Future<void> _openImport() async {
    final imported = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(builder: (_) => const ImportRoutineScreen()),
    );
    if (imported == null) return;
    await widget.repository.upsert(imported);
    _load();
  }

  Future<void> _createRoutine() async {
    final routine = createEmptyRoutine();
    final saved = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
          isNew: true,
        ),
      ),
    );
    if (saved == null) return;
    _load();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final updated = List<Routine>.from(_routines);
      final item = updated.removeAt(oldIndex);
      updated.insert(newIndex, item);
      _routines = updated;
    });
    widget.repository.saveListOrder(_routines.map((routine) => routine.id).toList());
  }

  Future<void> _openRoutine(Routine routine) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          repository: widget.repository,
          routineId: routine.id,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => showAppSettingsSheet(context),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
          ),
          IconButton(
            onPressed: _openImport,
            icon: const Icon(Icons.download_outlined),
            tooltip: l10n.importRoutineTooltip,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loadingProfiles),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  88 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  if (_loadError != null) ...[
                    _ErrorBanner(
                      message: _loadError!,
                      onRetry: _load,
                      retryLabel: l10n.retry,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_routines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Text(l10n.noRoutines)),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: _routines.length,
                      onReorder: _onReorder,
                      itemBuilder: (context, index) {
                        final routine = _routines[index];
                        final duration = routineDurationSec(routine);
                        return Padding(
                          key: ValueKey(routine.id),
                          padding: EdgeInsets.only(
                            bottom: index == _routines.length - 1 ? 0 : 12,
                          ),
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: ReorderableDragStartListener(
                                index: index,
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              title: Text(
                                routine.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  l10n.routineCountDuration(
                                    routine.orderedExercises.length,
                                    formatDurationShort(duration, l10n),
                                  ),
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openRoutine(routine),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRoutine,
        icon: const Icon(Icons.add),
        label: Text(l10n.createRoutine),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        title: Text(message),
        trailing: TextButton(
          onPressed: onRetry,
          child: Text(retryLabel),
        ),
      ),
    );
  }
}
