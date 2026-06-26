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
  String get uploadRoutineTooltip => '上传训练';

  @override
  String get uploadRoutineTitle => '上传训练';

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
  String get uploadLocalRoutineHint => '尚未上传到服务器的本地训练。上传后会添加到服务器。';

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
  String get homeCatalogSharedSection => '共享训练';

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
  String routineCountDuration(int count, String duration) {
    return '$count 个动作 · $duration';
  }

  @override
  String get routineNotFound => '未找到训练。';

  @override
  String get editTooltip => '编辑';

  @override
  String get shareTooltip => '分享';

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
}
