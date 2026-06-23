// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Tabata';

  @override
  String get importRoutineTooltip => '루틴 가져오기';

  @override
  String get noRoutines => '저장된 루틴이 없습니다.';

  @override
  String get loadingProfiles => '루틴을 불러오는 중...';

  @override
  String get profileLoadError => '서버에서 루틴을 불러오지 못했습니다.';

  @override
  String get retry => '다시 시도';

  @override
  String get createRoutine => '루틴 만들기';

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
  String estimatedDuration(String duration) {
    return '예상 $duration';
  }

  @override
  String get exerciseListTitle => '운동 목록';

  @override
  String get start => '시작';

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
  String get descriptionOptionalLabel => '설명 (선택)';

  @override
  String get reorderExercisesHint => '길게 눌러 순서 변경';

  @override
  String get addExercisesPrompt => '운동을 추가해 주세요';

  @override
  String get addExercise => '운동 추가';

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
  String get settingsTitle => '설정';

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
  String get voiceCountThree => '삼';

  @override
  String get voiceCountTwo => '이';

  @override
  String get voiceCountOne => '일';

  @override
  String get errorEmptyJson => '빈 데이터입니다.';

  @override
  String get errorInvalidRoutineJson => '루틴 JSON 형식이 아닙니다.';
}
