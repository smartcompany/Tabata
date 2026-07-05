import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../data/routine_factory.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/health_permission_flow.dart';
import '../services/health_workout_recorder.dart';
import '../services/routine_schedule_service.dart';
import '../services/routine_share_api.dart';
import '../services/routine_share_service.dart';
import '../services/workout_completion_recorder.dart';
import '../utils/duration_calculator.dart';
import '../widgets/description_blocks_view.dart';
import '../widgets/exercise_summary.dart';
import '../widgets/health_activity_type_picker.dart';
import '../widgets/routine_schedule_sheet.dart';
import '../widgets/routine_share_sheet.dart';
import '../models/routine_schedule.dart';
import 'exercise_editor_screen.dart';
import 'routine_editor_screen.dart';
import 'workout_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({
    super.key,
    required this.repository,
    required this.workoutCompletionRecorder,
    this.routineId,
    this.catalogId,
  }) : assert(
          routineId != null || catalogId != null,
          'Provide either routineId or catalogId',
        );

  final RoutineRepository repository;
  final WorkoutCompletionRecorder workoutCompletionRecorder;
  final String? routineId;
  final String? catalogId;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  Routine? _routine;
  RoutineSchedule? _schedule;
  bool _loadingCatalog = false;
  String? _catalogLoadError;
  bool _downloading = false;
  final _shareService = RoutineShareService();
  final _shareApi = RoutineShareApi();

  bool get _isCatalogPreview => widget.catalogId != null;

  @override
  void initState() {
    super.initState();
    if (_isCatalogPreview) {
      _loadCatalogRoutine();
    } else {
      _routine = widget.repository.findById(widget.routineId!);
      _refreshSchedule();
    }
  }

  void _refreshSchedule() {
    final routineId = widget.routineId;
    if (routineId == null) return;
    final schedule = RoutineScheduleService.shared.scheduleFor(routineId);
    if (schedule != null && schedule.isExpired(DateTime.now())) {
      unawaited(RoutineScheduleService.shared.cancelForRoutine(routineId));
      _schedule = null;
      return;
    }
    _schedule =
        schedule != null && schedule.isActiveAt(DateTime.now()) ? schedule : null;
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

  Future<void> _edit() async {
    final routine = _routine;
    if (routine == null || _isCatalogPreview) return;
    final updated = await Navigator.of(context).push<Routine>(
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
    setState(() {
      _routine = updated ?? widget.repository.findById(widget.routineId!);
    });
  }

  Future<void> _share() async {
    final routine = _routine;
    if (routine == null) return;
    final l10n = AppLocalizations.of(context);

    Uri linkUrl;
    try {
      linkUrl = await _shareApi.createShareLink(routine);
    } on RoutineShareApiException {
      if (!mounted) return;
      linkUrl = RoutineShareService.storeLink;
    }

    if (!mounted) return;
    await RoutineShareSheet.show(
      context: context,
      shareText: _shareService.buildShareMessage(routine, l10n),
      kakaoShareText: _shareService.buildKakaoShareMessage(routine, l10n),
      subject: routine.title,
      linkUrl: linkUrl,
    );
  }

  String _catalogAuthorLabel(AppLocalizations l10n) {
    final catalogId = widget.catalogId;
    if (catalogId == null) return l10n.catalogAuthorUnknown;

    final summary = widget.repository.catalogSummaryFor(catalogId);
    if (summary == null) return l10n.catalogAuthorUnknown;

    if (summary.isOfficialCatalog) {
      return l10n.catalogAuthor(l10n.appTitle);
    }

    final name = summary.ownerName?.trim();
    if (name != null && name.isNotEmpty) {
      return l10n.catalogAuthor(name);
    }

    return l10n.catalogAuthor(l10n.catalogAuthorUnknown);
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

    await RoutineScheduleService.shared.cancelForRoutine(widget.routineId!);
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
      await widget.repository.forkCatalogProfile(catalogId);
      if (!mounted) return;
      setState(() => _downloading = false);
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
          workoutCompletionRecorder: widget.workoutCompletionRecorder,
          routineId: saved.first.id,
        ),
      ),
    );
  }

  Future<void> _openWorkout(Routine routine) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          routine: routine,
          completionRecorder: widget.workoutCompletionRecorder,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _start() async {
    final routine = _routine;
    if (routine == null) return;
    await _openWorkout(routine);
  }

  Future<void> _startExercise(Exercise exercise) async {
    final routine = _routine;
    if (routine == null) return;
    await _openWorkout(routine.forSingleExercise(exercise));
  }

  Future<void> _setHealthActivityType(String? healthActivityType) async {
    final routine = _routine;
    final routineId = widget.routineId;
    if (routine == null || routineId == null || _isCatalogPreview) return;

    if (healthActivityType != null && HealthWorkoutRecorder.isSupported) {
      await HealthPermissionFlow.maybePromptOnHealthActivityTypeSelected(
        context,
      );
      if (!mounted) return;
    }

    final updated = routine.copyWith(healthActivityType: healthActivityType);
    await widget.repository.upsert(updated);
    if (!mounted) return;
    if (widget.repository.findById(routineId) == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _routine = widget.repository.findById(routineId);
    });
  }

  Future<void> _openScheduleSheet() async {
    final routine = _routine;
    if (routine == null || _isCatalogPreview) return;

    final changed = await RoutineScheduleSheet.show(
      context,
      routine: routine,
      existing: _schedule,
    );
    if (!mounted) return;
    if (changed == true) {
      setState(_refreshSchedule);
    }
  }

  String? _scheduleLabel(AppLocalizations l10n) {
    final schedule = _schedule;
    if (schedule == null || !schedule.isActiveAt(DateTime.now())) {
      return null;
    }
    return schedule.summary(l10n, MaterialLocalizations.of(context));
  }

  Future<void> _editExercise(Exercise exercise) async {
    final routine = _routine;
    final routineId = widget.routineId;
    if (routine == null || routineId == null || _isCatalogPreview) return;

    final exercises = routine.orderedExercises;
    final index = exercises.indexWhere((item) => item.id == exercise.id);
    if (index < 0) return;

    final updated = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseEditorScreen(exercise: exercise),
      ),
    );
    if (updated == null || !mounted) return;

    final nextExercises = List<Exercise>.from(exercises);
    nextExercises[index] = updated;
    final nextRoutine = routine.copyWith(
      exercises: reindexExercises(nextExercises),
    );
    await widget.repository.upsert(nextRoutine);
    if (!mounted) return;
    if (widget.repository.findById(routineId) == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _routine = widget.repository.findById(routineId);
    });
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
        toolbarHeight: 64,
        title: Text(
          routine.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
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
          else ...[
            IconButton(
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editTooltip,
            ),
          ],
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
          if (routine.effectiveDescriptionBlocks.isNotEmpty) ...[
            DescriptionBlocksView(blocks: routine.effectiveDescriptionBlocks),
            const SizedBox(height: 16),
          ] else if (routine.description.isNotEmpty) ...[
            Text(
              routine.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          if (_isCatalogPreview) ...[
            Text(
              _catalogAuthorLabel(l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
          ],
          if (HealthWorkoutRecorder.isSupported && !_isCatalogPreview) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
                child: HealthActivityTypePicker(
                  value: routine.healthActivityType,
                  showHeartStatus: true,
                  onChanged: _setHealthActivityType,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          EstimatedDurationCard(totalSec: totalSec),
          if (!_isCatalogPreview && _scheduleLabel(l10n) != null) ...[
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                title: Text(
                  _scheduleLabel(l10n)!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _openScheduleSheet,
                  child: Text(l10n.editTooltip),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.exerciseListTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (!_isCatalogPreview &&
                  RoutineScheduleService.shared.isSupported)
                Tooltip(
                  message: l10n.scheduleWorkoutTooltip,
                  child: OutlinedButton.icon(
                    onPressed: _openScheduleSheet,
                    icon: Icon(
                      _schedule != null &&
                              _schedule!.isActiveAt(DateTime.now())
                          ? Icons.notifications_active
                          : Icons.notifications_outlined,
                      size: 18,
                    ),
                    label: Text(l10n.scheduleWorkoutTooltip),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              if (!_isCatalogPreview &&
                  RoutineScheduleService.shared.isSupported)
                const SizedBox(width: 8),
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
              onEdit: _isCatalogPreview ? null : () => _editExercise(exercise),
              onStart: () => _startExercise(exercise),
            ),
          ),
          if (!_isCatalogPreview) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.ios_share),
                    label: Text(l10n.shareTooltip),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
            ),
          ],
        ],
      ),
    );
  }
}
