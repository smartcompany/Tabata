// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '大家的塔巴塔';

  @override
  String get importRoutineTooltip => '导入训练';

  @override
  String get uploadRoutineTooltip => '分享我的训练';

  @override
  String get uploadRoutineTitle => '分享我的训练';

  @override
  String get uploadAdminLoginHint => '使用管理员账号登录后，可将训练发布到服务器。';

  @override
  String get uploadAdminUsername => '管理员账号';

  @override
  String get uploadAdminPassword => '密码';

  @override
  String get uploadAdminLogin => '管理员登录';

  @override
  String get uploadLogout => '退出登录';

  @override
  String get deleteAccountTitle => '注销账户';

  @override
  String get deleteAccountMessage =>
      '将删除您的账户及服务器上的上传训练、个人资料与图片。本机本地训练会保留。此操作无法撤销。';

  @override
  String get deleteAccountConfirm => '注销';

  @override
  String get deleteAccountSuccess => '账户已注销。';

  @override
  String get deleteAccountFailed => '注销失败，请稍后重试。';

  @override
  String get deleteAccountRecentLoginRequired => '为保障安全，请重新登录后再注销。';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsDeleteAccount => '注销账户';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get uploadSelectRoutine => '选择要上传的训练';

  @override
  String get uploadNoLocalRoutines => '本设备没有已保存的训练。';

  @override
  String get upload => '上传';

  @override
  String get uploadUpdate => '更新';

  @override
  String get uploadConfirmTitle => '上传到服务器';

  @override
  String uploadConfirmCreate(String title) {
    return '将「$title」新增到服务器？';
  }

  @override
  String uploadConfirmUpdate(String title) {
    return '用服务器数据更新「$title」？';
  }

  @override
  String uploadSuccessCreated(String title) {
    return '已将「$title」添加到服务器。';
  }

  @override
  String uploadSuccessUpdated(String title) {
    return '已在服务器更新「$title」。';
  }

  @override
  String get uploadError => '上传失败。';

  @override
  String get uploadLoginError => '登录失败。';

  @override
  String get uploadLoadServerIdsError => '无法加载服务器训练列表。';

  @override
  String get uploadServerRoutineSection => '我上传的训练';

  @override
  String get uploadServerRoutineHint => '点击编辑。保存后会更新服务器副本。';

  @override
  String get uploadLocalRoutineSection => '本设备上的训练';

  @override
  String get uploadLocalRoutineHint => '保存在本设备的训练。上传只会同步到服务器，不会从本设备删除。';

  @override
  String get uploadNoAdminRoutines => '还没有上传的训练。';

  @override
  String get uploadEditServerRoutineTitle => '编辑服务器训练';

  @override
  String get uploadDeleteServerRoutineMessage => '要从服务器删除此训练吗？';

  @override
  String get downloadRoutineTooltip => '下载';

  @override
  String routineDownloadSuccess(String title) {
    return '已将「$title」保存到此设备。';
  }

  @override
  String get routineDownloadError => '下载失败。';

  @override
  String routineCountOnly(int count) {
    return '$count 个动作';
  }

  @override
  String get deleteLocalCopyMessage => '要从本设备删除此训练吗？服务器训练可重新下载。';

  @override
  String get noRoutines => '没有已保存的训练。';

  @override
  String get noMyRoutines => '还没有训练。请新建或从共享目录下载。';

  @override
  String get noSharedRoutines => '没有共享的训练。';

  @override
  String get homeTabMyRoutines => '我的训练';

  @override
  String get homeTabShared => '共享训练';

  @override
  String get homeDownloadCatalogHint => '下载后会添加到「我的训练」。';

  @override
  String get homeCatalogOfficialSection => '默认训练';

  @override
  String get homeCatalogSharedSection => '用户训练';

  @override
  String get searchRoutinesTooltip => '搜索训练';

  @override
  String get searchRoutinesHint => '按标题或说明搜索';

  @override
  String get noSearchResults => '没有匹配的训练。';

  @override
  String routineAddedToMyRoutines(String title) {
    return '已将「$title」添加到我的训练。';
  }

  @override
  String catalogSavedCount(int count) {
    return '我的训练中已保存 $count 个';
  }

  @override
  String get openSavedCopy => '打开';

  @override
  String get loadingProfiles => '正在加载训练...';

  @override
  String get profileLoadError => '无法从服务器加载训练。';

  @override
  String get retry => '重试';

  @override
  String get createRoutine => '创建训练';

  @override
  String get aiRoutineCreateButton => 'AI 创建训练';

  @override
  String get aiRoutineCreateTitle => '观看广告后用 AI 创建训练';

  @override
  String get aiRoutineCreatePromptHint =>
      '示例)\nhttps://www.youtube.com/watch?v=9bZkp7q19f0\n请根据这个视频内容创建运动训练\n\n或者\n\n最近脖子特别酸，请用推荐的拉伸动作帮我制定一套训练';

  @override
  String get aiRoutineCreateSubmit => '观看广告后生成训练';

  @override
  String get aiRoutineCreateLoading => 'AI 正在创建训练...';

  @override
  String get aiRoutineCreateLoadingStage1 => '正在阅读你的请求...';

  @override
  String get aiRoutineCreateLoadingStage2 => '正在挑选合适的动作...';

  @override
  String get aiRoutineCreateLoadingStage3 => '正在调整时间与次数...';

  @override
  String get aiRoutineCreateLoadingStage4 => '正在整理组数与顺序...';

  @override
  String get aiRoutineCreateLoadingStage5 => '正在做最后润色...';

  @override
  String get aiRoutineCreateLoadingFooter => '即将完成，请稍候。';

  @override
  String get aiRoutineCreateAdLoading => '正在加载广告...';

  @override
  String get aiRoutineCreatePromptRequired => '请输入请求内容。';

  @override
  String get aiRoutineCreateAdRequired => '观看广告后可继续使用。';

  @override
  String get aiRoutineCreateAdLoadFailed => '无法加载广告。请检查网络连接后稍后再试。';

  @override
  String get aiRoutineCreateError => '训练生成失败，请稍后重试。';

  @override
  String routineCountDuration(int count, String duration) {
    return '$count 个动作 · $duration';
  }

  @override
  String get routineNotFound => '未找到训练。';

  @override
  String get editTooltip => '编辑';

  @override
  String get shareTooltip => '分享训练';

  @override
  String get shareAppTooltip => '分享应用';

  @override
  String shareAppMessage(String appTitle) {
    return '试试 $appTitle — 运动 routine 间歇计时器应用。';
  }

  @override
  String get shareSheetKakaoTalk => '分享到 KakaoTalk';

  @override
  String get shareSheetSystemShare => '系统分享';

  @override
  String shareRoutineFooter(String appTitle) {
    return '在 $appTitle 应用中试试这个训练';
  }

  @override
  String get shareKakaoLinkButton => '打开训练';

  @override
  String get shareKakaoAppLinkButton => '安装应用';

  @override
  String get shareFailed => '分享失败，请稍后再试。';

  @override
  String get sharedRoutineImportTitle => '共享训练';

  @override
  String get sharedRoutineImportPrompt => '要下载这条共享训练吗？';

  @override
  String get sharedRoutineImportYes => '是';

  @override
  String sharedRoutineImportMessage(String title) {
    return '将「$title」添加到我的训练吗？';
  }

  @override
  String get sharedRoutineImportAdd => '添加到我的训练';

  @override
  String get sharedRoutineImportError => '无法加载共享训练。';

  @override
  String get sharedRoutineNotFound => '找不到该分享链接或已失效。';

  @override
  String catalogAuthor(String author) {
    return '作者：$author';
  }

  @override
  String get catalogAuthorUnknown => '未知';

  @override
  String estimatedDuration(String duration) {
    return '预计 $duration';
  }

  @override
  String get exerciseListTitle => '动作列表';

  @override
  String get start => '开始';

  @override
  String get seeMore => '查看更多';

  @override
  String get collapse => '收起';

  @override
  String get startAll => '全部开始';

  @override
  String get labelPrepare => '准备';

  @override
  String get labelWork => '运动';

  @override
  String get labelRelax => '放松';

  @override
  String get labelReps => '次数';

  @override
  String get labelSets => '组数';

  @override
  String oneSetDuration(String duration) {
    return '1 组 $duration';
  }

  @override
  String phaseWithDuration(String label, int seconds) {
    return '$label · $seconds 秒';
  }

  @override
  String phaseWithCountTiming(String label, int count, int seconds) {
    return '$label · $count 次 × $seconds 秒';
  }

  @override
  String get phaseTimingModeDuration => '时间';

  @override
  String get phaseTimingModeCount => '计数';

  @override
  String get labelPhaseCount => '次数';

  @override
  String get labelSecondsPerRep => '每次';

  @override
  String get tapToSetPhaseCount => '点击设置次数';

  @override
  String get countOrderAscending => '正序';

  @override
  String get countOrderDescending => '倒序';

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
    return '$count 次';
  }

  @override
  String countSets(int count) {
    return '$count 组';
  }

  @override
  String get importRoutineTitle => '导入训练';

  @override
  String get importRoutineHint => '请粘贴分享的 JSON。';

  @override
  String get importRoutineJsonHint => '粘贴完整的训练 JSON 数据';

  @override
  String get import => '导入';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get back => '返回';

  @override
  String get done => '完成';

  @override
  String get confirm => '确认';

  @override
  String get delete => '删除';

  @override
  String get createRoutineTitle => '创建训练';

  @override
  String get editRoutineTitle => '编辑训练';

  @override
  String get deleteRoutineTooltip => '删除训练';

  @override
  String get deleteRoutineTitle => '删除训练';

  @override
  String get deleteRoutineMessage => '要删除此训练吗？';

  @override
  String get routineNameLabel => '训练名称';

  @override
  String get routineNameHint => '例如：旋转袖康复';

  @override
  String get defaultRoutineName => '默认训练计划';

  @override
  String get defaultExerciseName => '默认动作';

  @override
  String get descriptionOptionalLabel => '说明（可选）';

  @override
  String get descriptionBlocksEmptyHint => '可按顺序添加文字、参考图片和视频链接。';

  @override
  String get descriptionAddText => '文字';

  @override
  String get descriptionAddImage => '图片';

  @override
  String get descriptionAddVideo => '视频链接';

  @override
  String get descriptionTextHint => '输入说明';

  @override
  String get descriptionVideoUrlHint => 'YouTube 等视频 URL';

  @override
  String get descriptionVideoUrlInvalid => '请输入有效的视频 URL。';

  @override
  String get descriptionVideoBlockLabel => '视频链接';

  @override
  String get descriptionVideoPlay => '点击播放';

  @override
  String get descriptionVideoExternal => '打开外部视频';

  @override
  String get descriptionImageLoginRequired => '添加图片需要先登录。';

  @override
  String get photoLibraryPermissionRequired => '添加图片需要照片图库访问权限。';

  @override
  String get descriptionImageUploadError => '图片上传失败。';

  @override
  String get descriptionImageLoadError => '无法加载图片。';

  @override
  String get reorderExercisesHint => '长按可调整顺序';

  @override
  String get addExercisesPrompt => '请添加动作';

  @override
  String get addExercise => '添加动作';

  @override
  String get importExercisesButton => '从其他套路导入';

  @override
  String get importExercisesTitle => '导入动作';

  @override
  String get importExercisesChooseRoutine => '选择套路';

  @override
  String get importExercisesNoOtherRoutines => '没有其他可导入的套路。';

  @override
  String get importExercisesNoExercisesInRoutine => '该套路没有动作。';

  @override
  String importExercisesAddCount(int count) {
    return '添加 $count 个';
  }

  @override
  String importExercisesAddedSnack(int count) {
    return '已添加 $count 个动作';
  }

  @override
  String get importExercisesSelectAll => '全选';

  @override
  String get importExercisesClearSelection => '取消选择';

  @override
  String get requireAtLeastOneExercise => '请至少添加一个动作';

  @override
  String get addExerciseTitle => '添加动作';

  @override
  String get editExerciseTitle => '编辑动作';

  @override
  String get basicInfoSection => '基本信息';

  @override
  String get exerciseNameLabel => '动作名称';

  @override
  String get exerciseNameHint => '例如：企鹅运动';

  @override
  String get exerciseInstructionLabel => '说明（可选）';

  @override
  String get exerciseInstructionHint => '请描述动作要领';

  @override
  String get prepareSection => '准备';

  @override
  String get phasesSection => '动作顺序';

  @override
  String get addWorkPhase => '添加运动';

  @override
  String get addRelaxPhase => '添加放松';

  @override
  String get requireAtLeastOnePhase => '请至少添加一个阶段';

  @override
  String get reorderPhasesHint => '拖动以调整顺序';

  @override
  String get workSection => '运动';

  @override
  String get relaxSection => '放松';

  @override
  String get repeatSection => '重复';

  @override
  String get phaseLabel => '阶段标签';

  @override
  String get workLabelHint => '例如：张开手臂';

  @override
  String get relaxLabelHint => '例如：合拢手臂';

  @override
  String get previewSection => '预览';

  @override
  String totalDuration(String duration) {
    return '总计 $duration';
  }

  @override
  String get newExercise => '新动作';

  @override
  String exerciseListSubtitle(String phases, String repsSets, String oneSet) {
    return '$phases · $repsSets · $oneSet';
  }

  @override
  String repsSetsSummary(int reps, int sets) {
    return '$reps 次 × $sets 组';
  }

  @override
  String get validationNameRequired => '请输入名称';

  @override
  String get validationLabelRequired => '请输入标签';

  @override
  String get enterValueTitle => '输入数值';

  @override
  String get dragToAdjustHint => '左右拖动调节 · 点击可输入';

  @override
  String get unitSeconds => '秒';

  @override
  String get unitMinutes => '分';

  @override
  String get tapToSetDuration => '点击设置时间';

  @override
  String get tapToSetReps => '点击设置次数';

  @override
  String get tapToSetSets => '点击设置组数';

  @override
  String get unitReps => '次';

  @override
  String get unitSets => '组';

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
    return '约 $minutes 分';
  }

  @override
  String durationApproxHours(int hours) {
    return '约 $hours 小时';
  }

  @override
  String durationApproxHoursMinutes(int hours, int minutes) {
    return '约 $hours 小时 $minutes 分';
  }

  @override
  String workoutProgress(int current, int total) {
    return '动作 $current/$total';
  }

  @override
  String get phasePrepare => '准备';

  @override
  String get phaseWork => '运动';

  @override
  String get phaseRelax => '放松';

  @override
  String get phaseCompleted => '完成';

  @override
  String get workoutCompletedMessage => '辛苦了';

  @override
  String repSetProgress(int rep, int totalReps, int set, int totalSets) {
    return '$rep/$totalReps 次 · $set/$totalSets 组';
  }

  @override
  String get skipPhase => '跳过';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get skipExercise => '跳过动作';

  @override
  String get workoutDone => '完成';

  @override
  String get workoutRemainingReps => '剩余次数';

  @override
  String get workoutRemainingSets => '剩余组数';

  @override
  String get workoutNext => '下一个';

  @override
  String get workoutPrevious => '上一个';

  @override
  String get nextPhaseFinish => '结束';

  @override
  String get settingsTitle => '设置';

  @override
  String get workoutSettingsSection => '训练';

  @override
  String get countSecondsWithTtsTitle => '秒数语音计数';

  @override
  String get countSecondsWithTtsSubtitle => '仅在计数模式下每秒播报数字。关闭后改为播放提示音。';

  @override
  String get contentSettingsSection => '内容';

  @override
  String get autoTranslateContentTitle => '内容自动翻译';

  @override
  String get autoTranslateContentSubtitle => '将服务器加载的训练标题、说明和动作名称自动翻译为应用语言后显示。';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get voiceGuidance => '语音引导';

  @override
  String get voiceGuidanceSubtitle => '训练时播报阶段与倒计时';

  @override
  String get soundEffects => '音效';

  @override
  String get soundEffectsSubtitle => '每秒滴答声，以及次数、组数变化提示音';

  @override
  String get voiceCountThree => '三';

  @override
  String get voiceCountTwo => '二';

  @override
  String get voiceCountOne => '一';

  @override
  String get errorEmptyJson => '数据为空。';

  @override
  String get errorInvalidRoutineJson => '训练 JSON 格式无效。';

  @override
  String get settingsLegalSection => '法律信息';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsAppDisclosures => '服务说明与免责声明';

  @override
  String get privacyProcessingConsentTitle => '条款、共享内容与隐私';

  @override
  String get privacyProcessingConsentLead => '使用上传或共享训练（用户生成内容）前，请阅读并同意以下内容。';

  @override
  String get privacyProcessingConsentSectionPrivacy => '个人信息';

  @override
  String get privacyProcessingConsentSectionUgc => '共享训练（UGC）';

  @override
  String get privacyProcessingConsentUgcIntro =>
      '适用于向其他用户公开的上传训练。YouTube 等外部视频链接仅通过官方 embed 播放，不在服务器存储或再分发视频文件。';

  @override
  String get privacyProcessingConsentBullet1 =>
      '收集：Firebase UID、邮箱（如有）、昵称、上传的训练（标题、说明、动作、图片 URL、视频链接 URL）。';

  @override
  String get privacyProcessingConsentBullet2 => '用途：账户识别、训练共享、防止滥用、改进服务。';

  @override
  String get privacyProcessingConsentBullet3 => '保存与删除：注销账户后删除，法律另有规定的除外。';

  @override
  String get privacyProcessingConsentUgcBullet1 =>
      '对违法、暴力、色情、仇恨、垃圾信息或侵权的训练、图片、视频链接零容忍。';

  @override
  String get privacyProcessingConsentUgcBullet2 => '违规可删除内容、限制上传或暂停账户。';

  @override
  String get privacyProcessingConsentUgcBullet3 => '可通过应用商店开发者联系方式举报不当共享训练。';

  @override
  String get privacyProcessingConsentCheckboxPrivacy => '我同意上述个人信息的收集与使用。';

  @override
  String get privacyProcessingConsentCheckboxUgc => '我同意共享训练（UGC）规则及零容忍政策。';

  @override
  String get privacyProcessingConsentAgree => '同意并继续';

  @override
  String get privacyProcessingConsentDecline => '不同意';

  @override
  String get scheduleWorkoutTooltip => '预约锻炼';

  @override
  String get scheduleWorkoutTitle => '预约锻炼';

  @override
  String get scheduleWorkoutDate => '日期';

  @override
  String get scheduleWorkoutTime => '时间';

  @override
  String get scheduleWorkoutConfirm => '预约';

  @override
  String get scheduleWorkoutCancelExisting => '取消预约';

  @override
  String scheduleWorkoutSuccess(String time) {
    return '将在 $time 提醒您。';
  }

  @override
  String get scheduleWorkoutCancelled => '已取消预约。';

  @override
  String get scheduleWorkoutPastTime => '请选择当前时间之后的时间。';

  @override
  String get scheduleWorkoutPermissionRequired => '需要通知权限。请在设置中允许通知。';

  @override
  String get scheduleWorkoutNotificationTitle => '锻炼时间到了';

  @override
  String scheduleWorkoutNotificationBody(String title) {
    return '开始 $title 训练吧。';
  }

  @override
  String scheduleWorkoutActive(String time) {
    return '已预约 $time';
  }

  @override
  String get scheduleRecurrenceLabel => '重复';

  @override
  String get scheduleRecurrenceOnce => '一次';

  @override
  String get scheduleRecurrenceDaily => '每天';

  @override
  String get scheduleRecurrenceWeekly => '每周';

  @override
  String get scheduleRecurrenceMonthly => '每月';

  @override
  String get scheduleWorkoutStartDate => '开始日期';

  @override
  String get scheduleRecurrenceEndDate => '结束重复';

  @override
  String get scheduleRecurrenceEndDateNone => '无（持续）';

  @override
  String get scheduleRecurrenceEndDateRequired => '请选择重复结束日期。';

  @override
  String get scheduleRecurrenceEndBeforeStart => '结束日期必须在开始日期之后。';

  @override
  String get scheduleRecurrenceWeeklyHint => '按所选日期的星期几重复。';

  @override
  String get scheduleRecurrenceMonthlyHint => '按每月相同日期重复。';

  @override
  String scheduleRecurrenceDailySummary(String time) {
    return '每天 $time';
  }

  @override
  String scheduleRecurrenceWeeklySummary(String weekday, String time) {
    return '每周$weekday $time';
  }

  @override
  String scheduleRecurrenceMonthlySummary(int day, String time) {
    return '每月$day日 $time';
  }

  @override
  String get onboardingWelcomeTitle => '欢迎使用「大家的 Tabata」';

  @override
  String get onboardingWelcomeSubtitle => '你想怎么开始？';

  @override
  String get onboardingOptionQuickStartTitle => '马上开始运动';

  @override
  String get onboardingOptionQuickStartSubtitle => '选择推荐训练并添加到「我的训练」';

  @override
  String get onboardingOptionYoutubeTitle => '跟着 YouTube/运动做';

  @override
  String get onboardingOptionYoutubeSubtitle => 'AI 根据视频或运动名称生成训练';

  @override
  String get onboardingOptionGoalTitle => '按目标/部位定制';

  @override
  String get onboardingOptionGoalSubtitle => '选择目标、时长和难度，AI 生成训练';

  @override
  String get onboardingOptionCreateTitle => '自己创建';

  @override
  String get onboardingOptionCreateSubtitle => '自行设置准备、运动和放松阶段';

  @override
  String get onboardingSkip => '稍后再说';

  @override
  String get onboardingRecommendedTitle => '推荐训练';

  @override
  String get onboardingRecommendedSubtitle => '选择要添加的训练，默认全选。';

  @override
  String get onboardingRecommendedSave => '添加到我的训练';

  @override
  String get onboardingRecommendedSelectAtLeastOne => '请至少选择一项训练。';

  @override
  String get onboardingRecommendedDownloadFailed => '无法下载训练，请检查网络后重试。';

  @override
  String get onboardingRecommendedLoadError => '无法加载推荐训练列表。';

  @override
  String get onboardingGoalTitle => '定制训练';

  @override
  String get onboardingGoalStepGoal => '你的目标是什么？';

  @override
  String get onboardingGoalStepDuration => '运动多长时间？';

  @override
  String get onboardingGoalStepLevel => '难度如何？';

  @override
  String get onboardingGoalNext => '下一步';

  @override
  String get onboardingGoalCreate => '用 AI 创建';

  @override
  String get onboardingGoalOptionWeightLoss => '减脂';

  @override
  String get onboardingGoalOptionStrength => '力量';

  @override
  String get onboardingGoalOptionFlexibility => '柔韧';

  @override
  String get onboardingGoalOptionFullBody => '全身';

  @override
  String get onboardingGoalOptionUpperBody => '上肢';

  @override
  String get onboardingGoalOptionLowerBody => '下肢';

  @override
  String get onboardingGoalOptionCore => '核心';

  @override
  String get onboardingGoalDuration5 => '5 分钟';

  @override
  String get onboardingGoalDuration10 => '10 分钟';

  @override
  String get onboardingGoalDuration15 => '15 分钟';

  @override
  String get onboardingGoalDuration20 => '20 分钟';

  @override
  String get onboardingGoalLevelBeginner => '初级';

  @override
  String get onboardingGoalLevelIntermediate => '中级';

  @override
  String get onboardingAiYoutubeInitialPrompt =>
      '请输入 YouTube 链接或运动名称。\n\n示例：\nhttps://www.youtube.com/watch?v=example\n请根据此视频内容创建 Tabata 间歇训练，分为准备、运动和休息阶段。';

  @override
  String onboardingAiGoalPrompt(String goal, String duration, String level) {
    return '请创建 Tabata 间歇训练：目标 $goal，时长 $duration 分钟，难度 $level。分为准备、运动和休息阶段。';
  }

  @override
  String get settingsAppSection => '应用';

  @override
  String get settingsShowOnboardingAgain => '再次查看引导';

  @override
  String get settingsShowOnboardingAgainSubtitle => '再次显示首次启动欢迎页。';

  @override
  String get settingsRateApp => '评价应用';

  @override
  String get healthAppleHealthLabel => '记录到 Apple 健康';

  @override
  String get healthAppleHealthInfoTitle => 'Apple 健康';

  @override
  String get healthActivityTypeSection => 'Apple 健康';

  @override
  String get healthActivityTypeDetail =>
      '设置后，完成此训练会将 workout 保存到 Apple“健康”App。选择“不保存到健康”则跳过。需在应用设置中开启“记录到 Apple 健康”。';

  @override
  String get healthActivityTypeNone => '不保存到健康';

  @override
  String get healthActivityTypeFunctionalStrength => '功能性力量训练';

  @override
  String get healthActivityTypeFlexibility => '柔韧性训练';

  @override
  String get healthActivityTypeHiit => '高强度间歇训练 (HIIT)';

  @override
  String get healthActivityTypeTraditionalStrength => '传统力量训练';

  @override
  String get healthActivityTypeOther => '其他';

  @override
  String get healthSaveToAppleHealthTitle => '记录到 Apple 健康';

  @override
  String get healthSaveToAppleHealthDetail =>
      '若训练已设置健康 workout 类型，完成时会保存到 Apple“健康”App。可在此开关；首次开启会显示 Apple 系统权限窗口。';

  @override
  String healthRoutineWillSaveDetail(String type) {
    return '完成此训练后将以$type保存到 Apple“健康”App。需在应用设置中开启“记录到 Apple 健康”。';
  }

  @override
  String healthWorkoutSavedSnack(String type) {
    return '已以$type保存到“健康”App。';
  }

  @override
  String get healthWorkoutSaveFailedSnack =>
      '未能保存到“健康”App。请确认应用设置中已开启“记录到 Apple 健康”，并已授予权限。';

  @override
  String get healthPermissionRequiredSnack => '需要健康权限。请在 设置 > 健康 > 数据访问 中允许。';

  @override
  String get healthFirstWorkoutPromptTitle => '保存 workout 到 Apple 健康？';

  @override
  String get healthFirstWorkoutPromptBody =>
      '若训练已设置健康 workout 类型，完成后可保存到“健康”App。选择“启用”会打开 Apple 系统权限窗口。之后可在应用设置中更改。';

  @override
  String get healthFirstWorkoutPromptEnable => '启用';

  @override
  String get healthFirstWorkoutPromptNotNow => '稍后';

  @override
  String get healthConnectLabel => '保存到 Health Connect';

  @override
  String get healthConnectInfoTitle => 'Health Connect';

  @override
  String get healthConnectSaveDetail =>
      '若训练已设置运动类型，完成时会保存到 Google Health Connect。需安装 Health Connect 应用。可在此开关；首次开启会显示权限界面。';

  @override
  String get healthConnectActivityTypeDetail =>
      '设置后，完成此训练会保存到 Health Connect。选择“不保存到 Health Connect”则跳过。需在应用设置中开启“保存到 Health Connect”。';

  @override
  String get healthConnectActivityTypeNone => '不保存到 Health Connect';

  @override
  String get healthConnectReadyStatus => '可使用 Health Connect';

  @override
  String get healthConnectUnavailableStatus => '需要安装或更新 Health Connect 应用';

  @override
  String healthConnectRoutineWillSaveDetail(String type) {
    return '完成此训练后将以$type保存到 Health Connect。需在应用设置中开启“保存到 Health Connect”。';
  }

  @override
  String healthConnectWorkoutSavedSnack(String type) {
    return '已以$type保存到 Health Connect。';
  }

  @override
  String get healthConnectWorkoutSaveFailedSnack =>
      '未能保存到 Health Connect。请确认应用设置中已开启“保存到 Health Connect”，并在 Health Connect 应用 > 应用权限中允许写入运动数据。';

  @override
  String get healthConnectPermissionRequiredSnack =>
      '需要 Health Connect 权限。请在 Health Connect 应用中允许本应用写入运动(EXERCISE)数据。';

  @override
  String get healthConnectFirstWorkoutPromptTitle => '保存到 Health Connect？';

  @override
  String get healthConnectFirstWorkoutPromptBody =>
      '若训练已设置运动类型，完成后可保存到 Health Connect。选择“启用”会打开权限界面。可能需要先安装 Health Connect 应用。';

  @override
  String get healthConnectInstallPromptTitle => '需要安装 Health Connect';

  @override
  String get healthConnectInstallPromptBody =>
      '此设备未安装 Health Connect。请从 Play Store 安装后重试。';

  @override
  String get healthConnectInstallPromptInstall => '安装';

  @override
  String get workoutHistoryTitle => '训练记录';

  @override
  String get workoutHistoryYearLabel => '年';

  @override
  String get workoutHistoryMonthLabel => '月';

  @override
  String workoutHistoryMonthWorkouts(int count) {
    return '训练 $count 次';
  }

  @override
  String workoutHistoryMonthDuration(String duration) {
    return '共 $duration';
  }

  @override
  String get workoutHistoryChartTitle => '每日训练时长（分钟）';

  @override
  String get workoutHistoryCalendarTitle => '日历';

  @override
  String workoutHistoryDayTitle(String date) {
    return '$date 的训练';
  }

  @override
  String get workoutHistoryEmptyDay => '这一天没有训练记录。';

  @override
  String workoutHistorySessionSubtitle(
    String time,
    String duration,
    int count,
  ) {
    return '$time · $duration · $count 个动作';
  }
}
