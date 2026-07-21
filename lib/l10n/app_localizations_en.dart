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
  String get aiRoutineCreateTitle => 'Create routine with AI';

  @override
  String get aiRoutineCreatePromptLead =>
      'Describe the workout you want, or paste a video link';

  @override
  String get aiRoutineCreatePromptHint =>
      'Example:\nhttps://www.youtube.com/watch?v=9bZkp7q19f0\nCreate a workout routine based on this video.\n\nOr\n\nMy neck has been really stiff lately—make a routine with stretches you recommend.';

  @override
  String get aiRoutineCreateSubmit => 'Create routine after watching ad';

  @override
  String get aiRoutineCreateSubmitNoAd => 'Create routine';

  @override
  String get aiRoutineCreateLoading => 'AI is building your routine...';

  @override
  String get aiRoutineCreateLoadingStage1 => 'Reading your request...';

  @override
  String get aiRoutineCreateLoadingStage2 => 'Picking the right exercises...';

  @override
  String get aiRoutineCreateLoadingStage3 => 'Tuning times and counts...';

  @override
  String get aiRoutineCreateLoadingStage4 => 'Arranging sets and order...';

  @override
  String get aiRoutineCreateLoadingStage5 =>
      'Putting on the finishing touches...';

  @override
  String get aiRoutineCreateLoadingFooter => 'Almost there — hang tight.';

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
  String get shareTooltip => 'Share routine';

  @override
  String get shareAppTooltip => 'Share app';

  @override
  String shareAppMessage(String appTitle) {
    return 'Try $appTitle — interval timer for workout routines.';
  }

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
  String get shareKakaoAppLinkButton => 'Get the app';

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
  String get workoutContinueInBackgroundTitle => 'Continue in background';

  @override
  String get workoutContinueInBackgroundSubtitle =>
      'The timer and voice cues keep running in the background. Turn off to pause when you leave the app.';

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
  String get scheduleWorkoutTooltip => 'Schedule workout';

  @override
  String get scheduleWorkoutTitle => 'Schedule workout';

  @override
  String get scheduleWorkoutDate => 'Date';

  @override
  String get scheduleWorkoutTime => 'Time';

  @override
  String get scheduleWorkoutConfirm => 'Schedule';

  @override
  String get scheduleWorkoutCancelExisting => 'Cancel schedule';

  @override
  String scheduleWorkoutSuccess(String time) {
    return 'Reminder set for $time.';
  }

  @override
  String get scheduleWorkoutCancelled => 'Schedule cancelled.';

  @override
  String get scheduleWorkoutPastTime => 'Choose a time in the future.';

  @override
  String get scheduleWorkoutPermissionRequired =>
      'Notification permission is required. Allow notifications in Settings.';

  @override
  String get scheduleWorkoutNotificationTitle => 'Time to work out';

  @override
  String scheduleWorkoutNotificationBody(String title) {
    return 'Start your $title routine.';
  }

  @override
  String scheduleWorkoutActive(String time) {
    return 'Scheduled for $time';
  }

  @override
  String get scheduleRecurrenceLabel => 'Repeat';

  @override
  String get scheduleRecurrenceOnce => 'Once';

  @override
  String get scheduleRecurrenceDaily => 'Daily';

  @override
  String get scheduleRecurrenceWeekly => 'Weekly';

  @override
  String get scheduleRecurrenceMonthly => 'Monthly';

  @override
  String get scheduleWorkoutStartDate => 'Start date';

  @override
  String get scheduleRecurrenceEndDate => 'End repeat';

  @override
  String get scheduleRecurrenceEndDateNone => 'None (ongoing)';

  @override
  String get scheduleRecurrenceEndDateRequired =>
      'Choose an end date for the repeat.';

  @override
  String get scheduleRecurrenceEndBeforeStart =>
      'End date must be on or after the start date.';

  @override
  String get scheduleRecurrenceWeeklyHint =>
      'Repeats on the weekday of the selected date.';

  @override
  String get scheduleRecurrenceMonthlyHint =>
      'Repeats on the same day of each month.';

  @override
  String scheduleRecurrenceDailySummary(String time) {
    return 'Daily at $time';
  }

  @override
  String scheduleRecurrenceWeeklySummary(String weekday, String time) {
    return 'Weekly on $weekday at $time';
  }

  @override
  String scheduleRecurrenceMonthlySummary(int day, String time) {
    return 'Monthly on day $day at $time';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome to Everyone\'s Tabata';

  @override
  String get onboardingWelcomeSubtitle =>
      'Build a prepare · work · rest schedule — the timer cues you through it. How would you like to get started?';

  @override
  String get onboardingOptionQuickStartTitle => 'Start working out now';

  @override
  String get onboardingOptionQuickStartSubtitle =>
      'Pick a short routine and the workout starts right away';

  @override
  String get onboardingOptionYoutubeTitle => 'Follow YouTube or a workout';

  @override
  String get onboardingOptionYoutubeSubtitle =>
      'AI builds a routine from a video or workout name';

  @override
  String get onboardingOptionGoalTitle => 'Match your goal or focus';

  @override
  String get onboardingOptionGoalSubtitle =>
      'Choose goal, time, and level—AI creates your routine';

  @override
  String get onboardingOptionCreateTitle => 'Create from scratch';

  @override
  String get onboardingOptionCreateSubtitle =>
      'Set prep, work, and rest intervals yourself';

  @override
  String get onboardingSkip => 'Try a 1-minute workout';

  @override
  String get onboardingActivationTitle => 'Ready for your first workout?';

  @override
  String get onboardingActivationSubtitle =>
      'A short trial that takes about one minute. Your workout starts right away.';

  @override
  String get onboardingActivationStart => 'Start now';

  @override
  String get onboardingRecommendedTitle => 'Recommended routines';

  @override
  String get onboardingRecommendedSubtitle =>
      'Select routines to add. The shortest one is selected by default.';

  @override
  String get onboardingRecommendedSave => 'Add and start';

  @override
  String get onboardingRecommendedSelectAtLeastOne =>
      'Select at least one routine.';

  @override
  String get onboardingRecommendedDownloadFailed =>
      'Could not download routines. Check your connection and try again.';

  @override
  String get onboardingRecommendedLoadError =>
      'Could not load recommended routines.';

  @override
  String get onboardingStartHint => 'Tap Start all below to begin the workout.';

  @override
  String get homeStartNowTitle => 'Ready for your first workout?';

  @override
  String get homeStartNowSubtitle =>
      'Finishing one short session shows how the timer helps you.';

  @override
  String get homeStartNowButton => 'Start now';

  @override
  String get homeEmptyStartRecommended => 'Start with a recommended routine';

  @override
  String get homeEmptyBrowseCatalog => 'Browse shared routines';

  @override
  String get onboardingGoalTitle => 'Custom routine';

  @override
  String get onboardingGoalStepGoal => 'What\'s your goal?';

  @override
  String get onboardingGoalStepDuration => 'How long should it be?';

  @override
  String get onboardingGoalStepLevel => 'What\'s your level?';

  @override
  String get onboardingGoalNext => 'Next';

  @override
  String get onboardingGoalCreate => 'Create with AI';

  @override
  String get onboardingGoalOptionWeightLoss => 'Weight loss';

  @override
  String get onboardingGoalOptionStrength => 'Strength';

  @override
  String get onboardingGoalOptionFlexibility => 'Flexibility';

  @override
  String get onboardingGoalOptionFullBody => 'Full body';

  @override
  String get onboardingGoalOptionUpperBody => 'Upper body';

  @override
  String get onboardingGoalOptionLowerBody => 'Lower body';

  @override
  String get onboardingGoalOptionCore => 'Core';

  @override
  String get onboardingGoalDuration5 => '5 min';

  @override
  String get onboardingGoalDuration10 => '10 min';

  @override
  String get onboardingGoalDuration15 => '15 min';

  @override
  String get onboardingGoalDuration20 => '20 min';

  @override
  String get onboardingGoalLevelBeginner => 'Beginner';

  @override
  String get onboardingGoalLevelIntermediate => 'Intermediate';

  @override
  String get onboardingAiYoutubeInitialPrompt =>
      'Enter a YouTube URL or workout name.\n\nExample:\nhttps://www.youtube.com/watch?v=example\nCreate a Tabata interval routine from this video with prep, work, and rest phases.';

  @override
  String onboardingAiGoalPrompt(String goal, String duration, String level) {
    return 'Create a Tabata interval routine for goal: $goal, duration: $duration minutes, level: $level. Split into prep, work, and rest phases.';
  }

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsShowOnboardingAgain => 'Show onboarding again';

  @override
  String get settingsShowOnboardingAgainSubtitle =>
      'Show the first-run welcome screen again.';

  @override
  String get settingsRateApp => 'Rate the app';

  @override
  String get healthAppleHealthLabel => 'Save to Apple Health';

  @override
  String get healthAppleHealthInfoTitle => 'Apple Health';

  @override
  String get healthActivityTypeSection => 'Apple Health';

  @override
  String get healthActivityTypeDetail =>
      'When set, completing this routine saves a workout to the Apple Health app. Choose \"Do not save to Health\" to skip. Turn on \"Save to Apple Health\" in app settings.';

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
  String get healthSaveToAppleHealthTitle => 'Save to Apple Health';

  @override
  String get healthSaveToAppleHealthDetail =>
      'When a routine has a Health workout type, finishing the workout saves it to the Apple Health app. You can turn this on or off here. Apple shows a permission sheet the first time you enable it.';

  @override
  String healthRoutineWillSaveDetail(String type) {
    return 'Completing this routine saves a $type workout to Apple Health. \"Save to Apple Health\" must be enabled in app settings.';
  }

  @override
  String healthWorkoutSavedSnack(String type) {
    return 'Saved as $type in the Health app.';
  }

  @override
  String get healthWorkoutSaveFailedSnack =>
      'Could not save to the Health app. Check that \"Save to Apple Health\" is on in app settings and that permission was granted.';

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
  String get healthConnectLabel => 'Save to Health Connect';

  @override
  String get healthConnectInfoTitle => 'Health Connect';

  @override
  String get healthConnectSaveDetail =>
      'When a routine has a workout type, finishing saves it to Google Health Connect. The Health Connect app must be installed. You can turn this on or off here; the permission screen appears the first time you enable it.';

  @override
  String get healthConnectActivityTypeDetail =>
      'When set, completing this routine saves a workout to Health Connect. Choose \"Do not save to Health Connect\" to skip. Turn on \"Save to Health Connect\" in app settings.';

  @override
  String get healthConnectActivityTypeNone => 'Do not save to Health Connect';

  @override
  String get healthConnectWorkoutTypesRecommended => 'Recommended';

  @override
  String get healthConnectReadyStatus => 'Health Connect is available';

  @override
  String get healthConnectUnavailableStatus =>
      'Install or update the Health Connect app';

  @override
  String healthConnectRoutineWillSaveDetail(String type) {
    return 'Completing this routine saves a $type workout to Health Connect. \"Save to Health Connect\" must be enabled in app settings.';
  }

  @override
  String healthConnectWorkoutSavedSnack(String type) {
    return 'Saved as $type in Health Connect.';
  }

  @override
  String get healthConnectWorkoutSaveFailedSnack =>
      'Could not save to Health Connect. Check that \"Save to Health Connect\" is on in app settings and that exercise write access is allowed for this app in the Health Connect app.';

  @override
  String get healthConnectPermissionRequiredSnack =>
      'Health Connect permission is required. Allow exercise write access for this app in the Health Connect app.';

  @override
  String get healthConnectFirstWorkoutPromptTitle =>
      'Save workouts to Health Connect?';

  @override
  String get healthConnectFirstWorkoutPromptBody =>
      'Completed workouts can be saved to Health Connect when a routine has a workout type set. Choose Enable to open the permission screen. You may need to install the Health Connect app.';

  @override
  String get healthConnectInstallPromptTitle => 'Install Health Connect';

  @override
  String get healthConnectInstallPromptBody =>
      'Health Connect is not installed on this device. Install it from the Play Store and try again.';

  @override
  String get healthConnectInstallPromptInstall => 'Install';

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
