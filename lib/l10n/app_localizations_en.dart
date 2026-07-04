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
  String get uploadRoutineTooltip => 'Share my routines';

  @override
  String get uploadRoutineTitle => 'Share my routines';

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
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountMessage =>
      'Your account and uploaded routines, profile, and images on the server will be deleted. Local routines on this device are kept. This cannot be undone.';

  @override
  String get deleteAccountConfirm => 'Delete account';

  @override
  String get deleteAccountSuccess => 'Your account has been deleted.';

  @override
  String get deleteAccountFailed =>
      'Could not delete your account. Please try again later.';

  @override
  String get deleteAccountRecentLoginRequired =>
      'For security, sign in again and then delete your account.';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsSignOut => 'Sign out';

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
  String get uploadServerRoutineSection => 'My uploaded routines';

  @override
  String get uploadServerRoutineHint =>
      'Tap to edit. Saving updates the server copy.';

  @override
  String get uploadLocalRoutineSection => 'Routines on this device';

  @override
  String get uploadLocalRoutineHint =>
      'Routines saved on this device. Uploading copies them to the server without removing the local copy.';

  @override
  String get uploadNoAdminRoutines => 'No uploaded routines yet.';

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
  String get homeCatalogSharedSection => 'User routines';

  @override
  String get searchRoutinesTooltip => 'Search routines';

  @override
  String get searchRoutinesHint => 'Search by title or description';

  @override
  String get noSearchResults => 'No matching routines.';

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
  String get aiRoutineCreateButton => 'Create routine with AI';

  @override
  String get aiRoutineCreateTitle =>
      'Create a routine with AI after watching an ad';

  @override
  String get aiRoutineCreatePromptHint =>
      'Example:\nhttps://www.youtube.com/watch?v=9bZkp7q19f0\nCreate a workout routine based on this video.\n\nOr\n\nMy neck has been really stiff lately—make a routine with stretches you recommend.';

  @override
  String get aiRoutineCreateSubmit => 'Create routine after watching ad';

  @override
  String get aiRoutineCreateLoading => 'AI is building your routine...';

  @override
  String get aiRoutineCreateAdLoading => 'Loading ad...';

  @override
  String get aiRoutineCreatePromptRequired => 'Please enter your request.';

  @override
  String get aiRoutineCreateAdRequired => 'Please watch the ad to continue.';

  @override
  String get aiRoutineCreateAdLoadFailed =>
      'Could not load the ad. Check your connection and try again shortly.';

  @override
  String get aiRoutineCreateError =>
      'Could not generate the routine. Please try again.';

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
  String get shareSheetKakaoTalk => 'Share to KakaoTalk';

  @override
  String get shareSheetSystemShare => 'System share';

  @override
  String shareRoutineFooter(String appTitle) {
    return 'Try this routine in $appTitle';
  }

  @override
  String get shareKakaoLinkButton => 'Open routine';

  @override
  String get shareFailed => 'Could not share. Please try again.';

  @override
  String get sharedRoutineImportTitle => 'Shared routine';

  @override
  String get sharedRoutineImportPrompt => 'Download this shared routine?';

  @override
  String get sharedRoutineImportYes => 'Yes';

  @override
  String sharedRoutineImportMessage(String title) {
    return 'Add \"$title\" to My routines?';
  }

  @override
  String get sharedRoutineImportAdd => 'Add to My routines';

  @override
  String get sharedRoutineImportError => 'Could not load the shared routine.';

  @override
  String get sharedRoutineNotFound =>
      'This share link was not found or has expired.';

  @override
  String catalogAuthor(String author) {
    return 'By $author';
  }

  @override
  String get catalogAuthorUnknown => 'Unknown';

  @override
  String estimatedDuration(String duration) {
    return 'Est. $duration';
  }

  @override
  String get exerciseListTitle => 'Exercises';

  @override
  String get start => 'Start';

  @override
  String get seeMore => 'Show details';

  @override
  String get collapse => 'Hide details';

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
  String get descriptionBlocksEmptyHint =>
      'Add text, reference photos, and video links in order.';

  @override
  String get descriptionAddText => 'Text';

  @override
  String get descriptionAddImage => 'Photo';

  @override
  String get descriptionAddVideo => 'Video link';

  @override
  String get descriptionTextHint => 'Enter description';

  @override
  String get descriptionVideoUrlHint => 'YouTube or other video URL';

  @override
  String get descriptionVideoUrlInvalid => 'Enter a valid video URL.';

  @override
  String get descriptionVideoBlockLabel => 'Video link';

  @override
  String get descriptionVideoPlay => 'Tap to play';

  @override
  String get descriptionVideoExternal => 'Open external video';

  @override
  String get descriptionImageLoginRequired => 'Sign in to add photos.';

  @override
  String get photoLibraryPermissionRequired =>
      'Photo library access is required to add images.';

  @override
  String get descriptionImageUploadError => 'Failed to upload photo.';

  @override
  String get descriptionImageLoadError => 'Could not load image.';

  @override
  String get reorderExercisesHint => 'Long press to reorder';

  @override
  String get addExercisesPrompt => 'Add an exercise';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get importExercisesButton => 'Import from another routine';

  @override
  String get importExercisesTitle => 'Import exercises';

  @override
  String get importExercisesChooseRoutine => 'Choose a routine';

  @override
  String get importExercisesNoOtherRoutines =>
      'No other routines to import from.';

  @override
  String get importExercisesNoExercisesInRoutine =>
      'This routine has no exercises.';

  @override
  String importExercisesAddCount(int count) {
    return 'Add $count';
  }

  @override
  String importExercisesAddedSnack(int count) {
    return 'Added $count exercise(s)';
  }

  @override
  String get importExercisesSelectAll => 'Select all';

  @override
  String get importExercisesClearSelection => 'Clear selection';

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
  String get workoutPrevious => 'Previous';

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
  String get contentSettingsSection => 'Content';

  @override
  String get autoTranslateContentTitle => 'Auto-translate content';

  @override
  String get autoTranslateContentSubtitle =>
      'Translate titles, descriptions, and exercise names from the server into your app language.';

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

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAppDisclosures => 'Service notice & disclaimers';

  @override
  String get privacyProcessingConsentTitle => 'Terms, shared content & privacy';

  @override
  String get privacyProcessingConsentLead =>
      'To upload or share workout routines (user-generated content), please review and agree below.';

  @override
  String get privacyProcessingConsentSectionPrivacy => 'Personal data';

  @override
  String get privacyProcessingConsentSectionUgc => 'Shared routines (UGC)';

  @override
  String get privacyProcessingConsentUgcIntro =>
      'Applies when you upload routines visible to other users. YouTube and other video links play via the official embed player only; we do not host or redistribute video files.';

  @override
  String get privacyProcessingConsentBullet1 =>
      'We collect: Firebase UID, email (if provided), nickname, uploaded routines (title, description, exercises, image URLs, video link URLs).';

  @override
  String get privacyProcessingConsentBullet2 =>
      'Purposes: account identity, routine sharing, abuse prevention, service improvement.';

  @override
  String get privacyProcessingConsentBullet3 =>
      'Retention: deleted when you delete your account unless law requires longer retention.';

  @override
  String get privacyProcessingConsentUgcBullet1 =>
      'Zero tolerance for illegal, violent, sexual, hateful, spam, or rights-infringing routines, images, or video links.';

  @override
  String get privacyProcessingConsentUgcBullet2 =>
      'Violations may result in content removal, upload restrictions, or account suspension.';

  @override
  String get privacyProcessingConsentUgcBullet3 =>
      'Report inappropriate shared routines via the developer contact on the app store.';

  @override
  String get privacyProcessingConsentCheckboxPrivacy =>
      'I agree to the collection and use of personal data described above.';

  @override
  String get privacyProcessingConsentCheckboxUgc =>
      'I agree to the shared routine (UGC) rules and zero-tolerance policy.';

  @override
  String get privacyProcessingConsentAgree => 'Agree and continue';

  @override
  String get privacyProcessingConsentDecline => 'Decline';

  @override
  String get healthActivityTypeSection => 'Apple Health workout type';

  @override
  String get healthActivityTypeHint =>
      'When set, completing this routine can save a workout to the Health app. Leave unset to skip saving.';

  @override
  String get healthActivityTypeHelper =>
      'Requires \"Save workouts to Apple Health\" in app settings.';

  @override
  String get healthActivityTypeNone => 'Do not save to Health';

  @override
  String get healthActivityTypeFunctionalStrength =>
      'Functional strength training';

  @override
  String get healthActivityTypeFlexibility => 'Flexibility';

  @override
  String get healthActivityTypeHiit =>
      'High intensity interval training (HIIT)';

  @override
  String get healthActivityTypeTraditionalStrength =>
      'Traditional strength training';

  @override
  String get healthActivityTypeOther => 'Other';

  @override
  String get healthSaveToAppleHealthTitle => 'Save workouts to Apple Health';

  @override
  String get healthSaveToAppleHealthSubtitle =>
      'When a routine has a Health workout type, finishing the workout saves it to the Health app.';

  @override
  String get healthRoutineWillSaveTitle => 'Apple Health';

  @override
  String healthRoutineWillSaveBody(String type) {
    return 'Completing this routine saves a $type workout to the Health app (if enabled in settings).';
  }

  @override
  String healthWorkoutSavedSnack(String type) {
    return 'Saved as $type in the Health app.';
  }

  @override
  String get healthPermissionRequiredSnack =>
      'Health permission is required. Enable it in Settings > Health > Data Access.';

  @override
  String get healthFirstWorkoutPromptTitle => 'Save workouts to Apple Health?';

  @override
  String get healthFirstWorkoutPromptBody =>
      'Completed workouts can be saved to the Health app when a routine has a Health workout type set. Choose Enable to turn this on — Apple will show a system permission sheet. You can change this later in app settings.';

  @override
  String get healthFirstWorkoutPromptEnable => 'Enable';

  @override
  String get healthFirstWorkoutPromptNotNow => 'Not now';

  @override
  String get workoutHistoryTitle => 'Workout history';

  @override
  String get workoutHistoryYearLabel => 'Year';

  @override
  String get workoutHistoryMonthLabel => 'Month';

  @override
  String workoutHistoryMonthWorkouts(int count) {
    return '$count workouts';
  }

  @override
  String workoutHistoryMonthDuration(String duration) {
    return '$duration total';
  }

  @override
  String get workoutHistoryChartTitle => 'Daily workout time (minutes)';

  @override
  String get workoutHistoryCalendarTitle => 'Calendar';

  @override
  String workoutHistoryDayTitle(String date) {
    return 'Sessions on $date';
  }

  @override
  String get workoutHistoryEmptyDay => 'No workouts on this day.';

  @override
  String workoutHistorySessionSubtitle(
    String time,
    String duration,
    int count,
  ) {
    return '$time · $duration · $count exercises';
  }
}
