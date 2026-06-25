import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/routine_share_service.dart';
import '../utils/duration_calculator.dart';
import '../widgets/exercise_summary.dart';
import 'routine_editor_screen.dart';
import 'workout_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({
    super.key,
    required this.repository,
    this.routineId,
    this.catalogId,
  }) : assert(
          routineId != null || catalogId != null,
          'Provide either routineId or catalogId',
        );

  final RoutineRepository repository;
  final String? routineId;
  final String? catalogId;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final _shareService = RoutineShareService();
  final _shareButtonKey = GlobalKey();
  Routine? _routine;
  bool _loadingCatalog = false;
  String? _catalogLoadError;
  bool _downloading = false;

  bool get _isCatalogPreview => widget.catalogId != null;

  @override
  void initState() {
    super.initState();
    if (_isCatalogPreview) {
      _loadCatalogRoutine();
    } else {
      _routine = widget.repository.findById(widget.routineId!);
    }
  }

  Future<void> _loadCatalogRoutine() async {
    setState(() {
      _loadingCatalog = true;
      _catalogLoadError = null;
    });

    try {
      final routine =
          await widget.repository.fetchCatalogRoutine(widget.catalogId!);
      if (!mounted) return;
      setState(() {
        _routine = routine;
        _loadingCatalog = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCatalog = false;
        _catalogLoadError = AppLocalizations.of(context).profileLoadError;
      });
    }
  }

  void _reload() {
    if (_isCatalogPreview) {
      _loadCatalogRoutine();
      return;
    }
    setState(() => _routine = widget.repository.findById(widget.routineId!));
  }

  Future<void> _edit() async {
    final routine = _routine;
    if (routine == null || _isCatalogPreview) return;
    await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
        ),
      ),
    );
    if (!mounted) return;
    if (widget.repository.findById(widget.routineId!) == null) {
      Navigator.of(context).pop();
      return;
    }
    _reload();
  }

  Future<void> _share() async {
    final routine = _routine;
    if (routine == null) return;
    await _shareService.share(
      routine,
      sharePositionOrigin: _sharePositionOrigin(),
    );
  }

  Rect? _sharePositionOrigin() {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }

    final context = this.context;
    if (!context.mounted) return null;
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }

  Future<void> _deleteLocally() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoutineTitle),
        content: Text(l10n.deleteRoutineMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await widget.repository.delete(widget.routineId!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _downloadCatalog() async {
    final catalogId = widget.catalogId;
    final routine = _routine;
    if (catalogId == null || routine == null || _downloading) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _downloading = true);

    try {
      final forked = await widget.repository.forkCatalogProfile(catalogId);
      if (!mounted) return;
      setState(() => _downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineAddedToMyRoutines(forked.title))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineDownloadError)),
      );
    }
  }

  void _openFirstSavedCopy() {
    final catalogId = widget.catalogId;
    if (catalogId == null) return;
    final saved = widget.repository.myRoutinesForkedFromCatalog(catalogId);
    if (saved.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          repository: widget.repository,
          routineId: saved.first.id,
        ),
      ),
    );
  }

  void _openWorkout(Routine routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(routine: routine),
        fullscreenDialog: true,
      ),
    );
  }

  void _start() {
    final routine = _routine;
    if (routine == null) return;
    _openWorkout(routine);
  }

  void _startExercise(Exercise exercise) {
    final routine = _routine;
    if (routine == null) return;
    _openWorkout(routine.forSingleExercise(exercise));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isCatalogPreview && _loadingCatalog) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loadingProfiles),
            ],
          ),
        ),
      );
    }

    if (_catalogLoadError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_catalogLoadError!),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadCatalogRoutine,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final routine = _routine;
    if (routine == null) {
      return Scaffold(
        body: Center(child: Text(l10n.routineNotFound)),
      );
    }

    if (!_isCatalogPreview &&
        !widget.repository.isLocalRoutine(widget.routineId!)) {
      return Scaffold(
        appBar: AppBar(title: Text(routine.title)),
        body: Center(child: Text(l10n.routineNotFound)),
      );
    }

    final exercises = routine.orderedExercises;
    final totalSec = routineDurationSec(routine);
    final savedCopies = _isCatalogPreview
        ? widget.repository.myRoutinesForkedFromCatalog(widget.catalogId!)
        : const <Routine>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.title),
        actions: [
          if (_isCatalogPreview)
            IconButton(
              onPressed: _downloading ? null : _downloadCatalog,
              tooltip: l10n.downloadRoutineTooltip,
              icon: _downloading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      savedCopies.isEmpty
                          ? Icons.download_outlined
                          : Icons.download_done_outlined,
                    ),
            )
          else
            IconButton(
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editTooltip,
            ),
          IconButton(
            key: _shareButtonKey,
            onPressed: _share,
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.shareTooltip,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (_isCatalogPreview && savedCopies.isNotEmpty) ...[
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                title: Text(
                  l10n.catalogSavedCount(savedCopies.length),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _openFirstSavedCopy,
                  child: Text(l10n.openSavedCopy),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (routine.description.isNotEmpty) ...[
            Text(
              routine.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          EstimatedDurationCard(totalSec: totalSec),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.exerciseListTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: Text(l10n.startAll),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...exercises.map(
            (exercise) => ExerciseDetailCard(
              exercise: exercise,
              onTap: _isCatalogPreview ? null : _edit,
              onStart: () => _startExercise(exercise),
            ),
          ),
          if (!_isCatalogPreview) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _deleteLocally,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteRoutineTitle),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
