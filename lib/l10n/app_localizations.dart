import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tabata'**
  String get appTitle;

  /// No description provided for @importRoutineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import routine'**
  String get importRoutineTooltip;

  /// No description provided for @noRoutines.
  ///
  /// In en, this message translates to:
  /// **'No saved routines.'**
  String get noRoutines;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createRoutine;

  /// No description provided for @routineCountDuration.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises · {duration}'**
  String routineCountDuration(int count, String duration);

  /// No description provided for @routineNotFound.
  ///
  /// In en, this message translates to:
  /// **'Routine not found.'**
  String get routineNotFound;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @shareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTooltip;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Est. {duration}'**
  String estimatedDuration(String duration);

  /// No description provided for @exerciseListTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exerciseListTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @labelPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get labelPrepare;

  /// No description provided for @labelWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get labelWork;

  /// No description provided for @labelRelax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get labelRelax;

  /// No description provided for @labelReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get labelReps;

  /// No description provided for @labelSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get labelSets;

  /// No description provided for @oneSetDuration.
  ///
  /// In en, this message translates to:
  /// **'1 set {duration}'**
  String oneSetDuration(String duration);

  /// No description provided for @phaseWithDuration.
  ///
  /// In en, this message translates to:
  /// **'{label} · {seconds}s'**
  String phaseWithDuration(String label, int seconds);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String durationSeconds(int seconds);

  /// No description provided for @countReps.
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String countReps(int count);

  /// No description provided for @countSets.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String countSets(int count);

  /// No description provided for @importRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Import routine'**
  String get importRoutineTitle;

  /// No description provided for @importRoutineHint.
  ///
  /// In en, this message translates to:
  /// **'Paste shared JSON below.'**
  String get importRoutineHint;

  /// No description provided for @importRoutineJsonHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the full routine JSON'**
  String get importRoutineJsonHint;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @createRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createRoutineTitle;

  /// No description provided for @editRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get editRoutineTitle;

  /// No description provided for @deleteRoutineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete routine'**
  String get deleteRoutineTooltip;

  /// No description provided for @deleteRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete routine'**
  String get deleteRoutineTitle;

  /// No description provided for @deleteRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this routine?'**
  String get deleteRoutineMessage;

  /// No description provided for @routineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Routine name'**
  String get routineNameLabel;

  /// No description provided for @routineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rotator cuff rehab'**
  String get routineNameHint;

  /// No description provided for @descriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptionalLabel;

  /// No description provided for @reorderExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Long press to reorder'**
  String get reorderExercisesHint;

  /// No description provided for @addExercisesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add an exercise'**
  String get addExercisesPrompt;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @requireAtLeastOneExercise.
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise'**
  String get requireAtLeastOneExercise;

  /// No description provided for @addExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExerciseTitle;

  /// No description provided for @editExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get editExerciseTitle;

  /// No description provided for @basicInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get basicInfoSection;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseNameLabel;

  /// No description provided for @exerciseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Penguin exercise'**
  String get exerciseNameHint;

  /// No description provided for @exerciseInstructionLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions (optional)'**
  String get exerciseInstructionLabel;

  /// No description provided for @exerciseInstructionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe how to perform the movement'**
  String get exerciseInstructionHint;

  /// No description provided for @prepareSection.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get prepareSection;

  /// No description provided for @phasesSection.
  ///
  /// In en, this message translates to:
  /// **'Phase order'**
  String get phasesSection;

  /// No description provided for @addWorkPhase.
  ///
  /// In en, this message translates to:
  /// **'Add work'**
  String get addWorkPhase;

  /// No description provided for @addRelaxPhase.
  ///
  /// In en, this message translates to:
  /// **'Add relax'**
  String get addRelaxPhase;

  /// No description provided for @requireAtLeastOnePhase.
  ///
  /// In en, this message translates to:
  /// **'Add at least one phase'**
  String get requireAtLeastOnePhase;

  /// No description provided for @reorderPhasesHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get reorderPhasesHint;

  /// No description provided for @workSection.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get workSection;

  /// No description provided for @relaxSection.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get relaxSection;

  /// No description provided for @repeatSection.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatSection;

  /// No description provided for @phaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase label'**
  String get phaseLabel;

  /// No description provided for @workLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Arms out'**
  String get workLabelHint;

  /// No description provided for @relaxLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Arms in'**
  String get relaxLabelHint;

  /// No description provided for @previewSection.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSection;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total {duration}'**
  String totalDuration(String duration);

  /// No description provided for @newExercise.
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get newExercise;

  /// No description provided for @exerciseListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{phases} · {repsSets} · {oneSet}'**
  String exerciseListSubtitle(String phases, String repsSets, String oneSet);

  /// No description provided for @repsSetsSummary.
  ///
  /// In en, this message translates to:
  /// **'{reps} reps × {sets} sets'**
  String repsSetsSummary(int reps, int sets);

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get validationNameRequired;

  /// No description provided for @validationLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a label'**
  String get validationLabelRequired;

  /// No description provided for @enterValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get enterValueTitle;

  /// No description provided for @dragToAdjustHint.
  ///
  /// In en, this message translates to:
  /// **'Drag left/right to adjust · tap to type'**
  String get dragToAdjustHint;

  /// No description provided for @unitSeconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get unitSeconds;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutes;

  /// No description provided for @tapToSetDuration.
  ///
  /// In en, this message translates to:
  /// **'Tap to set duration'**
  String get tapToSetDuration;

  /// No description provided for @unitReps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get unitReps;

  /// No description provided for @unitSets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get unitSets;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} s'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durationApproxMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String durationApproxMinutes(int minutes);

  /// No description provided for @durationApproxHours.
  ///
  /// In en, this message translates to:
  /// **'~{hours} h'**
  String durationApproxHours(int hours);

  /// No description provided for @durationApproxHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{hours} h {minutes} min'**
  String durationApproxHoursMinutes(int hours, int minutes);

  /// No description provided for @workoutProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current}/{total}'**
  String workoutProgress(int current, int total);

  /// No description provided for @phasePrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get phasePrepare;

  /// No description provided for @phaseWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get phaseWork;

  /// No description provided for @phaseRelax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get phaseRelax;

  /// No description provided for @phaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get phaseCompleted;

  /// No description provided for @workoutCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Great job'**
  String get workoutCompletedMessage;

  /// No description provided for @repSetProgress.
  ///
  /// In en, this message translates to:
  /// **'{rep}/{totalReps} reps · {set}/{totalSets} sets'**
  String repSetProgress(int rep, int totalReps, int set, int totalSets);

  /// No description provided for @skipPhase.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipPhase;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @skipExercise.
  ///
  /// In en, this message translates to:
  /// **'Skip exercise'**
  String get skipExercise;

  /// No description provided for @workoutDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get workoutDone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @voiceGuidance.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance'**
  String get voiceGuidance;

  /// No description provided for @voiceGuidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Announces phases and countdown during workouts'**
  String get voiceGuidanceSubtitle;

  /// No description provided for @voiceCountThree.
  ///
  /// In en, this message translates to:
  /// **'three'**
  String get voiceCountThree;

  /// No description provided for @voiceCountTwo.
  ///
  /// In en, this message translates to:
  /// **'two'**
  String get voiceCountTwo;

  /// No description provided for @voiceCountOne.
  ///
  /// In en, this message translates to:
  /// **'one'**
  String get voiceCountOne;

  /// No description provided for @errorEmptyJson.
  ///
  /// In en, this message translates to:
  /// **'Empty data.'**
  String get errorEmptyJson;

  /// No description provided for @errorInvalidRoutineJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid routine JSON.'**
  String get errorInvalidRoutineJson;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
