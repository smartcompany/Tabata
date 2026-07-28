import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../models/routine_schedule.dart';
import '../services/routine_schedule_service.dart';
import '../widgets/routine_schedule_sheet.dart';

class ScheduleHistoryScreen extends StatefulWidget {
  const ScheduleHistoryScreen({
    super.key,
    required this.routineRepository,
  });

  final RoutineRepository routineRepository;

  @override
  State<ScheduleHistoryScreen> createState() => _ScheduleHistoryScreenState();
}

class _ScheduleHistoryScreenState extends State<ScheduleHistoryScreen> {
  List<RoutineSchedule> get _schedules =>
      RoutineScheduleService.shared.allSchedules();

  Future<void> _openSchedule(RoutineSchedule schedule) async {
    final l10n = AppLocalizations.of(context);
    final routine = widget.routineRepository.findById(schedule.routineId);
    if (routine == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scheduleHistoryMissingRoutine)),
      );
      return;
    }

    final changed = await RoutineScheduleSheet.show(
      context,
      routine: routine,
      existing: RoutineScheduleService.shared.scheduleFor(routine.id),
    );
    if (changed == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _cancelSchedule(RoutineSchedule schedule) async {
    final l10n = AppLocalizations.of(context);
    await RoutineScheduleService.shared.cancelForRoutine(schedule.routineId);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.scheduleWorkoutCancelled)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final schedules = _schedules;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scheduleHistoryTitle),
      ),
      body: schedules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.scheduleHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: schedules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.event_available_outlined,
                      color: scheme.primary,
                    ),
                    title: Text(
                      schedule.routineTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(schedule.summary(l10n, material)),
                    ),
                    trailing: IconButton(
                      onPressed: () => _cancelSchedule(schedule),
                      icon: const Icon(Icons.close),
                      tooltip: l10n.scheduleWorkoutCancelExisting,
                    ),
                    onTap: () => _openSchedule(schedule),
                  ),
                );
              },
            ),
    );
  }
}
