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
  String get uploadRoutineTooltip => 'Upload routine';

  @override
  String get uploadRoutineTitle => 'Upload routine';

  @override
  String get uploadAdminLoginHint =>
      'Sign in with an admin account to publish routines to the server.';

  @override
  String get uploadAdminUsername => 'Admin username';

  @override
  String get uploadAdminPassword => 'Password';

  @override
  String get uploadAdminLogin => 'Admin sign in';

  @override
  String get uploadLogout => 'Sign out';

  @override
  String get uploadSelectRoutine => 'Choose a routine to upload';

  @override
  String get uploadNoLocalRoutines => 'No routines saved on this device.';

  @override
  String get upload => 'Upload';

  @override
  String get uploadUpdate => 'Update';

  @override
  String get uploadConfirmTitle => 'Upload to server';

  @override
  String uploadConfirmCreate(String title) {
    return 'Add \"$title\" to the server?';
  }

  @override
  String uploadConfirmUpdate(String title) {
    return 'Update \"$title\" on the server?';
  }

  @override
  String uploadSuccessCreated(String title) {
    return 'Added \"$title\" to the server.';
  }

  @override
  String uploadSuccessUpdated(String title) {
    return 'Updated \"$title\" on the server.';
  }

  @override
  String get uploadError => 'Upload failed.';

  @override
  String get uploadLoginError => 'Sign in failed.';

  @override
  String get uploadLoadServerIdsError => 'Could not load server routine list.';

  @override
  String get uploadServerRoutineSection => 'Routines on server';

  @override
  String get uploadServerRoutineHint =>
      'Tap to edit on the server. Saving updates the server copy.';

  @override
  String get uploadLocalRoutineSection => 'Routines on this device';

  @override
  String get uploadLocalRoutineHint =>
      'Local routines not yet on the server. Upload adds them to the server.';

  @override
  String get uploadNoAdminRoutines => 'No admin routines on the server.';

  @override
  String get uploadEditServerRoutineTitle => 'Edit server routine';

  @override
  String get uploadDeleteServerRoutineMessage =>
      'Delete this routine from the server?';

  @override
  String get downloadRoutineTooltip => 'Download';

  @override
  String routineDownloadSuccess(String title) {
    return 'Saved \"$title\" to this device.';
  }

  @override
  String get routineDownloadError => 'Download failed.';

  @override
  String routineCountOnly(int count) {
    return '$count exercises';
  }

  @override
  String get deleteLocalCopyMessage =>
      'Remove this routine from this device? Server routines can be downloaded again.';

  @override
  String get noRoutines => 'No saved routines.';

  @override
  String get noMyRoutines =>
      'No routines yet. Create one or download from the shared catalog.';

  @override
  String get noSharedRoutines => 'No shared routines.';

  @override
  String get homeTabMyRoutines => 'My routines';

  @override
  String get homeTabShared => 'Shared';

  @override
  String get homeDownloadCatalogHint => 'Download to add to My routines.';

  @override
  String get homeCatalogOfficialSection => 'Default routines';

  @override
  String get homeCatalogSharedSection => 'Shared routines';

  @override
  String routineAddedToMyRoutines(String title) {
    return 'Added \"$title\" to My routines.';
  }

  @override
  String catalogSavedCount(int count) {
    return '$count saved in My routines';
  }

  @override
  String get openSavedCopy => 'Open';

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
  String get defaultRoutineName => 'Default routine';

  @override
  String get defaultExerciseName => 'Default exercise';

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
  String get workoutSettingsSection => 'Workout';

  @override
  String get countSecondsWithTtsTitle => 'Voice second count';

  @override
  String get countSecondsWithTtsSubtitle =>
      'Speaks each second in count mode only. When off, beeps play instead.';

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
