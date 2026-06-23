// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Tabata';

  @override
  String get importRoutineTooltip => 'ルーティンを取り込む';

  @override
  String get noRoutines => '保存されたルーティンがありません。';

  @override
  String get createRoutine => 'ルーティンを作成';

  @override
  String routineCountDuration(int count, String duration) {
    return '$count 種目 · $duration';
  }

  @override
  String get routineNotFound => 'ルーティンが見つかりません。';

  @override
  String get editTooltip => '編集';

  @override
  String get shareTooltip => '共有';

  @override
  String estimatedDuration(String duration) {
    return '目安 $duration';
  }

  @override
  String get exerciseListTitle => '種目一覧';

  @override
  String get start => '開始';

  @override
  String get labelPrepare => '準備';

  @override
  String get labelWork => '運動';

  @override
  String get labelRelax => '休息';

  @override
  String get labelReps => '回数';

  @override
  String get labelSets => 'セット';

  @override
  String oneSetDuration(String duration) {
    return '1 セット $duration';
  }

  @override
  String phaseWithDuration(String label, int seconds) {
    return '$label · $seconds 秒';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds 秒';
  }

  @override
  String countReps(int count) {
    return '$count 回';
  }

  @override
  String countSets(int count) {
    return '$count セット';
  }

  @override
  String get importRoutineTitle => 'ルーティンを取り込む';

  @override
  String get importRoutineHint => '共有された JSON を貼り付けてください。';

  @override
  String get importRoutineJsonHint => 'ルーティンの JSON 全体を貼り付けてください';

  @override
  String get import => '取り込む';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get back => '戻る';

  @override
  String get done => '完了';

  @override
  String get confirm => '確認';

  @override
  String get delete => '削除';

  @override
  String get createRoutineTitle => 'ルーティンを作成';

  @override
  String get editRoutineTitle => 'ルーティンを編集';

  @override
  String get deleteRoutineTooltip => 'ルーティンを削除';

  @override
  String get deleteRoutineTitle => 'ルーティンを削除';

  @override
  String get deleteRoutineMessage => 'このルーティンを削除しますか？';

  @override
  String get routineNameLabel => 'ルーティン名';

  @override
  String get routineNameHint => '例：回旋筋腱板リハビリ';

  @override
  String get descriptionOptionalLabel => '説明（任意）';

  @override
  String get reorderExercisesHint => '長押しで並べ替え';

  @override
  String get addExercisesPrompt => '種目を追加してください';

  @override
  String get addExercise => '種目を追加';

  @override
  String get requireAtLeastOneExercise => '種目を 1 つ以上追加してください';

  @override
  String get addExerciseTitle => '種目を追加';

  @override
  String get editExerciseTitle => '種目を編集';

  @override
  String get basicInfoSection => '基本情報';

  @override
  String get exerciseNameLabel => '種目名';

  @override
  String get exerciseNameHint => '例：ペンギン運動';

  @override
  String get exerciseInstructionLabel => '説明（任意）';

  @override
  String get exerciseInstructionHint => '動作のやり方を記入してください';

  @override
  String get prepareSection => '準備';

  @override
  String get phasesSection => 'フェーズ順';

  @override
  String get addWorkPhase => '運動を追加';

  @override
  String get addRelaxPhase => '休息を追加';

  @override
  String get requireAtLeastOnePhase => 'フェーズを 1 つ以上追加してください';

  @override
  String get reorderPhasesHint => 'ドラッグして並べ替え';

  @override
  String get workSection => '運動';

  @override
  String get relaxSection => '休息';

  @override
  String get repeatSection => '繰り返し';

  @override
  String get phaseLabel => 'フェーズラベル';

  @override
  String get workLabelHint => '例：腕を広げる';

  @override
  String get relaxLabelHint => '例：腕を閉じる';

  @override
  String get previewSection => 'プレビュー';

  @override
  String totalDuration(String duration) {
    return '合計 $duration';
  }

  @override
  String get newExercise => '新しい種目';

  @override
  String exerciseListSubtitle(String phases, String repsSets, String oneSet) {
    return '$phases · $repsSets · $oneSet';
  }

  @override
  String repsSetsSummary(int reps, int sets) {
    return '$reps 回 × $sets セット';
  }

  @override
  String get validationNameRequired => '名前を入力してください';

  @override
  String get validationLabelRequired => 'ラベルを入力してください';

  @override
  String get enterValueTitle => '値を入力';

  @override
  String get dragToAdjustHint => '左右にドラッグして調整 · タップで入力';

  @override
  String get unitSeconds => '秒';

  @override
  String get unitMinutes => '分';

  @override
  String get tapToSetDuration => 'タップして時間を設定';

  @override
  String get unitReps => '回';

  @override
  String get unitSets => 'セット';

  @override
  String durationMinutes(int minutes) {
    return '$minutes 分';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes 分 $seconds 秒';
  }

  @override
  String durationApproxMinutes(int minutes) {
    return '約 $minutes 分';
  }

  @override
  String durationApproxHours(int hours) {
    return '約 $hours 時間';
  }

  @override
  String durationApproxHoursMinutes(int hours, int minutes) {
    return '約 $hours 時間 $minutes 分';
  }

  @override
  String workoutProgress(int current, int total) {
    return '種目 $current/$total';
  }

  @override
  String get phasePrepare => '準備';

  @override
  String get phaseWork => '運動';

  @override
  String get phaseRelax => '休息';

  @override
  String get phaseCompleted => '完了';

  @override
  String get workoutCompletedMessage => 'お疲れさまでした';

  @override
  String repSetProgress(int rep, int totalReps, int set, int totalSets) {
    return '$rep/$totalReps 回 · $set/$totalSets セット';
  }

  @override
  String get skipPhase => 'スキップ';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get skipExercise => '種目をスキップ';

  @override
  String get workoutDone => '完了';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => 'システム設定に従う';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get voiceGuidance => '音声ガイド';

  @override
  String get voiceGuidanceSubtitle => 'ワークアウト中にフェーズとカウントを読み上げます';

  @override
  String get voiceCountThree => 'さん';

  @override
  String get voiceCountTwo => 'に';

  @override
  String get voiceCountOne => 'いち';

  @override
  String get errorEmptyJson => 'データが空です。';

  @override
  String get errorInvalidRoutineJson => 'ルーティン JSON の形式が正しくありません。';
}
