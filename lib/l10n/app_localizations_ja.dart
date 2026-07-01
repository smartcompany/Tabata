// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'みんなのタバタ';

  @override
  String get importRoutineTooltip => 'ルーティンを取り込む';

  @override
  String get uploadRoutineTooltip => 'マイルーティンを共有';

  @override
  String get uploadRoutineTitle => 'マイルーティンを共有';

  @override
  String get uploadAdminLoginHint => '管理者アカウントでログインすると、サーバーにルーティンを公開できます。';

  @override
  String get uploadAdminUsername => '管理者 ID';

  @override
  String get uploadAdminPassword => 'パスワード';

  @override
  String get uploadAdminLogin => '管理者ログイン';

  @override
  String get uploadLogout => 'ログアウト';

  @override
  String get deleteAccountTitle => 'アカウント削除';

  @override
  String get deleteAccountMessage =>
      'アカウントとサーバーにアップロードしたルーティン・プロフィール・画像が削除されます。この端末のローカルルーティンは残ります。元に戻せません。';

  @override
  String get deleteAccountConfirm => '削除する';

  @override
  String get deleteAccountSuccess => 'アカウントを削除しました。';

  @override
  String get deleteAccountFailed => 'アカウントを削除できませんでした。しばらくしてから再度お試しください。';

  @override
  String get deleteAccountRecentLoginRequired =>
      'セキュリティのため、再度ログインしてから削除してください。';

  @override
  String get settingsAccountSection => 'アカウント';

  @override
  String get settingsDeleteAccount => 'アカウント削除';

  @override
  String get settingsSignOut => 'ログアウト';

  @override
  String get uploadSelectRoutine => 'アップロードするルーティンを選んでください';

  @override
  String get uploadNoLocalRoutines => 'この端末に保存されたルーティンがありません。';

  @override
  String get upload => 'アップロード';

  @override
  String get uploadUpdate => '更新';

  @override
  String get uploadConfirmTitle => 'サーバーにアップロード';

  @override
  String uploadConfirmCreate(String title) {
    return '「$title」をサーバーに新規追加しますか？';
  }

  @override
  String uploadConfirmUpdate(String title) {
    return '「$title」をサーバーのデータで更新しますか？';
  }

  @override
  String uploadSuccessCreated(String title) {
    return '「$title」をサーバーに追加しました。';
  }

  @override
  String uploadSuccessUpdated(String title) {
    return '「$title」をサーバーで更新しました。';
  }

  @override
  String get uploadError => 'アップロードに失敗しました。';

  @override
  String get uploadLoginError => 'ログインに失敗しました。';

  @override
  String get uploadLoadServerIdsError => 'サーバーのルーティン一覧を読み込めませんでした。';

  @override
  String get uploadServerRoutineSection => 'アップロード済みルーティン';

  @override
  String get uploadServerRoutineHint => 'タップして編集します。保存するとサーバーに反映されます。';

  @override
  String get uploadLocalRoutineSection => '端末のルーティン';

  @override
  String get uploadLocalRoutineHint => '端末に保存されたルーティンです。アップロードしても端末からは削除されません。';

  @override
  String get uploadNoAdminRoutines => 'まだアップロードしたルーティンがありません。';

  @override
  String get uploadEditServerRoutineTitle => 'サーバールーティンを編集';

  @override
  String get uploadDeleteServerRoutineMessage => 'サーバーからこのルーティンを削除しますか？';

  @override
  String get downloadRoutineTooltip => 'ダウンロード';

  @override
  String routineDownloadSuccess(String title) {
    return '「$title」をこの端末に保存しました。';
  }

  @override
  String get routineDownloadError => 'ダウンロードに失敗しました。';

  @override
  String routineCountOnly(int count) {
    return '$count 種目';
  }

  @override
  String get deleteLocalCopyMessage =>
      'この端末からルーティンを削除しますか？サーバーのルーティンは再ダウンロードできます。';

  @override
  String get noRoutines => '保存されたルーティンがありません。';

  @override
  String get noMyRoutines => 'マイルーティンがありません。新規作成するか、共有ルーティンをダウンロードしてください。';

  @override
  String get noSharedRoutines => '共有されたルーティンがありません。';

  @override
  String get homeTabMyRoutines => 'マイルーティン';

  @override
  String get homeTabShared => '共有ルーティン';

  @override
  String get homeDownloadCatalogHint => 'ダウンロードするとマイルーティンに追加されます。';

  @override
  String get homeCatalogOfficialSection => '基本ルーティン';

  @override
  String get homeCatalogSharedSection => 'ユーザールーティン';

  @override
  String get searchRoutinesTooltip => 'ルーティンを検索';

  @override
  String get searchRoutinesHint => 'タイトルまたは説明で検索';

  @override
  String get noSearchResults => '該当するルーティンがありません。';

  @override
  String routineAddedToMyRoutines(String title) {
    return '「$title」をマイルーティンに追加しました。';
  }

  @override
  String catalogSavedCount(int count) {
    return 'マイルーティンに$count件保存済み';
  }

  @override
  String get openSavedCopy => '開く';

  @override
  String get loadingProfiles => 'ルーティンを読み込み中...';

  @override
  String get profileLoadError => 'サーバーからルーティンを読み込めませんでした。';

  @override
  String get retry => '再試行';

  @override
  String get createRoutine => 'ルーティンを作成';

  @override
  String get aiRoutineCreateButton => 'AIでルーティン作成';

  @override
  String get aiRoutineCreateTitle => '広告視聴後にAIでルーティン作成';

  @override
  String get aiRoutineCreatePromptHint =>
      '例)\nhttps://www.youtube.com/watch?v=9bZkp7q19f0\nこの動画の内容で運動ルーティンを作ってください\n\nまたは\n\n最近首がとても凝っているので、おすすめのストレッチでルーティンを作ってください';

  @override
  String get aiRoutineCreateSubmit => '広告視聴後にルーティン生成';

  @override
  String get aiRoutineCreateLoading => 'AIがルーティンを作成しています...';

  @override
  String get aiRoutineCreatePromptRequired => 'リクエスト内容を入力してください。';

  @override
  String get aiRoutineCreateAdRequired => '広告視聴後にご利用いただけます。';

  @override
  String get aiRoutineCreateError => 'ルーティンの生成に失敗しました。しばらくしてから再度お試しください。';

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
  String get shareSheetKakaoTalk => 'カカオトークで共有';

  @override
  String get shareSheetSystemShare => '共有';

  @override
  String shareRoutineFooter(String appTitle) {
    return '$appTitle アプリで試してみてください';
  }

  @override
  String get shareKakaoLinkButton => 'ルーティンを開く';

  @override
  String get shareFailed => '共有に失敗しました。しばらくしてからもう一度お試しください。';

  @override
  String get sharedRoutineImportTitle => '共有ルーティン';

  @override
  String get sharedRoutineImportPrompt => '共有されたルーティンをダウンロードしますか？';

  @override
  String get sharedRoutineImportYes => 'はい';

  @override
  String sharedRoutineImportMessage(String title) {
    return '「$title」をマイルーティンに追加しますか？';
  }

  @override
  String get sharedRoutineImportAdd => 'マイルーティンに追加';

  @override
  String get sharedRoutineImportError => '共有ルーティンを読み込めませんでした。';

  @override
  String get sharedRoutineNotFound => '共有リンクが見つからないか、期限切れです。';

  @override
  String catalogAuthor(String author) {
    return '作成者: $author';
  }

  @override
  String get catalogAuthorUnknown => '不明';

  @override
  String estimatedDuration(String duration) {
    return '目安 $duration';
  }

  @override
  String get exerciseListTitle => '種目一覧';

  @override
  String get start => '開始';

  @override
  String get seeMore => '詳細を表示';

  @override
  String get collapse => '閉じる';

  @override
  String get startAll => '全体開始';

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
  String phaseWithCountTiming(String label, int count, int seconds) {
    return '$label · $count 回 × $seconds 秒';
  }

  @override
  String get phaseTimingModeDuration => '時間';

  @override
  String get phaseTimingModeCount => 'カウント';

  @override
  String get labelPhaseCount => '回数';

  @override
  String get labelSecondsPerRep => '1 回あたり';

  @override
  String get tapToSetPhaseCount => 'タップして回数を設定';

  @override
  String get countOrderAscending => '順';

  @override
  String get countOrderDescending => '逆';

  @override
  String repCountProgress(int current, int total) {
    return '$current / $total';
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
  String get defaultRoutineName => '基本ルーティン';

  @override
  String get defaultExerciseName => '基本種目';

  @override
  String get descriptionOptionalLabel => '説明（任意）';

  @override
  String get descriptionBlocksEmptyHint => 'テキスト・参考写真・動画リンクを順に追加できます。';

  @override
  String get descriptionAddText => 'テキスト';

  @override
  String get descriptionAddImage => '写真';

  @override
  String get descriptionAddVideo => '動画リンク';

  @override
  String get descriptionTextHint => '説明を入力';

  @override
  String get descriptionVideoUrlHint => 'YouTubeなどの動画URL';

  @override
  String get descriptionVideoUrlInvalid => '有効な動画URLを入力してください。';

  @override
  String get descriptionVideoBlockLabel => '動画リンク';

  @override
  String get descriptionVideoPlay => 'タップして再生';

  @override
  String get descriptionVideoExternal => '外部動画を開く';

  @override
  String get descriptionImageLoginRequired => '写真を追加するにはログインが必要です。';

  @override
  String get descriptionImageUploadError => '写真のアップロードに失敗しました。';

  @override
  String get descriptionImageLoadError => '画像を読み込めませんでした。';

  @override
  String get reorderExercisesHint => '長押しで並べ替え';

  @override
  String get addExercisesPrompt => '種目を追加してください';

  @override
  String get addExercise => '種目を追加';

  @override
  String get importExercisesButton => '他のルーティンから取り込む';

  @override
  String get importExercisesTitle => '種目を取り込む';

  @override
  String get importExercisesChooseRoutine => 'ルーティンを選択';

  @override
  String get importExercisesNoOtherRoutines => '取り込める他のルーティンがありません。';

  @override
  String get importExercisesNoExercisesInRoutine => 'このルーティンには種目がありません。';

  @override
  String importExercisesAddCount(int count) {
    return '$count件を追加';
  }

  @override
  String importExercisesAddedSnack(int count) {
    return '$count件の種目を追加しました';
  }

  @override
  String get importExercisesSelectAll => 'すべて選択';

  @override
  String get importExercisesClearSelection => '選択を解除';

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
  String get tapToSetReps => 'タップして回数を設定';

  @override
  String get tapToSetSets => 'タップしてセットを設定';

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
  String get workoutRemainingReps => '残り回数';

  @override
  String get workoutRemainingSets => '残りセット';

  @override
  String get workoutNext => '次';

  @override
  String get workoutPrevious => '前';

  @override
  String get nextPhaseFinish => '終了';

  @override
  String get settingsTitle => '設定';

  @override
  String get workoutSettingsSection => 'ワークアウト';

  @override
  String get countSecondsWithTtsTitle => '秒カウント音声';

  @override
  String get countSecondsWithTtsSubtitle =>
      'カウントモードでのみ毎秒数字を読み上げます。オフの場合はビープ音が鳴ります。';

  @override
  String get contentSettingsSection => 'コンテンツ';

  @override
  String get autoTranslateContentTitle => 'コンテンツ自動翻訳';

  @override
  String get autoTranslateContentSubtitle =>
      'サーバーから読み込んだルーティンのタイトル・説明・種目名をアプリの言語に自動翻訳して表示します。';

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
  String get soundEffects => '効果音';

  @override
  String get soundEffectsSubtitle => '毎秒のティック音と回数・セット変更時の音';

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

  @override
  String get settingsLegalSection => '法的情報';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsAppDisclosures => 'サービス案内・免責事項';

  @override
  String get privacyProcessingConsentTitle => '利用規約・共有コンテンツとプライバシー';

  @override
  String get privacyProcessingConsentLead =>
      'ルーティンのアップロード・共有（UGC）を利用するには、以下を確認のうえ同意してください。';

  @override
  String get privacyProcessingConsentSectionPrivacy => '個人情報';

  @override
  String get privacyProcessingConsentSectionUgc => '共有ルーティン（UGC）';

  @override
  String get privacyProcessingConsentUgcIntro =>
      '他の利用者に公開するルーティンのアップロードに適用されます。YouTubeなどの外部動画リンクは公式embedのみで再生し、動画ファイルをサーバーに保存・再配布しません。';

  @override
  String get privacyProcessingConsentBullet1 =>
      '収集：Firebase UID、メール（ある場合）、ニックネーム、アップロードしたルーティン（タイトル・説明・種目・画像URL・動画リンクURL）';

  @override
  String get privacyProcessingConsentBullet2 => '目的：本人確認、ルーティン共有、不正利用防止、サービス改善';

  @override
  String get privacyProcessingConsentBullet3 => '保管・削除：退会時に削除（法令で保管が必要な場合を除く）';

  @override
  String get privacyProcessingConsentUgcBullet1 =>
      '違法・暴力・性的・ヘイト・スパム・権利侵害のルーティン・画像・動画リンクは許容しません。';

  @override
  String get privacyProcessingConsentUgcBullet2 =>
      '違反時は削除、アップロード制限、アカウント停止等の措置を行う場合があります。';

  @override
  String get privacyProcessingConsentUgcBullet3 =>
      '不適切な共有ルーティンは App Store の開発者連絡先から報告してください。';

  @override
  String get privacyProcessingConsentCheckboxPrivacy => '上記の個人情報の収集・利用に同意します。';

  @override
  String get privacyProcessingConsentCheckboxUgc =>
      '共有ルーティン（UGC）規則と無容認政策に同意します。';

  @override
  String get privacyProcessingConsentAgree => '同意して続ける';

  @override
  String get privacyProcessingConsentDecline => '同意しない';
}
