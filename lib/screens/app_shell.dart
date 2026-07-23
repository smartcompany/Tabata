import 'package:flutter/material.dart';

import '../data/routine_repository.dart';
import '../data/workout_history_repository.dart';
import '../services/admin_session.dart';
import '../services/app_analytics_service.dart';
import '../services/onboarding_settings.dart';
import '../services/routine_api_client.dart';
import '../services/shared_routine_link_coordinator.dart';
import '../services/workout_completion_recorder.dart';
import '../services/workout_launch_coordinator.dart';
import 'home_screen.dart';
import 'onboarding/onboarding_screen.dart';

/// Shows onboarding on first launch, then the home screen.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.repository,
    required this.workoutHistoryRepository,
    required this.workoutCompletionRecorder,
    required this.apiClient,
    required this.adminSession,
    required this.linkCoordinator,
    required this.workoutLaunchCoordinator,
  });

  final RoutineRepository repository;
  final WorkoutHistoryRepository workoutHistoryRepository;
  final WorkoutCompletionRecorder workoutCompletionRecorder;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;
  final SharedRoutineLinkCoordinator linkCoordinator;
  final WorkoutLaunchCoordinator workoutLaunchCoordinator;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _ready = false;
  bool _showOnboarding = false;
  String? _initialOpenRoutineId;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final completed = await OnboardingSettings.isCompleted();
    if (!completed) {
      try {
        await widget.repository.refreshRemoteProfiles();
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _ready = true;
      _showOnboarding = !completed;
    });
  }

  Future<void> _completeOnboarding({
    required String path,
    String? openRoutineId,
  }) async {
    await AppAnalyticsService.logOnboardingComplete(path: path);
    await OnboardingSettings.markCompleted();
    if (!mounted) return;
    setState(() {
      _showOnboarding = false;
      _initialOpenRoutineId = openRoutineId;
    });
  }

  Future<void> showOnboardingAgain() async {
    await OnboardingSettings.resetCompleted();
    try {
      await widget.repository.refreshRemoteProfiles();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _showOnboarding = true;
      _initialOpenRoutineId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        repository: widget.repository,
        workoutCompletionRecorder: widget.workoutCompletionRecorder,
        onComplete: _completeOnboarding,
      );
    }

    return HomeScreen(
      repository: widget.repository,
      workoutHistoryRepository: widget.workoutHistoryRepository,
      workoutCompletionRecorder: widget.workoutCompletionRecorder,
      apiClient: widget.apiClient,
      adminSession: widget.adminSession,
      linkCoordinator: widget.linkCoordinator,
      workoutLaunchCoordinator: widget.workoutLaunchCoordinator,
      onShowOnboardingAgain: showOnboardingAgain,
      initialOpenRoutineId: _initialOpenRoutineId,
      autoStartWorkout: _initialOpenRoutineId != null,
    );
  }
}
