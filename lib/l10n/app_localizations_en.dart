// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Everyone\'s Tabata';

  @override
  String get importRoutineTooltip => 'Import routine';

  @override
  String get noRoutines => 'No saved routines.';

  @override
  String get loadingProfiles => 'Loading routines...';

  @override
  String get profileLoadError => 'Could not load routines from server.';

  @override
  String get retry => 'Retry';

  @override
  String get createRoutine => 'Create routine';

  @override
  String routineCountDuration(int count, String duration) {
    return '$count exercises · $duration';
  }

  @override
  String get routineNotFound => 'Routine not found.';

  @override
  String get editTooltip => 'Edit';

  @override
  String get shareTooltip => 'Share';

  @override
  String get rollbackTooltip => 'Restore from server';

  @override
  String get rollbackConfirmMessage => 'Restore this routine from the server?';

  @override
  String get rollbackSuccess => 'Restored from server.';

  @override
  String get rollbackError => 'Could not load data from the server.';

  @override
  String estimatedDuration(String duration) {
    return 'Est. $duration';
  }

  @override
  String get exerciseListTitle => 'Exercises';

  @override
  String get start => 'Start';

  @override
  String get startAll => 'Start all';

  @override
  String get labelPrepare => 'Prepare';

  @override
  String get labelWork => 'Work';

  @override
  String get labelRelax => 'Relax';

  @override
  String get labelReps => 'Reps';

  @override
  String get labelSets => 'Sets';

  @override
  String oneSetDuration(String duration) {
    return '1 set $duration';
  }

  @override
  String phaseWithDuration(String label, int seconds) {
    return '$label · ${seconds}s';
  }

  @override
  String phaseWithCountTiming(String label, int count, int seconds) {
    return '$label · $count reps × ${seconds}s';
  }

  @override
  String get phaseTimingModeDuration => 'Duration';

  @override
  String get phaseTimingModeCount => 'Count';

  @override
  String get labelPhaseCount => 'Reps';

  @override
  String get labelSecondsPerRep => 'Per rep';

  @override
  String get tapToSetPhaseCount => 'Tap to set reps';

  @override
  String get countOrderAscending => 'Ascending';

  @override
  String get countOrderDescending => 'Descending';

  @override
  String repCountProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String durationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String countReps(int count) {
    return '$count reps';
  }

  @override
  String countSets(int count) {
    return '$count sets';
  }

  @override
  String get importRoutineTitle => 'Import routine';

  @override
  String get importRoutineHint => 'Paste shared JSON below.';

  @override
  String get importRoutineJsonHint => 'Paste the full routine JSON';

  @override
  String get import => 'Import';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get createRoutineTitle => 'Create routine';

  @override
  String get editRoutineTitle => 'Edit routine';

  @override
  String get deleteRoutineTooltip => 'Delete routine';

  @override
  String get deleteRoutineTitle => 'Delete routine';

  @override
  String get deleteRoutineMessage => 'Delete this routine?';

  @override
  String get routineNameLabel => 'Routine name';

  @override
  String get routineNameHint => 'e.g. Rotator cuff rehab';

  @override
  String get descriptionOptionalLabel => 'Description (optional)';

  @override
  String get reorderExercisesHint => 'Long press to reorder';

  @override
  String get addExercisesPrompt => 'Add an exercise';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get requireAtLeastOneExercise => 'Add at least one exercise';

  @override
  String get addExerciseTitle => 'Add exercise';

  @override
  String get editExerciseTitle => 'Edit exercise';

  @override
  String get basicInfoSection => 'Basic info';

  @override
  String get exerciseNameLabel => 'Exercise name';

  @override
  String get exerciseNameHint => 'e.g. Penguin exercise';

  @override
  String get exerciseInstructionLabel => 'Instructions (optional)';

  @override
  String get exerciseInstructionHint => 'Describe how to perform the movement';

  @override
  String get prepareSection => 'Prepare';

  @override
  String get phasesSection => 'Phase order';

  @override
  String get addWorkPhase => 'Add work';

  @override
  String get addRelaxPhase => 'Add relax';

  @override
  String get requireAtLeastOnePhase => 'Add at least one phase';

  @override
  String get reorderPhasesHint => 'Drag to reorder';

  @override
  String get workSection => 'Work';

  @override
  String get relaxSection => 'Relax';

  @override
  String get repeatSection => 'Repeat';

  @override
  String get phaseLabel => 'Phase label';

  @override
  String get workLabelHint => 'e.g. Arms out';

  @override
  String get relaxLabelHint => 'e.g. Arms in';

  @override
  String get previewSection => 'Preview';

  @override
  String totalDuration(String duration) {
    return 'Total $duration';
  }

  @override
  String get newExercise => 'New exercise';

  @override
  String exerciseListSubtitle(String phases, String repsSets, String oneSet) {
    return '$phases · $repsSets · $oneSet';
  }

  @override
  String repsSetsSummary(int reps, int sets) {
    return '$reps reps × $sets sets';
  }

  @override
  String get validationNameRequired => 'Enter a name';

  @override
  String get validationLabelRequired => 'Enter a label';

  @override
  String get enterValueTitle => 'Enter value';

  @override
  String get dragToAdjustHint => 'Drag left/right to adjust · tap to type';

  @override
  String get unitSeconds => 's';

  @override
  String get unitMinutes => 'min';

  @override
  String get tapToSetDuration => 'Tap to set duration';

  @override
  String get tapToSetReps => 'Tap to set reps';

  @override
  String get tapToSetSets => 'Tap to set sets';

  @override
  String get unitReps => 'reps';

  @override
  String get unitSets => 'sets';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String durationApproxMinutes(int minutes) {
    return '~$minutes min';
  }

  @override
  String durationApproxHours(int hours) {
    return '~$hours h';
  }

  @override
  String durationApproxHoursMinutes(int hours, int minutes) {
    return '~$hours h $minutes min';
  }

  @override
  String workoutProgress(int current, int total) {
    return 'Exercise $current/$total';
  }

  @override
  String get phasePrepare => 'Prepare';

  @override
  String get phaseWork => 'Work';

  @override
  String get phaseRelax => 'Relax';

  @override
  String get phaseCompleted => 'Done';

  @override
  String get workoutCompletedMessage => 'Great job';

  @override
  String repSetProgress(int rep, int totalReps, int set, int totalSets) {
    return '$rep/$totalReps reps · $set/$totalSets sets';
  }

  @override
  String get skipPhase => 'Skip';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get skipExercise => 'Skip exercise';

  @override
  String get workoutDone => 'Done';

  @override
  String get workoutRemainingReps => 'Reps left';

  @override
  String get workoutRemainingSets => 'Sets left';

  @override
  String get workoutNext => 'Next';

  @override
  String get nextPhaseFinish => 'Finish';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get voiceGuidance => 'Voice guidance';

  @override
  String get voiceGuidanceSubtitle =>
      'Announces phases and countdown during workouts';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsSubtitle =>
      'Tick each second and chime when reps or sets change';

  @override
  String get voiceCountThree => 'three';

  @override
  String get voiceCountTwo => 'two';

  @override
  String get voiceCountOne => 'one';

  @override
  String get errorEmptyJson => 'Empty data.';

  @override
  String get errorInvalidRoutineJson => 'Invalid routine JSON.';
}
