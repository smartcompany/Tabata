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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => showAppSettingsSheet(
              context,
              localeSettings: widget.localeSettings,
              onLocaleChanged: widget.onLocaleChanged,
            ),
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
                padding: const EdgeInsets.all(16),
                children: [
                  if (_loadError != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        title: Text(_loadError!),
                        trailing: TextButton(
                          onPressed: _load,
                          child: Text(l10n.retry),
                        ),
                      ),
                    ),
                  if (_routines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Text(l10n.noRoutines)),
                    )
                  else
                    ...List.generate(_routines.length, (index) {
                      final routine = _routines[index];
                      final duration = routineDurationSec(routine);
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _routines.length - 1 ? 0 : 12,
                        ),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
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
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RoutineDetailScreen(
                                    repository: widget.repository,
                                    routineId: routine.id,
                                  ),
                                ),
                              );
                              _load();
                            },
                          ),
                        ),
                      );
                    }),
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
