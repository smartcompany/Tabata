// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '모두의 타바타';

  @override
  String get importRoutineTooltip => '루틴 가져오기';

  @override
  String get uploadRoutineTooltip => '내 루틴 공유';

  @override
  String get uploadRoutineTitle => '내 루틴 공유';

  @override
  String get uploadAdminLoginHint => '관리자 계정으로 로그인하면 서버에 루틴을 올릴 수 있습니다.';

  @override
  String get uploadAdminUsername => '관리자 아이디';

  @override
  String get uploadAdminPassword => '비밀번호';

  @override
  String get uploadAdminLogin => '관리자 로그인';

  @override
  String get uploadLogout => '로그아웃';

  @override
  String get deleteAccountTitle => '회원 탈퇴';

  @override
  String get deleteAccountMessage =>
      '계정과 서버에 업로드한 루틴·프로필·이미지가 삭제됩니다. 기기에 저장된 로컬 루틴은 유지됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteAccountConfirm => '탈퇴';

  @override
  String get deleteAccountSuccess => '회원 탈퇴가 완료되었습니다.';

  @override
  String get deleteAccountFailed => '회원 탈퇴에 실패했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get deleteAccountRecentLoginRequired =>
      '보안을 위해 다시 로그인한 뒤 탈퇴를 시도해 주세요.';

  @override
  String get settingsAccountSection => '계정';

  @override
  String get settingsDeleteAccount => '회원 탈퇴';

  @override
  String get settingsSignOut => '로그아웃';

  @override
  String get uploadSelectRoutine => '업로드할 루틴을 선택하세요';

  @override
  String get uploadNoLocalRoutines => '기기에 저장된 루틴이 없습니다.';

  @override
  String get upload => '업로드';

  @override
  String get uploadUpdate => '갱신';

  @override
  String get uploadConfirmTitle => '서버에 업로드';

  @override
  String uploadConfirmCreate(String title) {
    return '「$title」 루틴을 서버에 새로 추가할까요?';
  }

  @override
  String uploadConfirmUpdate(String title) {
    return '「$title」 루틴을 서버 데이터로 갱신할까요?';
  }

  @override
  String uploadSuccessCreated(String title) {
    return '「$title」 루틴을 서버에 추가했습니다.';
  }

  @override
  String uploadSuccessUpdated(String title) {
    return '「$title」 루틴을 서버에 갱신했습니다.';
  }

  @override
  String get uploadError => '업로드에 실패했습니다.';

  @override
  String get uploadLoginError => '로그인에 실패했습니다.';

  @override
  String get uploadLoadServerIdsError => '서버 루틴 목록을 불러오지 못했습니다.';

  @override
  String get uploadServerRoutineSection => '내가 업로드한 루틴';

  @override
  String get uploadServerRoutineHint => '탭하여 편집합니다. 저장하면 서버에 반영됩니다.';

  @override
  String get uploadLocalRoutineSection => '기기에 있는 루틴';

  @override
  String get uploadLocalRoutineHint => '기기에 저장된 루틴입니다. 업로드해도 기기에서 삭제되지 않습니다.';

  @override
  String get uploadNoAdminRoutines => '아직 업로드한 루틴이 없습니다.';

  @override
  String get uploadEditServerRoutineTitle => '서버 루틴 편집';

  @override
  String get uploadDeleteServerRoutineMessage => '서버에서 이 루틴을 삭제할까요?';

  @override
  String get downloadRoutineTooltip => '다운로드';

  @override
  String routineDownloadSuccess(String title) {
    return '「$title」 루틴을 저장했습니다.';
  }

  @override
  String get routineDownloadError => '다운로드에 실패했습니다.';

  @override
  String routineCountOnly(int count) {
    return '$count개 운동';
  }

  @override
  String get deleteLocalCopyMessage =>
      '기기에서 이 루틴을 삭제할까요? 서버 루틴은 다시 다운로드할 수 있습니다.';

  @override
  String get noRoutines => '저장된 루틴이 없습니다.';

  @override
  String get noMyRoutines => '내 루틴이 없습니다. 새로 만들거나 공유된 루틴을 다운로드하세요.';

  @override
  String get noSharedRoutines => '공유된 루틴이 없습니다.';

  @override
  String get homeTabMyRoutines => '내 루틴';

  @override
  String get homeTabShared => '공유된 루틴';

  @override
  String get homeDownloadCatalogHint => '다운로드하면 내 루틴에 추가됩니다.';

  @override
  String get homeCatalogOfficialSection => '기본 루틴';

  @override
  String get homeCatalogSharedSection => '사용자 루틴';

  @override
  String get searchRoutinesTooltip => '루틴 검색';

  @override
  String get searchRoutinesHint => '제목 또는 설명 검색';

  @override
  String get noSearchResults => '검색 결과가 없습니다.';

  @override
  String routineAddedToMyRoutines(String title) {
    return '「$title」 루틴을 내 루틴에 추가했습니다.';
  }

  @override
  String catalogSavedCount(int count) {
    return '내 루틴에 $count개 저장됨';
  }

  @override
  String get openSavedCopy => '열기';

  @override
  String get loadingProfiles => '루틴을 불러오는 중...';

  @override
  String get profileLoadError => '서버에서 루틴을 불러오지 못했습니다.';

  @override
  String get retry => '다시 시도';

  @override
  String get createRoutine => '루틴 만들기';

  @override
  String get aiRoutineCreateButton => 'AI로 루틴 생성하기';

  @override
  String get aiRoutineCreateTitle => '광고 보고 AI로 루틴 만들기';

  @override
  String get aiRoutineCreatePromptHint =>
      '예)\nhttps://www.youtube.com/watch?v=9bZkp7q19f0\n이 영상 내용으로 운동 루틴을 만들어 줘\n\n또는\n\n요즘 목이 너무 뻐근한데 추천 운동으로 루틴을 만들어 줘';

  @override
  String get aiRoutineCreateSubmit => '광고 보고 루틴 생성하기';

  @override
  String get aiRoutineCreateLoading => 'AI가 루틴을 만들고 있어요...';

  @override
  String get aiRoutineCreateAdLoading => '광고를 불러오는 중...';

  @override
  String get aiRoutineCreatePromptRequired => '요청 내용을 입력해 주세요.';

  @override
  String get aiRoutineCreateAdRequired => '광고 시청 후 이용할 수 있습니다.';

  @override
  String get aiRoutineCreateAdLoadFailed =>
      '광고를 불러오지 못했습니다. 네트워크 연결을 확인하고 잠시 후 다시 시도해 주세요.';

  @override
  String get aiRoutineCreateError => '루틴 생성에 실패했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String routineCountDuration(int count, String duration) {
    return '$count개 운동 · $duration';
  }

  @override
  String get routineNotFound => '루틴을 찾을 수 없습니다.';

  @override
  String get editTooltip => '편집';

  @override
  String get shareTooltip => '공유';

  @override
  String get shareAppTooltip => '앱 공유';

  @override
  String shareAppMessage(String appTitle) {
    return '$appTitle — 운동 루틴 인터벌 타이머 앱을 사용해 보세요.';
  }

  @override
  String get shareSheetKakaoTalk => '카카오톡 공유';

  @override
  String get shareSheetSystemShare => '기본 공유';

  @override
  String shareRoutineFooter(String appTitle) {
    return '$appTitle 앱에서 운동해 보세요';
  }

  @override
  String get shareKakaoLinkButton => '루틴 열기';

  @override
  String get shareKakaoAppLinkButton => '앱 설치하기';

  @override
  String get shareFailed => '공유에 실패했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get sharedRoutineImportTitle => '공유 루틴';

  @override
  String get sharedRoutineImportPrompt => '공유된 루틴을 다운로드 할까요?';

  @override
  String get sharedRoutineImportYes => '예';

  @override
  String sharedRoutineImportMessage(String title) {
    return '「$title」 루틴을 내 루틴에 추가할까요?';
  }

  @override
  String get sharedRoutineImportAdd => '내 루틴에 추가';

  @override
  String get sharedRoutineImportError => '공유 루틴을 불러오지 못했습니다.';

  @override
  String get sharedRoutineNotFound => '공유 링크를 찾을 수 없거나 만료되었습니다.';

  @override
  String catalogAuthor(String author) {
    return '저작자: $author';
  }

  @override
  String get catalogAuthorUnknown => '알 수 없음';

  @override
  String estimatedDuration(String duration) {
    return '예상 $duration';
  }

  @override
  String get exerciseListTitle => '운동 목록';

  @override
  String get start => '시작';

  @override
  String get seeMore => '더보기';

  @override
  String get collapse => '접기';

  @override
  String get startAll => '전체 시작';

  @override
  String get labelPrepare => '준비';

  @override
  String get labelWork => '운동';

  @override
  String get labelRelax => '이완';

  @override
  String get labelReps => '횟수';

  @override
  String get labelSets => '세트';

  @override
  String oneSetDuration(String duration) {
    return '1세트 $duration';
  }

  @override
  String phaseWithDuration(String label, int seconds) {
    return '$label · $seconds초';
  }

  @override
  String phaseWithCountTiming(String label, int count, int seconds) {
    return '$label · $count회 × $seconds초';
  }

  @override
  String get phaseTimingModeDuration => '시간';

  @override
  String get phaseTimingModeCount => '카운트';

  @override
  String get labelPhaseCount => '회수';

  @override
  String get labelSecondsPerRep => '회당 시간';

  @override
  String get tapToSetPhaseCount => '탭하여 회수 설정';

  @override
  String get countOrderAscending => '순서';

  @override
  String get countOrderDescending => '역순';

  @override
  String repCountProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds초';
  }

  @override
  String countReps(int count) {
    return '$count회';
  }

  @override
  String countSets(int count) {
    return '$count세트';
  }

  @override
  String get importRoutineTitle => '루틴 가져오기';

  @override
  String get importRoutineHint => '공유받은 JSON을 붙여넣으세요.';

  @override
  String get importRoutineJsonHint => 'JSON 형식의 루틴 데이터 전체를 붙여넣으세요';

  @override
  String get import => '가져오기';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get back => '뒤로';

  @override
  String get done => '완료';

  @override
  String get confirm => '확인';

  @override
  String get delete => '삭제';

  @override
  String get createRoutineTitle => '루틴 만들기';

  @override
  String get editRoutineTitle => '루틴 편집';

  @override
  String get deleteRoutineTooltip => '루틴 삭제';

  @override
  String get deleteRoutineTitle => '루틴 삭제';

  @override
  String get deleteRoutineMessage => '이 루틴을 삭제할까요?';

  @override
  String get routineNameLabel => '루틴 이름';

  @override
  String get routineNameHint => '예: 회전근개 재활';

  @override
  String get defaultRoutineName => '기본 루틴';

  @override
  String get defaultExerciseName => '기본 운동';

  @override
  String get descriptionOptionalLabel => '설명 (선택)';

  @override
  String get descriptionBlocksEmptyHint =>
      '텍스트, 참고 사진, 영상 링크를 순서대로 추가할 수 있습니다.';

  @override
  String get descriptionAddText => '텍스트';

  @override
  String get descriptionAddImage => '사진';

  @override
  String get descriptionAddVideo => '영상 링크';

  @override
  String get descriptionTextHint => '설명을 입력하세요';

  @override
  String get descriptionVideoUrlHint => 'YouTube 등 영상 URL';

  @override
  String get descriptionVideoUrlInvalid => '올바른 영상 URL을 입력해 주세요.';

  @override
  String get descriptionVideoBlockLabel => '영상 링크';

  @override
  String get descriptionVideoPlay => '탭하여 재생';

  @override
  String get descriptionVideoExternal => '외부 영상 열기';

  @override
  String get descriptionImageLoginRequired => '사진을 추가하려면 로그인이 필요합니다.';

  @override
  String get photoLibraryPermissionRequired =>
      '사진을 추가하려면 사진 라이브러리 접근 권한이 필요합니다.';

  @override
  String get descriptionImageUploadError => '사진 업로드에 실패했습니다.';

  @override
  String get descriptionImageLoadError => '이미지를 불러오지 못했습니다.';

  @override
  String get reorderExercisesHint => '길게 눌러 순서 변경';

  @override
  String get addExercisesPrompt => '운동을 추가해 주세요';

  @override
  String get addExercise => '운동 추가';

  @override
  String get importExercisesButton => '다른 루틴에서 가져오기';

  @override
  String get importExercisesTitle => '운동 가져오기';

  @override
  String get importExercisesChooseRoutine => '루틴을 선택하세요';

  @override
  String get importExercisesNoOtherRoutines => '가져올 수 있는 다른 루틴이 없습니다.';

  @override
  String get importExercisesNoExercisesInRoutine => '이 루틴에는 운동이 없습니다.';

  @override
  String importExercisesAddCount(int count) {
    return '$count개 추가';
  }

  @override
  String importExercisesAddedSnack(int count) {
    return '$count개 운동을 추가했습니다';
  }

  @override
  String get importExercisesSelectAll => '전체 선택';

  @override
  String get importExercisesClearSelection => '선택 해제';

  @override
  String get requireAtLeastOneExercise => '운동을 1개 이상 추가하세요';

  @override
  String get addExerciseTitle => '운동 추가';

  @override
  String get editExerciseTitle => '운동 편집';

  @override
  String get basicInfoSection => '기본 정보';

  @override
  String get exerciseNameLabel => '운동 이름';

  @override
  String get exerciseNameHint => '예: 팽귄 운동';

  @override
  String get exerciseInstructionLabel => '설명 (선택)';

  @override
  String get exerciseInstructionHint => '동작 방법을 적어주세요';

  @override
  String get prepareSection => '준비';

  @override
  String get phasesSection => '동작 순서';

  @override
  String get addWorkPhase => '운동 추가';

  @override
  String get addRelaxPhase => '이완 추가';

  @override
  String get requireAtLeastOnePhase => '동작을 1개 이상 추가하세요';

  @override
  String get reorderPhasesHint => '드래그하여 순서 변경';

  @override
  String get workSection => '운동';

  @override
  String get relaxSection => '이완';

  @override
  String get repeatSection => '반복';

  @override
  String get phaseLabel => '동작 라벨';

  @override
  String get workLabelHint => '예: 팔을 벌리기';

  @override
  String get relaxLabelHint => '예: 팔을 오므리기';

  @override
  String get previewSection => '미리보기';

  @override
  String totalDuration(String duration) {
    return '전체 $duration';
  }

  @override
  String get newExercise => '새 운동';

  @override
  String exerciseListSubtitle(String phases, String repsSets, String oneSet) {
    return '$phases · $repsSets · $oneSet';
  }

  @override
  String repsSetsSummary(int reps, int sets) {
    return '$reps회 × $sets세트';
  }

  @override
  String get validationNameRequired => '이름을 입력하세요';

  @override
  String get validationLabelRequired => '라벨을 입력하세요';

  @override
  String get enterValueTitle => '값 입력';

  @override
  String get dragToAdjustHint => '좌우로 드래그하여 조절 · 탭하면 직접 입력';

  @override
  String get unitSeconds => '초';

  @override
  String get unitMinutes => '분';

  @override
  String get tapToSetDuration => '탭하여 시간 설정';

  @override
  String get tapToSetReps => '탭하여 횟수 설정';

  @override
  String get tapToSetSets => '탭하여 세트 설정';

  @override
  String get unitReps => '회';

  @override
  String get unitSets => '세트';

  @override
  String durationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes분 $seconds초';
  }

  @override
  String durationApproxMinutes(int minutes) {
    return '약 $minutes분';
  }

  @override
  String durationApproxHours(int hours) {
    return '약 $hours시간';
  }

  @override
  String durationApproxHoursMinutes(int hours, int minutes) {
    return '약 $hours시간 $minutes분';
  }

  @override
  String workoutProgress(int current, int total) {
    return '운동 $current/$total';
  }

  @override
  String get phasePrepare => '준비';

  @override
  String get phaseWork => '운동';

  @override
  String get phaseRelax => '이완';

  @override
  String get phaseCompleted => '완료';

  @override
  String get workoutCompletedMessage => '수고하셨습니다';

  @override
  String repSetProgress(int rep, int totalReps, int set, int totalSets) {
    return '$rep/$totalReps회 · $set/$totalSets세트';
  }

  @override
  String get skipPhase => '건너뛰기';

  @override
  String get pause => '일시정지';

  @override
  String get resume => '재개';

  @override
  String get skipExercise => '운동 스킵';

  @override
  String get workoutDone => '완료';

  @override
  String get workoutRemainingReps => '남은 횟수';

  @override
  String get workoutRemainingSets => '남은 세트';

  @override
  String get workoutNext => '다음';

  @override
  String get workoutPrevious => '이전';

  @override
  String get nextPhaseFinish => '종료';

  @override
  String get settingsTitle => '설정';

  @override
  String get workoutSettingsSection => '운동';

  @override
  String get countSecondsWithTtsTitle => '초 카운팅 음성';

  @override
  String get countSecondsWithTtsSubtitle =>
      '카운트 모드에서만 초마다 숫자를 음성으로 안내합니다. 끄면 비프음이 재생됩니다.';

  @override
  String get contentSettingsSection => '콘텐츠';

  @override
  String get autoTranslateContentTitle => '콘텐츠 자동 번역';

  @override
  String get autoTranslateContentSubtitle =>
      '서버에서 불러온 루틴 제목·설명·운동 이름을 앱 언어로 자동 번역해 표시합니다.';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get voiceGuidance => '음성 안내';

  @override
  String get voiceGuidanceSubtitle => '운동 중 단계와 카운트를 읽어 줍니다';

  @override
  String get soundEffects => '효과음';

  @override
  String get soundEffectsSubtitle => '타이머·횟수·세트 변경 시 소리로 알려 줍니다';

  @override
  String get voiceCountThree => '삼';

  @override
  String get voiceCountTwo => '이';

  @override
  String get voiceCountOne => '일';

  @override
  String get errorEmptyJson => '빈 데이터입니다.';

  @override
  String get errorInvalidRoutineJson => '루틴 JSON 형식이 아닙니다.';

  @override
  String get settingsLegalSection => '법적 고지';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get settingsAppDisclosures => '서비스 안내 및 면책';

  @override
  String get privacyProcessingConsentTitle => '이용약관·공유 콘텐츠 규칙 및 개인정보 동의';

  @override
  String get privacyProcessingConsentLead =>
      '루틴 업로드·공유 등 사용자 생성 콘텐츠(UGC) 기능을 이용하시려면 아래를 확인하신 뒤 동의해 주세요.';

  @override
  String get privacyProcessingConsentSectionPrivacy => '개인정보';

  @override
  String get privacyProcessingConsentSectionUgc => '공유 루틴(UGC)';

  @override
  String get privacyProcessingConsentUgcIntro =>
      '다른 이용자에게 공개되는 루틴 업로드·공유에 적용됩니다. YouTube 등 외부 동영상 링크는 공식 embed 방식으로만 재생되며, 영상 파일을 서버에 저장·재배포하지 않습니다.';

  @override
  String get privacyProcessingConsentBullet1 =>
      '수집 항목: 계정 식별자(Firebase UID), 이메일(있는 경우), 닉네임, 업로드한 루틴(제목·설명·운동 구성·이미지 URL·동영상 링크 URL)';

  @override
  String get privacyProcessingConsentBullet2 =>
      '이용 목적: 회원 식별, 루틴 공유·다운로드 제공, 부정 이용 방지 및 서비스 개선';

  @override
  String get privacyProcessingConsentBullet3 =>
      '보관 및 파기: 탈퇴 시 관련 법령에 따른 보관 의무가 없는 한 지체 없이 삭제·처리합니다.';

  @override
  String get privacyProcessingConsentUgcBullet1 =>
      '무관용 원칙: 불법·폭력·성적·혐오·스팸·타인 권리 침해 루틴·이미지·동영상 링크는 허용하지 않습니다.';

  @override
  String get privacyProcessingConsentUgcBullet2 =>
      '위반 시 루틴 삭제, 업로드 제한, 계정 정지 등 조치를 할 수 있습니다.';

  @override
  String get privacyProcessingConsentUgcBullet3 =>
      '부적절한 공유 루틴은 앱 스토어 개발자 연락처로 신고해 주세요.';

  @override
  String get privacyProcessingConsentCheckboxPrivacy => '위 개인정보 수집·이용에 동의합니다.';

  @override
  String get privacyProcessingConsentCheckboxUgc =>
      '위 공유 루틴(UGC) 규칙 및 무관용 정책에 동의합니다.';

  @override
  String get privacyProcessingConsentAgree => '동의하고 계속하기';

  @override
  String get privacyProcessingConsentDecline => '동의하지 않음';

  @override
  String get scheduleWorkoutTooltip => '예약';

  @override
  String get scheduleWorkoutTitle => '운동 예약';

  @override
  String get scheduleWorkoutDate => '날짜';

  @override
  String get scheduleWorkoutTime => '시간';

  @override
  String get scheduleWorkoutConfirm => '예약하기';

  @override
  String get scheduleWorkoutCancelExisting => '예약 취소';

  @override
  String scheduleWorkoutSuccess(String time) {
    return '$time에 알림을 보내드립니다.';
  }

  @override
  String get scheduleWorkoutCancelled => '예약을 취소했습니다.';

  @override
  String get scheduleWorkoutPastTime => '현재 시간 이후로 선택해 주세요.';

  @override
  String get scheduleWorkoutPermissionRequired =>
      '알림 권한이 필요합니다. 설정에서 알림을 허용해 주세요.';

  @override
  String get scheduleWorkoutNotificationTitle => '운동 시간입니다';

  @override
  String scheduleWorkoutNotificationBody(String title) {
    return '$title 루틴을 시작해 보세요.';
  }

  @override
  String scheduleWorkoutActive(String time) {
    return '$time 예약됨';
  }

  @override
  String get scheduleRecurrenceLabel => '반복';

  @override
  String get scheduleRecurrenceOnce => '한 번';

  @override
  String get scheduleRecurrenceDaily => '매일';

  @override
  String get scheduleRecurrenceWeekly => '매주';

  @override
  String get scheduleRecurrenceMonthly => '매월';

  @override
  String get scheduleWorkoutStartDate => '시작 날짜';

  @override
  String get scheduleRecurrenceEndDate => '반복 종료';

  @override
  String get scheduleRecurrenceEndDateNone => '없음 (계속)';

  @override
  String get scheduleRecurrenceEndDateRequired => '반복 종료 날짜를 선택해 주세요.';

  @override
  String get scheduleRecurrenceEndBeforeStart => '종료 날짜는 시작 날짜 이후여야 합니다.';

  @override
  String get scheduleRecurrenceWeeklyHint => '선택한 날짜의 요일마다 반복됩니다.';

  @override
  String get scheduleRecurrenceMonthlyHint => '선택한 날짜(일)마다 반복됩니다.';

  @override
  String scheduleRecurrenceDailySummary(String time) {
    return '매일 $time';
  }

  @override
  String scheduleRecurrenceWeeklySummary(String weekday, String time) {
    return '매주 $weekday $time';
  }

  @override
  String scheduleRecurrenceMonthlySummary(int day, String time) {
    return '매월 $day일 $time';
  }

  @override
  String get onboardingWelcomeTitle => '모두의 타바타에 오신 걸 환영해요';

  @override
  String get onboardingWelcomeSubtitle => '어떻게 시작할까요? 원하는 방법을 골라 주세요.';

  @override
  String get onboardingOptionQuickStartTitle => '바로 운동 시작';

  @override
  String get onboardingOptionQuickStartSubtitle => '추천 루틴을 골라 내 루틴에 추가해요';

  @override
  String get onboardingOptionYoutubeTitle => '유튜브·운동 따라하기';

  @override
  String get onboardingOptionYoutubeSubtitle => '영상이나 운동 이름으로 AI가 루틴을 만들어요';

  @override
  String get onboardingOptionGoalTitle => '목표·부위 맞춤';

  @override
  String get onboardingOptionGoalSubtitle => '목표, 시간, 난이도를 고르면 AI가 루틴을 만들어요';

  @override
  String get onboardingOptionCreateTitle => '직접 만들기';

  @override
  String get onboardingOptionCreateSubtitle => '준비·운동·휴식 구간을 직접 설정해요';

  @override
  String get onboardingSkip => '나중에 할게요';

  @override
  String get onboardingRecommendedTitle => '추천 루틴';

  @override
  String get onboardingRecommendedSubtitle => '추가할 루틴을 선택하세요. 모두 기본 선택되어 있어요.';

  @override
  String get onboardingRecommendedSave => '내 루틴에 추가';

  @override
  String get onboardingRecommendedSelectAtLeastOne => '루틴을 하나 이상 선택해 주세요.';

  @override
  String get onboardingRecommendedDownloadFailed =>
      '루틴을 불러오지 못했습니다. 네트워크를 확인하고 다시 시도해 주세요.';

  @override
  String get onboardingRecommendedLoadError => '추천 루틴 목록을 불러오지 못했습니다.';

  @override
  String get onboardingGoalTitle => '맞춤 루틴';

  @override
  String get onboardingGoalStepGoal => '어떤 목표인가요?';

  @override
  String get onboardingGoalStepDuration => '얼마나 운동할까요?';

  @override
  String get onboardingGoalStepLevel => '난이도는 어느 정도인가요?';

  @override
  String get onboardingGoalNext => '다음';

  @override
  String get onboardingGoalCreate => 'AI로 만들기';

  @override
  String get onboardingGoalOptionWeightLoss => '다이어트';

  @override
  String get onboardingGoalOptionStrength => '근력';

  @override
  String get onboardingGoalOptionFlexibility => '유연성';

  @override
  String get onboardingGoalOptionFullBody => '전신';

  @override
  String get onboardingGoalOptionUpperBody => '상체';

  @override
  String get onboardingGoalOptionLowerBody => '하체';

  @override
  String get onboardingGoalOptionCore => '코어';

  @override
  String get onboardingGoalDuration5 => '5분';

  @override
  String get onboardingGoalDuration10 => '10분';

  @override
  String get onboardingGoalDuration15 => '15분';

  @override
  String get onboardingGoalDuration20 => '20분';

  @override
  String get onboardingGoalLevelBeginner => '초급';

  @override
  String get onboardingGoalLevelIntermediate => '중급';

  @override
  String get onboardingAiYoutubeInitialPrompt =>
      '유튜브 영상 URL이나 운동 이름을 입력해 주세요.\n\n예)\nhttps://www.youtube.com/watch?v=예시\n이 영상 내용으로 타바타 인터벌 운동 루틴을 만들어 줘. 준비·운동·휴식 구간을 나눠서.';

  @override
  String onboardingAiGoalPrompt(String goal, String duration, String level) {
    return '목표: $goal, 시간: $duration분, 난이도: $level에 맞는 타바타 인터벌 운동 루틴을 만들어 줘. 준비·운동·휴식 구간을 나눠서.';
  }

  @override
  String get settingsAppSection => '앱';

  @override
  String get settingsShowOnboardingAgain => '온보딩 다시 보기';

  @override
  String get settingsShowOnboardingAgainSubtitle => '처음 시작 화면을 다시 표시합니다.';
}
