import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ko.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ko')];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'Tabata'**
  String get appTitle;

  /// No description provided for @importRoutineTooltip.
  ///
  /// In ko, this message translates to:
  /// **'루틴 가져오기'**
  String get importRoutineTooltip;

  /// No description provided for @noRoutines.
  ///
  /// In ko, this message translates to:
  /// **'저장된 루틴이 없습니다.'**
  String get noRoutines;

  /// No description provided for @createRoutine.
  ///
  /// In ko, this message translates to:
  /// **'루틴 만들기'**
  String get createRoutine;

  /// No description provided for @routineCountDuration.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 운동 · {duration}'**
  String routineCountDuration(int count, String duration);

  /// No description provided for @routineNotFound.
  ///
  /// In ko, this message translates to:
  /// **'루틴을 찾을 수 없습니다.'**
  String get routineNotFound;

  /// No description provided for @editTooltip.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get editTooltip;

  /// No description provided for @shareTooltip.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get shareTooltip;

  /// No description provided for @estimatedDuration.
  ///
  /// In ko, this message translates to:
  /// **'예상 {duration}'**
  String estimatedDuration(String duration);

  /// No description provided for @exerciseListTitle.
  ///
  /// In ko, this message translates to:
  /// **'운동 목록'**
  String get exerciseListTitle;

  /// No description provided for @start.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get start;

  /// No description provided for @labelPrepare.
  ///
  /// In ko, this message translates to:
  /// **'준비'**
  String get labelPrepare;

  /// No description provided for @labelWork.
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get labelWork;

  /// No description provided for @labelRelax.
  ///
  /// In ko, this message translates to:
  /// **'이완'**
  String get labelRelax;

  /// No description provided for @labelReps.
  ///
  /// In ko, this message translates to:
  /// **'횟수'**
  String get labelReps;

  /// No description provided for @labelSets.
  ///
  /// In ko, this message translates to:
  /// **'세트'**
  String get labelSets;

  /// No description provided for @oneSetDuration.
  ///
  /// In ko, this message translates to:
  /// **'1세트 {duration}'**
  String oneSetDuration(String duration);

  /// No description provided for @phaseWithDuration.
  ///
  /// In ko, this message translates to:
  /// **'{label} · {seconds}초'**
  String phaseWithDuration(String label, int seconds);

  /// No description provided for @durationSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{seconds}초'**
  String durationSeconds(int seconds);

  /// No description provided for @countReps.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String countReps(int count);

  /// No description provided for @countSets.
  ///
  /// In ko, this message translates to:
  /// **'{count}세트'**
  String countSets(int count);

  /// No description provided for @importRoutineTitle.
  ///
  /// In ko, this message translates to:
  /// **'루틴 가져오기'**
  String get importRoutineTitle;

  /// No description provided for @importRoutineHint.
  ///
  /// In ko, this message translates to:
  /// **'공유받은 JSON을 붙여넣으세요.'**
  String get importRoutineHint;

  /// No description provided for @importRoutineJsonHint.
  ///
  /// In ko, this message translates to:
  /// **'JSON 형식의 루틴 데이터 전체를 붙여넣으세요'**
  String get importRoutineJsonHint;

  /// No description provided for @import.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get import;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In ko, this message translates to:
  /// **'뒤로'**
  String get back;

  /// No description provided for @done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get done;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @createRoutineTitle.
  ///
  /// In ko, this message translates to:
  /// **'루틴 만들기'**
  String get createRoutineTitle;

  /// No description provided for @editRoutineTitle.
  ///
  /// In ko, this message translates to:
  /// **'루틴 편집'**
  String get editRoutineTitle;

  /// No description provided for @deleteRoutineTooltip.
  ///
  /// In ko, this message translates to:
  /// **'루틴 삭제'**
  String get deleteRoutineTooltip;

  /// No description provided for @deleteRoutineTitle.
  ///
  /// In ko, this message translates to:
  /// **'루틴 삭제'**
  String get deleteRoutineTitle;

  /// No description provided for @deleteRoutineMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 루틴을 삭제할까요?'**
  String get deleteRoutineMessage;

  /// No description provided for @routineNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'루틴 이름'**
  String get routineNameLabel;

  /// No description provided for @routineNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 회전근개 재활'**
  String get routineNameHint;

  /// No description provided for @descriptionOptionalLabel.
  ///
  /// In ko, this message translates to:
  /// **'설명 (선택)'**
  String get descriptionOptionalLabel;

  /// No description provided for @reorderExercisesHint.
  ///
  /// In ko, this message translates to:
  /// **'길게 눌러 순서 변경'**
  String get reorderExercisesHint;

  /// No description provided for @addExercisesPrompt.
  ///
  /// In ko, this message translates to:
  /// **'운동을 추가해 주세요'**
  String get addExercisesPrompt;

  /// No description provided for @addExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 추가'**
  String get addExercise;

  /// No description provided for @requireAtLeastOneExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동을 1개 이상 추가하세요'**
  String get requireAtLeastOneExercise;

  /// No description provided for @addExerciseTitle.
  ///
  /// In ko, this message translates to:
  /// **'운동 추가'**
  String get addExerciseTitle;

  /// No description provided for @editExerciseTitle.
  ///
  /// In ko, this message translates to:
  /// **'운동 편집'**
  String get editExerciseTitle;

  /// No description provided for @basicInfoSection.
  ///
  /// In ko, this message translates to:
  /// **'기본 정보'**
  String get basicInfoSection;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'운동 이름'**
  String get exerciseNameLabel;

  /// No description provided for @exerciseNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 팽귄 운동'**
  String get exerciseNameHint;

  /// No description provided for @exerciseInstructionLabel.
  ///
  /// In ko, this message translates to:
  /// **'설명 (선택)'**
  String get exerciseInstructionLabel;

  /// No description provided for @exerciseInstructionHint.
  ///
  /// In ko, this message translates to:
  /// **'동작 방법을 적어주세요'**
  String get exerciseInstructionHint;

  /// No description provided for @prepareSection.
  ///
  /// In ko, this message translates to:
  /// **'준비'**
  String get prepareSection;

  /// No description provided for @phasesSection.
  ///
  /// In ko, this message translates to:
  /// **'동작 순서'**
  String get phasesSection;

  /// No description provided for @addWorkPhase.
  ///
  /// In ko, this message translates to:
  /// **'운동 추가'**
  String get addWorkPhase;

  /// No description provided for @addRelaxPhase.
  ///
  /// In ko, this message translates to:
  /// **'이완 추가'**
  String get addRelaxPhase;

  /// No description provided for @requireAtLeastOnePhase.
  ///
  /// In ko, this message translates to:
  /// **'동작을 1개 이상 추가하세요'**
  String get requireAtLeastOnePhase;

  /// No description provided for @reorderPhasesHint.
  ///
  /// In ko, this message translates to:
  /// **'드래그하여 순서 변경'**
  String get reorderPhasesHint;

  /// No description provided for @workSection.
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get workSection;

  /// No description provided for @relaxSection.
  ///
  /// In ko, this message translates to:
  /// **'이완'**
  String get relaxSection;

  /// No description provided for @repeatSection.
  ///
  /// In ko, this message translates to:
  /// **'반복'**
  String get repeatSection;

  /// No description provided for @phaseLabel.
  ///
  /// In ko, this message translates to:
  /// **'동작 라벨'**
  String get phaseLabel;

  /// No description provided for @workLabelHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 팔을 벌리기'**
  String get workLabelHint;

  /// No description provided for @relaxLabelHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 팔을 오므리기'**
  String get relaxLabelHint;

  /// No description provided for @previewSection.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get previewSection;

  /// No description provided for @totalDuration.
  ///
  /// In ko, this message translates to:
  /// **'전체 {duration}'**
  String totalDuration(String duration);

  /// No description provided for @newExercise.
  ///
  /// In ko, this message translates to:
  /// **'새 운동'**
  String get newExercise;

  /// No description provided for @exerciseListSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'{phases} · {repsSets} · {oneSet}'**
  String exerciseListSubtitle(String phases, String repsSets, String oneSet);

  /// No description provided for @repsSetsSummary.
  ///
  /// In ko, this message translates to:
  /// **'{reps}회 × {sets}세트'**
  String repsSetsSummary(int reps, int sets);

  /// No description provided for @validationNameRequired.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get validationNameRequired;

  /// No description provided for @validationLabelRequired.
  ///
  /// In ko, this message translates to:
  /// **'라벨을 입력하세요'**
  String get validationLabelRequired;

  /// No description provided for @enterValueTitle.
  ///
  /// In ko, this message translates to:
  /// **'값 입력'**
  String get enterValueTitle;

  /// No description provided for @dragToAdjustHint.
  ///
  /// In ko, this message translates to:
  /// **'좌우로 드래그하여 조절 · 탭하면 직접 입력'**
  String get dragToAdjustHint;

  /// No description provided for @unitSeconds.
  ///
  /// In ko, this message translates to:
  /// **'초'**
  String get unitSeconds;

  /// No description provided for @unitMinutes.
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get unitMinutes;

  /// No description provided for @tapToSetDuration.
  ///
  /// In ko, this message translates to:
  /// **'탭하여 시간 설정'**
  String get tapToSetDuration;

  /// No description provided for @unitReps.
  ///
  /// In ko, this message translates to:
  /// **'회'**
  String get unitReps;

  /// No description provided for @unitSets.
  ///
  /// In ko, this message translates to:
  /// **'세트'**
  String get unitSets;

  /// No description provided for @durationMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String durationMinutes(int minutes);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 {seconds}초'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durationApproxMinutes.
  ///
  /// In ko, this message translates to:
  /// **'약 {minutes}분'**
  String durationApproxMinutes(int minutes);

  /// No description provided for @durationApproxHours.
  ///
  /// In ko, this message translates to:
  /// **'약 {hours}시간'**
  String durationApproxHours(int hours);

  /// No description provided for @durationApproxHoursMinutes.
  ///
  /// In ko, this message translates to:
  /// **'약 {hours}시간 {minutes}분'**
  String durationApproxHoursMinutes(int hours, int minutes);

  /// No description provided for @workoutProgress.
  ///
  /// In ko, this message translates to:
  /// **'운동 {current}/{total}'**
  String workoutProgress(int current, int total);

  /// No description provided for @phasePrepare.
  ///
  /// In ko, this message translates to:
  /// **'준비'**
  String get phasePrepare;

  /// No description provided for @phaseWork.
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get phaseWork;

  /// No description provided for @phaseRelax.
  ///
  /// In ko, this message translates to:
  /// **'이완'**
  String get phaseRelax;

  /// No description provided for @phaseCompleted.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get phaseCompleted;

  /// No description provided for @workoutCompletedMessage.
  ///
  /// In ko, this message translates to:
  /// **'수고하셨습니다'**
  String get workoutCompletedMessage;

  /// No description provided for @repSetProgress.
  ///
  /// In ko, this message translates to:
  /// **'{rep}/{totalReps}회 · {set}/{totalSets}세트'**
  String repSetProgress(int rep, int totalReps, int set, int totalSets);

  /// No description provided for @skipPhase.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get skipPhase;

  /// No description provided for @pause.
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In ko, this message translates to:
  /// **'재개'**
  String get resume;

  /// No description provided for @skipExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 스킵'**
  String get skipExercise;

  /// No description provided for @workoutDone.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get workoutDone;

  /// No description provided for @errorEmptyJson.
  ///
  /// In ko, this message translates to:
  /// **'빈 데이터입니다.'**
  String get errorEmptyJson;

  /// No description provided for @errorInvalidRoutineJson.
  ///
  /// In ko, this message translates to:
  /// **'루틴 JSON 형식이 아닙니다.'**
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
      <String>['ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
