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
  /// **'Everyone\'s Tabata'**
  String get appTitle;

  /// No description provided for @importRoutineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import routine'**
  String get importRoutineTooltip;

  /// No description provided for @uploadRoutineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share my routines'**
  String get uploadRoutineTooltip;

  /// No description provided for @uploadRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Share my routines'**
  String get uploadRoutineTitle;

  /// No description provided for @uploadAdminLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with an admin account to publish routines to the server.'**
  String get uploadAdminLoginHint;

  /// No description provided for @uploadAdminUsername.
  ///
  /// In en, this message translates to:
  /// **'Admin username'**
  String get uploadAdminUsername;

  /// No description provided for @uploadAdminPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get uploadAdminPassword;

  /// No description provided for @uploadAdminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin sign in'**
  String get uploadAdminLogin;

  /// No description provided for @uploadLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get uploadLogout;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account and uploaded routines, profile, and images on the server will be deleted. Local routines on this device are kept. This cannot be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again later.'**
  String get deleteAccountFailed;

  /// No description provided for @deleteAccountRecentLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'For security, sign in again and then delete your account.'**
  String get deleteAccountRecentLoginRequired;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @uploadSelectRoutine.
  ///
  /// In en, this message translates to:
  /// **'Choose a routine to upload'**
  String get uploadSelectRoutine;

  /// No description provided for @uploadNoLocalRoutines.
  ///
  /// In en, this message translates to:
  /// **'No routines saved on this device.'**
  String get uploadNoLocalRoutines;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploadUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get uploadUpdate;

  /// No description provided for @uploadConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload to server'**
  String get uploadConfirmTitle;

  /// No description provided for @uploadConfirmCreate.
  ///
  /// In en, this message translates to:
  /// **'Add \"{title}\" to the server?'**
  String uploadConfirmCreate(String title);

  /// No description provided for @uploadConfirmUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update \"{title}\" on the server?'**
  String uploadConfirmUpdate(String title);

  /// No description provided for @uploadSuccessCreated.
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\" to the server.'**
  String uploadSuccessCreated(String title);

  /// No description provided for @uploadSuccessUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated \"{title}\" on the server.'**
  String uploadSuccessUpdated(String title);

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed.'**
  String get uploadError;

  /// No description provided for @uploadLoginError.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get uploadLoginError;

  /// No description provided for @uploadLoadServerIdsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load server routine list.'**
  String get uploadLoadServerIdsError;

  /// No description provided for @uploadServerRoutineSection.
  ///
  /// In en, this message translates to:
  /// **'My uploaded routines'**
  String get uploadServerRoutineSection;

  /// No description provided for @uploadServerRoutineHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit. Saving updates the server copy.'**
  String get uploadServerRoutineHint;

  /// No description provided for @uploadLocalRoutineSection.
  ///
  /// In en, this message translates to:
  /// **'Routines on this device'**
  String get uploadLocalRoutineSection;

  /// No description provided for @uploadLocalRoutineHint.
  ///
  /// In en, this message translates to:
  /// **'Routines saved on this device. Uploading copies them to the server without removing the local copy.'**
  String get uploadLocalRoutineHint;

  /// No description provided for @uploadNoAdminRoutines.
  ///
  /// In en, this message translates to:
  /// **'No uploaded routines yet.'**
  String get uploadNoAdminRoutines;

  /// No description provided for @uploadEditServerRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit server routine'**
  String get uploadEditServerRoutineTitle;

  /// No description provided for @uploadDeleteServerRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this routine from the server?'**
  String get uploadDeleteServerRoutineMessage;

  /// No description provided for @downloadRoutineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadRoutineTooltip;

  /// No description provided for @routineDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{title}\" to this device.'**
  String routineDownloadSuccess(String title);

  /// No description provided for @routineDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Download failed.'**
  String get routineDownloadError;

  /// No description provided for @routineCountOnly.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String routineCountOnly(int count);

  /// No description provided for @deleteLocalCopyMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this routine from this device? Server routines can be downloaded again.'**
  String get deleteLocalCopyMessage;

  /// No description provided for @noRoutines.
  ///
  /// In en, this message translates to:
  /// **'No saved routines.'**
  String get noRoutines;

  /// No description provided for @noMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'No routines yet. Create one or download from the shared catalog.'**
  String get noMyRoutines;

  /// No description provided for @noSharedRoutines.
  ///
  /// In en, this message translates to:
  /// **'No shared routines.'**
  String get noSharedRoutines;

  /// No description provided for @homeTabMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'My routines'**
  String get homeTabMyRoutines;

  /// No description provided for @homeTabShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get homeTabShared;

  /// No description provided for @homeDownloadCatalogHint.
  ///
  /// In en, this message translates to:
  /// **'Download to add to My routines.'**
  String get homeDownloadCatalogHint;

  /// No description provided for @homeCatalogOfficialSection.
  ///
  /// In en, this message translates to:
  /// **'Default routines'**
  String get homeCatalogOfficialSection;

  /// No description provided for @homeCatalogSharedSection.
  ///
  /// In en, this message translates to:
  /// **'User routines'**
  String get homeCatalogSharedSection;

  /// No description provided for @searchRoutinesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search routines'**
  String get searchRoutinesTooltip;

  /// No description provided for @searchRoutinesHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or description'**
  String get searchRoutinesHint;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching routines.'**
  String get noSearchResults;

  /// No description provided for @routineAddedToMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\" to My routines.'**
  String routineAddedToMyRoutines(String title);

  /// No description provided for @catalogSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved in My routines'**
  String catalogSavedCount(int count);

  /// No description provided for @openSavedCopy.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openSavedCopy;

  /// No description provided for @loadingProfiles.
  ///
  /// In en, this message translates to:
  /// **'Loading routines...'**
  String get loadingProfiles;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load routines from server.'**
  String get profileLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createRoutine;

  /// No description provided for @aiRoutineCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create routine with AI'**
  String get aiRoutineCreateButton;

  /// No description provided for @aiRoutineCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a routine with AI after watching an ad'**
  String get aiRoutineCreateTitle;

  /// No description provided for @aiRoutineCreatePromptHint.
  ///
  /// In en, this message translates to:
  /// **'Example:\nhttps://www.youtube.com/watch?v=9bZkp7q19f0\nCreate a workout routine based on this video.\n\nOr\n\nMy neck has been really stiff lately—make a routine with stretches you recommend.'**
  String get aiRoutineCreatePromptHint;

  /// No description provided for @aiRoutineCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create routine after watching ad'**
  String get aiRoutineCreateSubmit;

  /// No description provided for @aiRoutineCreateLoading.
  ///
  /// In en, this message translates to:
  /// **'AI is building your routine...'**
  String get aiRoutineCreateLoading;

  /// No description provided for @aiRoutineCreateAdLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading ad...'**
  String get aiRoutineCreateAdLoading;

  /// No description provided for @aiRoutineCreatePromptRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your request.'**
  String get aiRoutineCreatePromptRequired;

  /// No description provided for @aiRoutineCreateAdRequired.
  ///
  /// In en, this message translates to:
  /// **'Please watch the ad to continue.'**
  String get aiRoutineCreateAdRequired;

  /// No description provided for @aiRoutineCreateAdLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the ad. Check your connection and try again shortly.'**
  String get aiRoutineCreateAdLoadFailed;

  /// No description provided for @aiRoutineCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the routine. Please try again.'**
  String get aiRoutineCreateError;

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

  /// No description provided for @shareAppTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareAppTooltip;

  /// No description provided for @shareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Try {appTitle} — interval timer for workout routines.'**
  String shareAppMessage(String appTitle);

  /// No description provided for @shareSheetKakaoTalk.
  ///
  /// In en, this message translates to:
  /// **'Share to KakaoTalk'**
  String get shareSheetKakaoTalk;

  /// No description provided for @shareSheetSystemShare.
  ///
  /// In en, this message translates to:
  /// **'System share'**
  String get shareSheetSystemShare;

  /// No description provided for @shareRoutineFooter.
  ///
  /// In en, this message translates to:
  /// **'Try this routine in {appTitle}'**
  String shareRoutineFooter(String appTitle);

  /// No description provided for @shareKakaoLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Open routine'**
  String get shareKakaoLinkButton;

  /// No description provided for @shareKakaoAppLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Get the app'**
  String get shareKakaoAppLinkButton;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share. Please try again.'**
  String get shareFailed;

  /// No description provided for @sharedRoutineImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared routine'**
  String get sharedRoutineImportTitle;

  /// No description provided for @sharedRoutineImportPrompt.
  ///
  /// In en, this message translates to:
  /// **'Download this shared routine?'**
  String get sharedRoutineImportPrompt;

  /// No description provided for @sharedRoutineImportYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get sharedRoutineImportYes;

  /// No description provided for @sharedRoutineImportMessage.
  ///
  /// In en, this message translates to:
  /// **'Add \"{title}\" to My routines?'**
  String sharedRoutineImportMessage(String title);

  /// No description provided for @sharedRoutineImportAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to My routines'**
  String get sharedRoutineImportAdd;

  /// No description provided for @sharedRoutineImportError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the shared routine.'**
  String get sharedRoutineImportError;

  /// No description provided for @sharedRoutineNotFound.
  ///
  /// In en, this message translates to:
  /// **'This share link was not found or has expired.'**
  String get sharedRoutineNotFound;

  /// No description provided for @catalogAuthor.
  ///
  /// In en, this message translates to:
  /// **'By {author}'**
  String catalogAuthor(String author);

  /// No description provided for @catalogAuthorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get catalogAuthorUnknown;

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

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get seeMore;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get collapse;

  /// No description provided for @startAll.
  ///
  /// In en, this message translates to:
  /// **'Start all'**
  String get startAll;

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

  /// No description provided for @phaseWithCountTiming.
  ///
  /// In en, this message translates to:
  /// **'{label} · {count} reps × {seconds}s'**
  String phaseWithCountTiming(String label, int count, int seconds);

  /// No description provided for @phaseTimingModeDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get phaseTimingModeDuration;

  /// No description provided for @phaseTimingModeCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get phaseTimingModeCount;

  /// No description provided for @labelPhaseCount.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get labelPhaseCount;

  /// No description provided for @labelSecondsPerRep.
  ///
  /// In en, this message translates to:
  /// **'Per rep'**
  String get labelSecondsPerRep;

  /// No description provided for @tapToSetPhaseCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to set reps'**
  String get tapToSetPhaseCount;

  /// No description provided for @countOrderAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get countOrderAscending;

  /// No description provided for @countOrderDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get countOrderDescending;

  /// No description provided for @repCountProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String repCountProgress(int current, int total);

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

  /// No description provided for @defaultRoutineName.
  ///
  /// In en, this message translates to:
  /// **'Default routine'**
  String get defaultRoutineName;

  /// No description provided for @defaultExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Default exercise'**
  String get defaultExerciseName;

  /// No description provided for @descriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptionalLabel;

  /// No description provided for @descriptionBlocksEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add text, reference photos, and video links in order.'**
  String get descriptionBlocksEmptyHint;

  /// No description provided for @descriptionAddText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get descriptionAddText;

  /// No description provided for @descriptionAddImage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get descriptionAddImage;

  /// No description provided for @descriptionAddVideo.
  ///
  /// In en, this message translates to:
  /// **'Video link'**
  String get descriptionAddVideo;

  /// No description provided for @descriptionTextHint.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get descriptionTextHint;

  /// No description provided for @descriptionVideoUrlHint.
  ///
  /// In en, this message translates to:
  /// **'YouTube or other video URL'**
  String get descriptionVideoUrlHint;

  /// No description provided for @descriptionVideoUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid video URL.'**
  String get descriptionVideoUrlInvalid;

  /// No description provided for @descriptionVideoBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Video link'**
  String get descriptionVideoBlockLabel;

  /// No description provided for @descriptionVideoPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap to play'**
  String get descriptionVideoPlay;

  /// No description provided for @descriptionVideoExternal.
  ///
  /// In en, this message translates to:
  /// **'Open external video'**
  String get descriptionVideoExternal;

  /// No description provided for @descriptionImageLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to add photos.'**
  String get descriptionImageLoginRequired;

  /// No description provided for @photoLibraryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo library access is required to add images.'**
  String get photoLibraryPermissionRequired;

  /// No description provided for @descriptionImageUploadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo.'**
  String get descriptionImageUploadError;

  /// No description provided for @descriptionImageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load image.'**
  String get descriptionImageLoadError;

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

  /// No description provided for @importExercisesButton.
  ///
  /// In en, this message translates to:
  /// **'Import from another routine'**
  String get importExercisesButton;

  /// No description provided for @importExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Import exercises'**
  String get importExercisesTitle;

  /// No description provided for @importExercisesChooseRoutine.
  ///
  /// In en, this message translates to:
  /// **'Choose a routine'**
  String get importExercisesChooseRoutine;

  /// No description provided for @importExercisesNoOtherRoutines.
  ///
  /// In en, this message translates to:
  /// **'No other routines to import from.'**
  String get importExercisesNoOtherRoutines;

  /// No description provided for @importExercisesNoExercisesInRoutine.
  ///
  /// In en, this message translates to:
  /// **'This routine has no exercises.'**
  String get importExercisesNoExercisesInRoutine;

  /// No description provided for @importExercisesAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String importExercisesAddCount(int count);

  /// No description provided for @importExercisesAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added {count} exercise(s)'**
  String importExercisesAddedSnack(int count);

  /// No description provided for @importExercisesSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get importExercisesSelectAll;

  /// No description provided for @importExercisesClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get importExercisesClearSelection;

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

  /// No description provided for @tapToSetReps.
  ///
  /// In en, this message translates to:
  /// **'Tap to set reps'**
  String get tapToSetReps;

  /// No description provided for @tapToSetSets.
  ///
  /// In en, this message translates to:
  /// **'Tap to set sets'**
  String get tapToSetSets;

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

  /// No description provided for @workoutRemainingReps.
  ///
  /// In en, this message translates to:
  /// **'Reps left'**
  String get workoutRemainingReps;

  /// No description provided for @workoutRemainingSets.
  ///
  /// In en, this message translates to:
  /// **'Sets left'**
  String get workoutRemainingSets;

  /// No description provided for @workoutNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get workoutNext;

  /// No description provided for @workoutPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get workoutPrevious;

  /// No description provided for @nextPhaseFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get nextPhaseFinish;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @workoutSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutSettingsSection;

  /// No description provided for @countSecondsWithTtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice second count'**
  String get countSecondsWithTtsTitle;

  /// No description provided for @countSecondsWithTtsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speaks each second in count mode only. When off, beeps play instead.'**
  String get countSecondsWithTtsSubtitle;

  /// No description provided for @contentSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentSettingsSection;

  /// No description provided for @autoTranslateContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-translate content'**
  String get autoTranslateContentTitle;

  /// No description provided for @autoTranslateContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Translate titles, descriptions, and exercise names from the server into your app language.'**
  String get autoTranslateContentSubtitle;

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

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tick each second and chime when reps or sets change'**
  String get soundEffectsSubtitle;

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

  /// No description provided for @settingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegalSection;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAppDisclosures.
  ///
  /// In en, this message translates to:
  /// **'Service notice & disclaimers'**
  String get settingsAppDisclosures;

  /// No description provided for @privacyProcessingConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms, shared content & privacy'**
  String get privacyProcessingConsentTitle;

  /// No description provided for @privacyProcessingConsentLead.
  ///
  /// In en, this message translates to:
  /// **'To upload or share workout routines (user-generated content), please review and agree below.'**
  String get privacyProcessingConsentLead;

  /// No description provided for @privacyProcessingConsentSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get privacyProcessingConsentSectionPrivacy;

  /// No description provided for @privacyProcessingConsentSectionUgc.
  ///
  /// In en, this message translates to:
  /// **'Shared routines (UGC)'**
  String get privacyProcessingConsentSectionUgc;

  /// No description provided for @privacyProcessingConsentUgcIntro.
  ///
  /// In en, this message translates to:
  /// **'Applies when you upload routines visible to other users. YouTube and other video links play via the official embed player only; we do not host or redistribute video files.'**
  String get privacyProcessingConsentUgcIntro;

  /// No description provided for @privacyProcessingConsentBullet1.
  ///
  /// In en, this message translates to:
  /// **'We collect: Firebase UID, email (if provided), nickname, uploaded routines (title, description, exercises, image URLs, video link URLs).'**
  String get privacyProcessingConsentBullet1;

  /// No description provided for @privacyProcessingConsentBullet2.
  ///
  /// In en, this message translates to:
  /// **'Purposes: account identity, routine sharing, abuse prevention, service improvement.'**
  String get privacyProcessingConsentBullet2;

  /// No description provided for @privacyProcessingConsentBullet3.
  ///
  /// In en, this message translates to:
  /// **'Retention: deleted when you delete your account unless law requires longer retention.'**
  String get privacyProcessingConsentBullet3;

  /// No description provided for @privacyProcessingConsentUgcBullet1.
  ///
  /// In en, this message translates to:
  /// **'Zero tolerance for illegal, violent, sexual, hateful, spam, or rights-infringing routines, images, or video links.'**
  String get privacyProcessingConsentUgcBullet1;

  /// No description provided for @privacyProcessingConsentUgcBullet2.
  ///
  /// In en, this message translates to:
  /// **'Violations may result in content removal, upload restrictions, or account suspension.'**
  String get privacyProcessingConsentUgcBullet2;

  /// No description provided for @privacyProcessingConsentUgcBullet3.
  ///
  /// In en, this message translates to:
  /// **'Report inappropriate shared routines via the developer contact on the app store.'**
  String get privacyProcessingConsentUgcBullet3;

  /// No description provided for @privacyProcessingConsentCheckboxPrivacy.
  ///
  /// In en, this message translates to:
  /// **'I agree to the collection and use of personal data described above.'**
  String get privacyProcessingConsentCheckboxPrivacy;

  /// No description provided for @privacyProcessingConsentCheckboxUgc.
  ///
  /// In en, this message translates to:
  /// **'I agree to the shared routine (UGC) rules and zero-tolerance policy.'**
  String get privacyProcessingConsentCheckboxUgc;

  /// No description provided for @privacyProcessingConsentAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get privacyProcessingConsentAgree;

  /// No description provided for @privacyProcessingConsentDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get privacyProcessingConsentDecline;

  /// No description provided for @scheduleWorkoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleWorkoutTooltip;

  /// No description provided for @scheduleWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule workout'**
  String get scheduleWorkoutTitle;

  /// No description provided for @scheduleWorkoutDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get scheduleWorkoutDate;

  /// No description provided for @scheduleWorkoutTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get scheduleWorkoutTime;

  /// No description provided for @scheduleWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleWorkoutConfirm;

  /// No description provided for @scheduleWorkoutCancelExisting.
  ///
  /// In en, this message translates to:
  /// **'Cancel schedule'**
  String get scheduleWorkoutCancelExisting;

  /// No description provided for @scheduleWorkoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {time}.'**
  String scheduleWorkoutSuccess(String time);

  /// No description provided for @scheduleWorkoutCancelled.
  ///
  /// In en, this message translates to:
  /// **'Schedule cancelled.'**
  String get scheduleWorkoutCancelled;

  /// No description provided for @scheduleWorkoutPastTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time in the future.'**
  String get scheduleWorkoutPastTime;

  /// No description provided for @scheduleWorkoutPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required. Allow notifications in Settings.'**
  String get scheduleWorkoutPermissionRequired;

  /// No description provided for @scheduleWorkoutNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to work out'**
  String get scheduleWorkoutNotificationTitle;

  /// No description provided for @scheduleWorkoutNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Start your {title} routine.'**
  String scheduleWorkoutNotificationBody(String title);

  /// No description provided for @scheduleWorkoutActive.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String scheduleWorkoutActive(String time);

  /// No description provided for @scheduleRecurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get scheduleRecurrenceLabel;

  /// No description provided for @scheduleRecurrenceOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get scheduleRecurrenceOnce;

  /// No description provided for @scheduleRecurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get scheduleRecurrenceDaily;

  /// No description provided for @scheduleRecurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get scheduleRecurrenceWeekly;

  /// No description provided for @scheduleRecurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get scheduleRecurrenceMonthly;

  /// No description provided for @scheduleWorkoutStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get scheduleWorkoutStartDate;

  /// No description provided for @scheduleRecurrenceEndDate.
  ///
  /// In en, this message translates to:
  /// **'End repeat'**
  String get scheduleRecurrenceEndDate;

  /// No description provided for @scheduleRecurrenceEndDateNone.
  ///
  /// In en, this message translates to:
  /// **'None (ongoing)'**
  String get scheduleRecurrenceEndDateNone;

  /// No description provided for @scheduleRecurrenceEndDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose an end date for the repeat.'**
  String get scheduleRecurrenceEndDateRequired;

  /// No description provided for @scheduleRecurrenceEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be on or after the start date.'**
  String get scheduleRecurrenceEndBeforeStart;

  /// No description provided for @scheduleRecurrenceWeeklyHint.
  ///
  /// In en, this message translates to:
  /// **'Repeats on the weekday of the selected date.'**
  String get scheduleRecurrenceWeeklyHint;

  /// No description provided for @scheduleRecurrenceMonthlyHint.
  ///
  /// In en, this message translates to:
  /// **'Repeats on the same day of each month.'**
  String get scheduleRecurrenceMonthlyHint;

  /// No description provided for @scheduleRecurrenceDailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String scheduleRecurrenceDailySummary(String time);

  /// No description provided for @scheduleRecurrenceWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly on {weekday} at {time}'**
  String scheduleRecurrenceWeeklySummary(String weekday, String time);

  /// No description provided for @scheduleRecurrenceMonthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly on day {day} at {time}'**
  String scheduleRecurrenceMonthlySummary(int day, String time);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Everyone\'s Tabata'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to get started?'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingOptionQuickStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start working out now'**
  String get onboardingOptionQuickStartTitle;

  /// No description provided for @onboardingOptionQuickStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick recommended routines to add to My Routines'**
  String get onboardingOptionQuickStartSubtitle;

  /// No description provided for @onboardingOptionYoutubeTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow YouTube or a workout'**
  String get onboardingOptionYoutubeTitle;

  /// No description provided for @onboardingOptionYoutubeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI builds a routine from a video or workout name'**
  String get onboardingOptionYoutubeSubtitle;

  /// No description provided for @onboardingOptionGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Match your goal or focus'**
  String get onboardingOptionGoalTitle;

  /// No description provided for @onboardingOptionGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose goal, time, and level—AI creates your routine'**
  String get onboardingOptionGoalSubtitle;

  /// No description provided for @onboardingOptionCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create from scratch'**
  String get onboardingOptionCreateTitle;

  /// No description provided for @onboardingOptionCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set prep, work, and rest intervals yourself'**
  String get onboardingOptionCreateSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboardingSkip;

  /// No description provided for @onboardingRecommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended routines'**
  String get onboardingRecommendedTitle;

  /// No description provided for @onboardingRecommendedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select routines to add. All are selected by default.'**
  String get onboardingRecommendedSubtitle;

  /// No description provided for @onboardingRecommendedSave.
  ///
  /// In en, this message translates to:
  /// **'Add to My Routines'**
  String get onboardingRecommendedSave;

  /// No description provided for @onboardingRecommendedSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one routine.'**
  String get onboardingRecommendedSelectAtLeastOne;

  /// No description provided for @onboardingRecommendedDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download routines. Check your connection and try again.'**
  String get onboardingRecommendedDownloadFailed;

  /// No description provided for @onboardingRecommendedLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load recommended routines.'**
  String get onboardingRecommendedLoadError;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom routine'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalStepGoal.
  ///
  /// In en, this message translates to:
  /// **'What\'s your goal?'**
  String get onboardingGoalStepGoal;

  /// No description provided for @onboardingGoalStepDuration.
  ///
  /// In en, this message translates to:
  /// **'How long should it be?'**
  String get onboardingGoalStepDuration;

  /// No description provided for @onboardingGoalStepLevel.
  ///
  /// In en, this message translates to:
  /// **'What\'s your level?'**
  String get onboardingGoalStepLevel;

  /// No description provided for @onboardingGoalNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingGoalNext;

  /// No description provided for @onboardingGoalCreate.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get onboardingGoalCreate;

  /// No description provided for @onboardingGoalOptionWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight loss'**
  String get onboardingGoalOptionWeightLoss;

  /// No description provided for @onboardingGoalOptionStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get onboardingGoalOptionStrength;

  /// No description provided for @onboardingGoalOptionFlexibility.
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get onboardingGoalOptionFlexibility;

  /// No description provided for @onboardingGoalOptionFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get onboardingGoalOptionFullBody;

  /// No description provided for @onboardingGoalOptionUpperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper body'**
  String get onboardingGoalOptionUpperBody;

  /// No description provided for @onboardingGoalOptionLowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower body'**
  String get onboardingGoalOptionLowerBody;

  /// No description provided for @onboardingGoalOptionCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get onboardingGoalOptionCore;

  /// No description provided for @onboardingGoalDuration5.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get onboardingGoalDuration5;

  /// No description provided for @onboardingGoalDuration10.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get onboardingGoalDuration10;

  /// No description provided for @onboardingGoalDuration15.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get onboardingGoalDuration15;

  /// No description provided for @onboardingGoalDuration20.
  ///
  /// In en, this message translates to:
  /// **'20 min'**
  String get onboardingGoalDuration20;

  /// No description provided for @onboardingGoalLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get onboardingGoalLevelBeginner;

  /// No description provided for @onboardingGoalLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get onboardingGoalLevelIntermediate;

  /// No description provided for @onboardingAiYoutubeInitialPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a YouTube URL or workout name.\n\nExample:\nhttps://www.youtube.com/watch?v=example\nCreate a Tabata interval routine from this video with prep, work, and rest phases.'**
  String get onboardingAiYoutubeInitialPrompt;

  /// No description provided for @onboardingAiGoalPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a Tabata interval routine for goal: {goal}, duration: {duration} minutes, level: {level}. Split into prep, work, and rest phases.'**
  String onboardingAiGoalPrompt(String goal, String duration, String level);

  /// No description provided for @settingsAppSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsAppSection;

  /// No description provided for @settingsShowOnboardingAgain.
  ///
  /// In en, this message translates to:
  /// **'Show onboarding again'**
  String get settingsShowOnboardingAgain;

  /// No description provided for @settingsShowOnboardingAgainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the first-run welcome screen again.'**
  String get settingsShowOnboardingAgainSubtitle;
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
