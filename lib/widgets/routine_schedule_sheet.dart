import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/routine.dart';
import '../models/routine_schedule.dart';
import '../models/schedule_recurrence.dart';
import '../services/routine_schedule_service.dart';
import '../utils/routine_schedule_format.dart';
import 'wheel_date_time_picker.dart';

class RoutineScheduleSheet {
  static Future<bool?> show(
    BuildContext context, {
    required Routine routine,
    required RoutineSchedule? existing,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _RoutineScheduleSheetBody(
        routine: routine,
        existing: existing,
      ),
    );
  }
}

class _RoutineScheduleSheetBody extends StatefulWidget {
  const _RoutineScheduleSheetBody({
    required this.routine,
    required this.existing,
  });

  final Routine routine;
  final RoutineSchedule? existing;

  @override
  State<_RoutineScheduleSheetBody> createState() =>
      _RoutineScheduleSheetBodyState();
}

class _RoutineScheduleSheetBodyState extends State<_RoutineScheduleSheetBody> {
  late DateTime _selectedDateTime;
  late ScheduleRecurrence _recurrence;
  DateTime? _endDate;
  bool _hasEndDate = false;
  bool _saving = false;

  bool get _isRecurring => _recurrence != ScheduleRecurrence.none;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final existing = widget.existing;
    if (existing != null && existing.isActiveAt(now)) {
      _selectedDateTime = existing.scheduledAt;
      _recurrence = existing.recurrence;
      _endDate = existing.endDate;
      _hasEndDate = existing.endDate != null;
    } else {
      _selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      ).add(const Duration(hours: 1));
      _recurrence = ScheduleRecurrence.none;
    }
  }

  RoutineSchedule _buildSchedule() {
    return RoutineSchedule(
      routineId: widget.routine.id,
      routineTitle: widget.routine.title,
      scheduledAt: _selectedDateTime,
      recurrence: _recurrence,
      endDate: _hasEndDate ? _endDate : null,
    );
  }

  Future<void> _pickDate() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final picked = await WheelDateTimePicker.showDate(
      context,
      title: _isRecurring ? l10n.scheduleWorkoutStartDate : l10n.scheduleWorkoutDate,
      initialDate: _selectedDateTime,
      minimumDate: DateTime(now.year, now.month, now.day),
      maximumDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
      if (_hasEndDate && _endDate != null && _endDate!.isBefore(_selectedDateTime)) {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final initial = _endDate ?? _selectedDateTime.add(const Duration(days: 30));
    final picked = await WheelDateTimePicker.showDate(
      context,
      title: l10n.scheduleRecurrenceEndDate,
      initialDate: initial,
      minimumDate: DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
      ),
      maximumDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked == null || !mounted) return;
    setState(() => _endDate = picked);
  }

  Future<void> _pickTime() async {
    final l10n = AppLocalizations.of(context);
    final picked = await WheelDateTimePicker.showTime(
      context,
      title: l10n.scheduleWorkoutTime,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  String? _validationError(AppLocalizations l10n) {
    final now = DateTime.now();
    if (_recurrence == ScheduleRecurrence.none &&
        !_selectedDateTime.isAfter(now)) {
      return l10n.scheduleWorkoutPastTime;
    }
    if (_hasEndDate && _endDate == null) {
      return l10n.scheduleRecurrenceEndDateRequired;
    }
    if (_hasEndDate && _endDate != null) {
      final startDay = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
      );
      final endDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
      if (endDay.isBefore(startDay)) {
        return l10n.scheduleRecurrenceEndBeforeStart;
      }
    }
    return null;
  }

  Future<void> _confirm() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final error = _validationError(l10n);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _saving = true);
    final schedule = _buildSchedule();
    final saved = await RoutineScheduleService.shared.scheduleWorkout(
      routine: widget.routine,
      schedule: schedule,
      l10n: l10n,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scheduleWorkoutPermissionRequired)),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final message = scheduleSuccessMessage(schedule, l10n, material);
    Navigator.pop(context, true);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cancelExisting() async {
    if (_saving || widget.existing == null) return;
    setState(() => _saving = true);
    await RoutineScheduleService.shared.cancelForRoutine(widget.routine.id);
    if (!mounted) return;
    setState(() => _saving = false);
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).scheduleWorkoutCancelled;
    Navigator.pop(context, true);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String _recurrenceHint(AppLocalizations l10n, MaterialLocalizations material) {
    final schedule = _buildSchedule();
    if (!schedule.isActiveAt(DateTime.now())) return '';
    return schedule.summary(l10n, material);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final dateLabel = material.formatFullDate(_selectedDateTime);
    final timeLabel =
        material.formatTimeOfDay(TimeOfDay.fromDateTime(_selectedDateTime));
    final hint = _recurrenceHint(l10n, material);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.scheduleWorkoutTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.routine.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.scheduleRecurrenceLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ScheduleRecurrence>(
                segments: [
                  ButtonSegment(
                    value: ScheduleRecurrence.none,
                    label: Text(l10n.scheduleRecurrenceOnce),
                  ),
                  ButtonSegment(
                    value: ScheduleRecurrence.daily,
                    label: Text(l10n.scheduleRecurrenceDaily),
                  ),
                  ButtonSegment(
                    value: ScheduleRecurrence.weekly,
                    label: Text(l10n.scheduleRecurrenceWeekly),
                  ),
                  ButtonSegment(
                    value: ScheduleRecurrence.monthly,
                    label: Text(l10n.scheduleRecurrenceMonthly),
                  ),
                ],
                selected: {_recurrence},
                onSelectionChanged: _saving
                    ? null
                    : (selection) {
                        setState(() => _recurrence = selection.first);
                      },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _saving ? null : _pickDate,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isRecurring
                        ? '${l10n.scheduleWorkoutStartDate}: $dateLabel'
                        : '${l10n.scheduleWorkoutDate}: $dateLabel',
                  ),
                ),
              ),
              if (_isRecurring &&
                  (_recurrence == ScheduleRecurrence.weekly ||
                      _recurrence == ScheduleRecurrence.monthly)) ...[
                const SizedBox(height: 4),
                Text(
                  _recurrence == ScheduleRecurrence.weekly
                      ? l10n.scheduleRecurrenceWeeklyHint
                      : l10n.scheduleRecurrenceMonthlyHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _saving ? null : _pickTime,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${l10n.scheduleWorkoutTime}: $timeLabel'),
                ),
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.scheduleRecurrenceEndDate),
                  subtitle: Text(
                    _hasEndDate && _endDate != null
                        ? material.formatFullDate(_endDate!)
                        : l10n.scheduleRecurrenceEndDateNone,
                  ),
                  value: _hasEndDate,
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _hasEndDate = value;
                            _endDate ??=
                                _selectedDateTime.add(const Duration(days: 30));
                          });
                        },
                ),
                if (_hasEndDate)
                  OutlinedButton(
                    onPressed: _saving ? null : _pickEndDate,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${l10n.scheduleRecurrenceEndDate}: ${material.formatFullDate(_endDate ?? _selectedDateTime)}',
                      ),
                    ),
                  ),
              ],
              if (hint.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _confirm,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.scheduleWorkoutConfirm),
              ),
              if (widget.existing != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _saving ? null : _cancelExisting,
                  child: Text(l10n.scheduleWorkoutCancelExisting),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
