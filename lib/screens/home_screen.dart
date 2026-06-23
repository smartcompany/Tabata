import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../models/routine.dart';
import '../utils/duration_calculator.dart';
import 'import_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final RoutineRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Routine> _routines;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _routines = widget.repository.loadAll());
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
            onPressed: _openImport,
            icon: const Icon(Icons.download_outlined),
            tooltip: l10n.importRoutineTooltip,
          ),
        ],
      ),
      body: _routines.isEmpty
          ? Center(child: Text(l10n.noRoutines))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _routines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final routine = _routines[index];
                final duration = routineDurationSec(routine);
                return Card(
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRoutine,
        icon: const Icon(Icons.add),
        label: Text(l10n.createRoutine),
      ),
    );
  }
}
