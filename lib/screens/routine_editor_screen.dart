import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../app_auth_provider.dart';
import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../models/description_block.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/routine_api_client.dart';
import '../services/app_analytics_service.dart';
import '../services/workout_completion_recorder.dart';
import '../utils/content_language.dart';
import '../utils/duration_calculator.dart';
import '../utils/form_validation_scroll.dart';
import '../widgets/description_blocks_editor.dart';
import '../widgets/exercise_summary.dart';
import '../widgets/import_exercises_sheet.dart';
import '../widgets/keyboard_dismiss_scope.dart';
import 'exercise_editor_screen.dart';

class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({
    super.key,
    required this.repository,
    required this.routine,
    this.isNew = false,
    this.apiClient,
    this.userAuthToken,
    this.adminToken,
    this.persistToServer = false,
    this.persistToDashboard = false,
    this.completionRecorder,
  });

  final RoutineRepository repository;
  final Routine routine;
  final bool isNew;
  final RoutineApiClient? apiClient;
  final String? userAuthToken;
  final String? adminToken;
  final bool persistToServer;
  final bool persistToDashboard;
  final WorkoutCompletionRecorder? completionRecorder;

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _exercisesSectionKey = GlobalKey();
  late final TextEditingController _titleController;
  late List<DescriptionBlock> _descriptionBlocks;
  late List<Exercise> _exercises;
  String? _resolvedAuthToken;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine.title);
    _descriptionBlocks = _initialDescriptionBlocks(widget.routine);
    _exercises = List<Exercise>.from(widget.routine.orderedExercises);
    _resolvedAuthToken = widget.userAuthToken;
    if (_resolvedAuthToken == null) {
      AppAuthProvider.shared.getIdToken().then((token) {
        if (!mounted) return;
        setState(() => _resolvedAuthToken = token);
      });
    }
  }

  List<DescriptionBlock> _initialDescriptionBlocks(Routine routine) {
    final blocks = List<DescriptionBlock>.from(routine.effectiveDescriptionBlocks);
    if (widget.isNew && blocks.isEmpty) {
      return [const TextDescriptionBlock(text: '')];
    }
    if (blocks.length == 1) {
      final only = blocks.first;
      if (only is TextDescriptionBlock && only.text.trim().isEmpty) {
        return [];
      }
    }
    return blocks;
  }

  List<DescriptionBlock> _normalizedDescriptionBlocks() {
    return _descriptionBlocks.where((block) {
      if (block is TextDescriptionBlock) {
        return block.text.trim().isNotEmpty;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Routine get _draft {
    final blocks = _normalizedDescriptionBlocks();
    return widget.routine.copyWith(
      title: _titleController.text.trim(),
      description: DescriptionBlock.plainText(blocks),
      descriptionBlocks: blocks,
      exercises: reindexExercises(_exercises),
    );
  }

  Future<bool> _persistDraft() async {
    final draft = _draft;
    if (widget.persistToDashboard) {
      final apiClient = widget.apiClient;
      final adminToken = widget.adminToken;
      if (apiClient == null || adminToken == null || adminToken.isEmpty) {
        return false;
      }
      if (draft.exercises.isEmpty) return false;

      final l10n = AppLocalizations.of(context);
      try {
        await apiClient.uploadProfile(
          routine: draft.copyWith(
            contentLanguage: ContentLanguage.current(
              systemLocale: Localizations.localeOf(context),
            ),
          ),
          adminToken: adminToken,
        );
        return true;
      } on RoutineApiException catch (error) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
        return false;
      } catch (_) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadError)),
        );
        return false;
      }
    }

    if (widget.persistToServer) {
      final apiClient = widget.apiClient;
      final userAuthToken = widget.userAuthToken ?? _resolvedAuthToken;
      if (apiClient == null || userAuthToken == null || userAuthToken.isEmpty) {
        return false;
      }
      if (draft.exercises.isEmpty) return false;

      final l10n = AppLocalizations.of(context);
      try {
        await apiClient.uploadUserProfile(
          routine: draft.copyWith(
            contentLanguage: ContentLanguage.current(
              systemLocale: Localizations.localeOf(context),
            ),
          ),
          userToken: userAuthToken,
        );
        return true;
      } on RoutineApiException catch (error) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
        return false;
      } catch (_) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadError)),
        );
        return false;
      }
    }

    await widget.repository.upsert(draft);
    return true;
  }

  Future<void> _save() async {
    if (!validateFormAndScrollToError(_formKey)) return;
    if (_exercises.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requireAtLeastOneExercise)),
      );
      scrollToKey(_exercisesSectionKey);
      return;
    }

    final saved = await _persistDraft();
    if (!saved || !mounted) return;
    await AppAnalyticsService.logProductEvent(
      widget.isNew ? 'routine_created' : 'routine_edited',
      properties: {
        'exercise_count_bucket': _exercises.length <= 3
            ? '1_to_3'
            : _exercises.length <= 6
                ? '4_to_6'
                : '7_plus',
      },
    );
    if (!mounted) return;
    Navigator.of(context).pop(_draft);
  }

  Future<void> _deleteRoutine() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoutineTitle),
        content: Text(
          widget.persistToDashboard || widget.persistToServer
              ? l10n.uploadDeleteServerRoutineMessage
              : l10n.deleteRoutineMessage,
        ),
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

    if (widget.persistToDashboard) {
      final apiClient = widget.apiClient;
      final adminToken = widget.adminToken;
      if (apiClient == null || adminToken == null) return;

      try {
        await apiClient.deleteDashboardProfile(
          profileId: widget.routine.id,
          adminToken: adminToken,
        );
      } on RoutineApiException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
        return;
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadError)),
        );
        return;
      }
    } else if (widget.persistToServer) {
      final apiClient = widget.apiClient;
      final userAuthToken = widget.userAuthToken;
      if (apiClient == null || userAuthToken == null) return;

      try {
        await apiClient.deleteUserProfile(
          profileId: widget.routine.id,
          userToken: userAuthToken,
        );
      } on RoutineApiException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
        return;
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadError)),
        );
        return;
      }
    } else {
      await widget.repository.delete(widget.routine.id);
    }

    if (!mounted) return;
    await AppAnalyticsService.logProductEvent(
      'routine_deleted',
      properties: {
        'scope': widget.persistToDashboard
            ? 'admin_server'
            : widget.persistToServer
                ? 'user_server'
                : 'local',
      },
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _persistDraftIfNeeded() async {
    await _persistDraft();
  }

  Future<void> _importExercisesFromRoutine() async {
    KeyboardDismissScope.dismiss(context);
    final imported = await ImportExercisesSheet.show(
      context: context,
      repository: widget.repository,
      excludeRoutineId: widget.routine.id,
    );
    if (imported == null || imported.isEmpty || !mounted) return;

    setState(() {
      _exercises = reindexExercises([..._exercises, ...imported]);
    });
    await _persistDraftIfNeeded();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.importExercisesAddedSnack(imported.length))),
    );
  }

  Future<void> _addExercise() async {
    KeyboardDismissScope.dismiss(context);
    final l10n = AppLocalizations.of(context);
    final exercise = createEmptyExercise(
      order: _exercises.length,
      relaxLabel: l10n.labelRelax,
    ).copyWith(name: l10n.defaultExerciseName);
    final result = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseEditorScreen(
          exercise: exercise,
          isNew: true,
          repository: widget.repository,
          completionRecorder: widget.completionRecorder,
          parentRoutine: _draft,
        ),
      ),
    );
    if (result == null) return;
    setState(() => _exercises = [..._exercises, result]);
    await _persistDraftIfNeeded();
  }

  Future<void> _editExercise(int index) async {
    KeyboardDismissScope.dismiss(context);
    final result = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseEditorScreen(
          exercise: _exercises[index],
          repository: widget.repository,
          completionRecorder: widget.completionRecorder,
          parentRoutine: _draft,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      final updated = List<Exercise>.from(_exercises);
      updated[index] = result;
      _exercises = updated;
    });
    await _persistDraftIfNeeded();
  }

  void _deleteExercise(int index) {
    KeyboardDismissScope.dismiss(context);
    setState(() {
      final updated = List<Exercise>.from(_exercises)..removeAt(index);
      _exercises = reindexExercises(updated);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    KeyboardDismissScope.dismiss(context);
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final updated = List<Exercise>.from(_exercises);
      final item = updated.removeAt(oldIndex);
      updated.insert(newIndex, item);
      _exercises = reindexExercises(updated);
    });
  }

  Widget _buildExerciseActions(AppLocalizations l10n) {
    final otherRoutines = widget.repository.myRoutines
        .where((routine) => routine.id != widget.routine.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add),
            label: Text(l10n.addExercisesPrompt),
          ),
        ),
        if (otherRoutines.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _importExercisesFromRoutine,
              icon: const Icon(Icons.library_add_outlined),
              label: Text(l10n.importExercisesButton),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final previewRoutine = _draft;
    final totalSec =
        _exercises.isEmpty ? 0 : routineDurationSec(previewRoutine);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNew
              ? l10n.createRoutineTitle
              : widget.persistToServer
                  ? l10n.uploadEditServerRoutineTitle
                  : l10n.editRoutineTitle,
        ),
        actions: [
          if (!widget.isNew)
            IconButton(
              onPressed: _deleteRoutine,
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteRoutineTooltip,
            ),
        ],
      ),
      body: KeyboardDismissScope(
        showAccessoryBar: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.routineNameLabel,
                  hintText: l10n.routineNameHint,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onEditingComplete: () => KeyboardDismissScope.dismiss(context),
                onTapOutside: (_) => KeyboardDismissScope.dismiss(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationNameRequired;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            const SizedBox(height: 12),
            DescriptionBlocksEditor(
              routineId: widget.routine.id,
              blocks: _descriptionBlocks,
              onChanged: (blocks) => setState(() => _descriptionBlocks = blocks),
            ),
            const SizedBox(height: 16),
            if (_exercises.isNotEmpty) EstimatedDurationCard(totalSec: totalSec),
            const SizedBox(height: 20),
            Row(
              key: _exercisesSectionKey,
              children: [
                Text(
                  l10n.exerciseListTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  l10n.reorderExercisesHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_exercises.isNotEmpty)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return ExerciseListTileCard(
                    key: ValueKey(exercise.id),
                    exercise: exercise,
                    index: index,
                    onTap: () => _editExercise(index),
                    onDelete: () => _deleteExercise(index),
                  );
                },
              ),
            if (_exercises.isNotEmpty) const SizedBox(height: 12),
            _buildExerciseActions(l10n),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
          ],
        ),
        ),
      ),
    );
  }
}
