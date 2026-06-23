// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Tabata';

  @override
  String get importRoutineTooltip => '导入训练';

  @override
  String get noRoutines => '没有已保存的训练。';

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
  String estimatedDuration(String duration) {
    return '预计 $duration';
  }

  @override
  String get exerciseListTitle => '动作列表';

  @override
  String get start => '开始';

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
  String get descriptionOptionalLabel => '说明（可选）';

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
  String get settingsTitle => '设置';

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
