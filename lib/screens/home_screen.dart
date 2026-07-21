import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../data/workout_history_repository.dart';
import '../models/profile_summary.dart';
import '../models/routine.dart';
import '../services/ai_routine_service.dart';
import '../services/admin_session.dart';
import '../services/app_analytics_service.dart';
import '../services/routine_api_client.dart';
import '../services/routine_share_service.dart';
import '../services/shared_routine_link_coordinator.dart';
import '../services/share_link_log.dart';
import '../services/workout_completion_recorder.dart';
import '../services/workout_launch_coordinator.dart';
import '../utils/auth_helper.dart';
import '../utils/catalog_thumbnail.dart';
import '../utils/duration_calculator.dart';
import '../widgets/routine_list_thumbnail.dart';
import 'admin_upload_routine_screen.dart';
import 'ai_routine_create_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';
import 'upload_routine_screen.dart';
import 'workout_history_screen.dart';
import 'workout_screen.dart';
import 'app_settings_screen.dart';
import '../services/onboarding_routine_seeder.dart';
import '../widgets/home_app_bar_title.dart';
import '../widgets/routine_share_sheet.dart';
import '../widgets/swipe_reveal_delete.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.workoutHistoryRepository,
    required this.workoutCompletionRecorder,
    required this.apiClient,
    required this.adminSession,
    required this.linkCoordinator,
    required this.workoutLaunchCoordinator,
    this.onShowOnboardingAgain,
    this.initialOpenRoutineId,
    this.autoStartWorkout = false,
  });

  final RoutineRepository repository;
  final WorkoutHistoryRepository workoutHistoryRepository;
  final WorkoutCompletionRecorder workoutCompletionRecorder;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;
  final SharedRoutineLinkCoordinator linkCoordinator;
  final WorkoutLaunchCoordinator workoutLaunchCoordinator;
  final Future<void> Function()? onShowOnboardingAgain;
  /// When set (e.g. after onboarding), open this local routine once.
  final String? initialOpenRoutineId;
  /// After onboarding, open the workout timer directly instead of detail.
  final bool autoStartWorkout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loadingCatalog = true;
  String? _loadError;
  String? _downloadingCatalogId;
  String? _openSwipeItemKey;
  late final TextEditingController _catalogSearchController;
  /// Missing key = still resolving; null value = no media; non-null = ready.
  final Map<String, RoutineListThumbnailRef?> _catalogThumbnails = {};

  static const _bottomBarHeight = 120.0;
  static const _adminTapTarget = 7;
  static const _adminTapWindow = Duration(seconds: 2);

  int _titleTapCount = 0;
  DateTime? _lastTitleTapAt;
  final _shareService = RoutineShareService();
  bool _didOpenInitialRoutine = false;
  bool _seedingRecommended = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _catalogSearchController = TextEditingController();
    widget.linkCoordinator.onRoutineImported = () {
      if (!mounted) return;
      _tabController.animateTo(0);
      setState(() {});
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shareLinkLog('HomeScreen first frame — onHomeReady');
      widget.linkCoordinator.onHomeReady();
      widget.workoutLaunchCoordinator.onHomeReady();
      _openInitialRoutineIfNeeded();
    });
    _loadCatalogInitial();
  }

  Future<void> _openInitialRoutineIfNeeded() async {
    final routineId = widget.initialOpenRoutineId;
    if (_didOpenInitialRoutine || routineId == null) return;
    final routine = widget.repository.findById(routineId);
    if (routine == null) return;
    _didOpenInitialRoutine = true;
    if (widget.autoStartWorkout) {
      await _openWorkout(routine);
      return;
    }
    await _openLocalRoutine(routineId, showStartHint: true);
  }

  Future<void> _openWorkout(Routine routine) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          routine: routine,
          repository: widget.repository,
          completionRecorder: widget.workoutCompletionRecorder,
        ),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startFirstRoutineWorkout() async {
    final routines = widget.repository.myRoutines;
    if (routines.isEmpty) return;
    await _openWorkout(routines.first);
  }

  Future<void> _seedRecommendedAndStart() async {
    if (_seedingRecommended) return;
    setState(() => _seedingRecommended = true);
    final routineId = await OnboardingRoutineSeeder.seedFirstRecommended(
      widget.repository,
      analyticsSource: 'home_empty',
    );
    if (!mounted) return;
    setState(() => _seedingRecommended = false);
    if (routineId == null) {
      _tabController.animateTo(1);
      return;
    }
    final routine = widget.repository.findById(routineId);
    if (routine == null) return;
    await _openWorkout(routine);
  }

  @override
  void dispose() {
    _catalogSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogInitial() async {
    setState(() {
      _loadingCatalog = true;
      _loadError = null;
    });

    try {
      await widget.repository.refreshRemoteProfiles();
      if (!mounted) return;
      setState(() => _loadingCatalog = false);
      unawaited(_loadCatalogThumbnailImages());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCatalog = false;
        _loadError = AppLocalizations.of(context).profileLoadError;
      });
    }
  }

  Future<void> _refreshCatalog() async {
    setState(() => _loadError = null);

    try {
      await widget.repository.refreshRemoteProfiles();
      if (!mounted) return;
      setState(() {});
      unawaited(_loadCatalogThumbnailImages());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = AppLocalizations.of(context).profileLoadError;
      });
    }
  }

  Future<void> _openUpload() async {
    final authed = await AuthHelper.requireAuth(context);
    if (!authed || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UploadRoutineScreen(
          repository: widget.repository,
          apiClient: widget.apiClient,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshCatalog();
  }

  void _onTitleTap() {
    final now = DateTime.now();
    if (_lastTitleTapAt != null &&
        now.difference(_lastTitleTapAt!) > _adminTapWindow) {
      _titleTapCount = 0;
    }
    _lastTitleTapAt = now;
    _titleTapCount++;
    if (_titleTapCount < _adminTapTarget) return;

    _titleTapCount = 0;
    _lastTitleTapAt = null;
    _openAdminUpload();
  }

  Future<void> _openAdminUpload() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminUploadRoutineScreen(
          repository: widget.repository,
          apiClient: widget.apiClient,
          adminSession: widget.adminSession,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshCatalog();
  }

  List<ProfileSummary> _filterSummaries(List<ProfileSummary> summaries) {
    final query = _catalogSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return summaries;

    return summaries
        .where(
          (summary) =>
              summary.title.toLowerCase().contains(query) ||
              summary.description.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _openAiRoutineCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiRoutineCreateScreen(
          repository: widget.repository,
          aiRoutineService: AiRoutineService(),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _createRoutine() async {
    final l10n = AppLocalizations.of(context);
    await AppAnalyticsService.logProductEvent(
      'routine_create_started',
      properties: {'source': 'home'},
    );
    if (!mounted) return;
    final routine = createEmptyRoutine().copyWith(
      title: l10n.defaultRoutineName,
    );
    final saved = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
          isNew: true,
        ),
      ),
    );
    if (saved == null) return;
    if (!mounted) return;
    setState(() {});
  }

  void _onReorderMyRoutines(int oldIndex, int newIndex) {
    final routines = widget.repository.myRoutines;
    if (newIndex > oldIndex) newIndex--;
    final updated = List<Routine>.from(routines);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    widget.repository.saveListOrder(
      widget.repository.localIdsInDisplayOrder(updated),
    );
    setState(() {});
  }

  Future<void> _forkCatalogProfile(ProfileSummary summary) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _downloadingCatalogId = summary.id);
    await AppAnalyticsService.logProductEvent(
      'routine_download_started',
      properties: {
        'source': 'catalog',
        'catalog_type': summary.isOfficialCatalog ? 'official' : 'shared',
      },
    );

    try {
      await widget.repository.forkCatalogProfile(summary.id);
      await AppAnalyticsService.logRoutineDownload(
        source: 'catalog',
        catalogId: summary.id,
      );
      if (!mounted) return;
      setState(() => _downloadingCatalogId = null);
    } catch (_) {
      await AppAnalyticsService.logProductEvent(
        'routine_download_failed',
        properties: {'source': 'catalog'},
      );
      if (!mounted) return;
      setState(() => _downloadingCatalogId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routineDownloadError)));
    }
  }

  Future<void> _openCatalogRoutine(String catalogId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          repository: widget.repository,
          workoutCompletionRecorder: widget.workoutCompletionRecorder,
          catalogId: catalogId,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _confirmDeleteMyRoutine(Routine routine) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoutineTitle),
        content: Text(l10n.deleteRoutineMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await widget.repository.delete(routine.id);
    if (!mounted) return;
    setState(() => _openSwipeItemKey = null);
  }

  Future<void> _openLocalRoutine(
    String routineId, {
    bool showStartHint = false,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          repository: widget.repository,
          workoutCompletionRecorder: widget.workoutCompletionRecorder,
          routineId: routineId,
          showStartHint: showStartHint,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  String _myRoutineSubtitle(AppLocalizations l10n, Routine routine) {
    final duration = routineDurationSec(routine);
    return l10n.routineCountDuration(
      routine.orderedExercises.length,
      formatDurationShort(duration, l10n),
    );
  }

  Future<void> _loadCatalogThumbnailImages() async {
    final summaries = [
      ...widget.repository.officialCatalogSummaries,
      ...widget.repository.sharedCatalogSummaries,
    ];
    final unresolvedIds = <String>[
      for (final summary in summaries)
        if (!_catalogThumbnails.containsKey(summary.id)) summary.id,
    ];
    if (unresolvedIds.isEmpty) return;

    for (final id in unresolvedIds) {
      RoutineListThumbnailRef? thumbnail;
      try {
        final routine = await widget.apiClient.fetchProfile(
          id,
          localize: false,
        );
        thumbnail = pickRoutineListThumbnail(routine);
      } catch (_) {
        thumbnail = null;
      }
      if (!mounted) return;
      setState(() => _catalogThumbnails[id] = thumbnail);
    }
  }

  Future<void> _shareApp() async {
    final l10n = AppLocalizations.of(context);
    await RoutineShareSheet.show(
      context: context,
      shareText: _shareService.buildAppShareMessage(l10n),
      kakaoShareText: _shareService.buildAppKakaoShareMessage(l10n),
      subject: l10n.appTitle,
      linkUrl: RoutineShareService.appShareLink,
      linkButtonTitle: l10n.shareKakaoAppLinkButton,
      shareType: 'app',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        actionsPadding: const EdgeInsets.only(right: 4),
        toolbarHeight: 56,
        title: GestureDetector(
          onTap: _onTitleTap,
          behavior: HitTestBehavior.opaque,
          child: HomeAppBarTitle(title: l10n.appTitle),
        ),
        actions: [
          IconButton(
            onPressed: _shareApp,
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.shareAppTooltip,
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WorkoutHistoryScreen(
                    historyRepository: widget.workoutHistoryRepository,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: l10n.workoutHistoryTitle,
          ),
          IconButton(
            onPressed: () => AppSettingsScreen.open(
              context,
              onShowOnboardingAgain: widget.onShowOnboardingAgain,
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.homeTabMyRoutines),
            Tab(text: l10n.homeTabShared),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildMyRoutinesTab(l10n), _buildDownloadCatalogTab(l10n)],
      ),
      bottomNavigationBar: _HomeBottomActions(
        aiLabel: l10n.aiRoutineCreateButton,
        createLabel: l10n.createRoutine,
        uploadLabel: l10n.uploadRoutineTitle,
        onAiCreate: _openAiRoutineCreate,
        onCreate: _createRoutine,
        onUpload: _openUpload,
      ),
    );
  }

  double get _listBottomPadding =>
      _bottomBarHeight + 16 + MediaQuery.paddingOf(context).bottom;

  Widget _buildMyRoutinesTab(AppLocalizations l10n) {
    final routines = widget.repository.myRoutines;
    final hasCompletedWorkout =
        widget.workoutHistoryRepository.allRecords.isNotEmpty;
    final showStartBanner = routines.isNotEmpty && !hasCompletedWorkout;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 12, 16, _listBottomPadding),
      children: [
        if (showStartBanner) ...[
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.homeStartNowTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeStartNowSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _startFirstRoutineWorkout,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.homeStartNowButton),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (routines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(
                  l10n.noMyRoutines,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed:
                      _seedingRecommended ? null : _seedRecommendedAndStart,
                  icon: _seedingRecommended
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(l10n.homeEmptyStartRecommended),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: Text(l10n.homeEmptyBrowseCatalog),
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: routines.length,
            onReorder: _onReorderMyRoutines,
            itemBuilder: (context, index) {
              final routine = routines[index];
              final thumbnail = pickRoutineListThumbnail(routine);
              return Padding(
                key: ValueKey(routine.id),
                padding: EdgeInsets.only(
                  bottom: index == routines.length - 1 ? 0 : 12,
                ),
                child: SwipeRevealDelete(
                  itemKey: routine.id,
                  openItemKey: _openSwipeItemKey,
                  onOpenChanged: (key) =>
                      setState(() => _openSwipeItemKey = key),
                  deleteLabel: l10n.delete,
                  onDelete: () => _confirmDeleteMyRoutine(routine),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: SizedBox(
                        width: thumbnail != null ? 88 : 36,
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            if (thumbnail != null) ...[
                              const SizedBox(width: 8),
                              RoutineListThumbnail.fromRef(thumbnail),
                            ],
                          ],
                        ),
                      ),
                      minLeadingWidth: thumbnail != null ? 88 : 36,
                      title: Text(
                        routine.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _myRoutineSubtitle(l10n, routine),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openLocalRoutine(routine.id),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDownloadCatalogTab(AppLocalizations l10n) {
    final official = _filterSummaries(
      widget.repository.officialCatalogSummaries,
    );
    final shared = _filterSummaries(widget.repository.sharedCatalogSummaries);
    final hasAnyCatalog =
        widget.repository.officialCatalogSummaries.isNotEmpty ||
        widget.repository.sharedCatalogSummaries.isNotEmpty;
    final isEmpty = official.isEmpty && shared.isEmpty;
    final hasSearchQuery = _catalogSearchController.text.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _catalogSearchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchRoutinesHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: hasSearchQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _catalogSearchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: _loadingCatalog
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.loadingProfiles),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshCatalog,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 0, 16, _listBottomPadding),
                    children: [
                      if (_loadError != null) ...[
                        _ErrorBanner(
                          message: _loadError!,
                          onRetry: _loadCatalogInitial,
                          retryLabel: l10n.retry,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        l10n.homeDownloadCatalogHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!hasAnyCatalog)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text(l10n.noSharedRoutines)),
                        )
                      else if (isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text(l10n.noSearchResults)),
                        )
                      else ...[
                        if (official.isNotEmpty) ...[
                          _SectionTitle(l10n.homeCatalogOfficialSection),
                          const SizedBox(height: 8),
                          ...official.map(
                            (summary) => _CatalogCard(
                              summary: summary,
                              l10n: l10n,
                              isDownloading:
                                  _downloadingCatalogId == summary.id,
                              isDownloaded: widget.repository
                                  .hasDownloadedCatalog(summary.id),
                              thumbnail: _catalogThumbnails[summary.id],
                              onOpen: () => _openCatalogRoutine(summary.id),
                              onDownload: () => _forkCatalogProfile(summary),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (shared.isNotEmpty) ...[
                          _SectionTitle(l10n.homeCatalogSharedSection),
                          const SizedBox(height: 8),
                          ...shared.map(
                            (summary) => _CatalogCard(
                              summary: summary,
                              l10n: l10n,
                              isDownloading:
                                  _downloadingCatalogId == summary.id,
                              isDownloaded: widget.repository
                                  .hasDownloadedCatalog(summary.id),
                              thumbnail: _catalogThumbnails[summary.id],
                              onOpen: () => _openCatalogRoutine(summary.id),
                              onDownload: () => _forkCatalogProfile(summary),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _HomeBottomActions extends StatelessWidget {
  const _HomeBottomActions({
    required this.aiLabel,
    required this.createLabel,
    required this.uploadLabel,
    required this.onAiCreate,
    required this.onCreate,
    required this.onUpload,
  });

  final String aiLabel;
  final String createLabel;
  final String uploadLabel;
  final VoidCallback onAiCreate;
  final VoidCallback onCreate;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final panelColor = Theme.of(context).scaffoldBackgroundColor;
    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.7);
    return Material(
      elevation: 0,
      color: panelColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAiCreate,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: borderColor),
                    foregroundColor: colorScheme.onSurface,
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 20),
                  label: Text(aiLabel),
                ),
              ),
              const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onCreate,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: borderColor),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Icon(Icons.add, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                createLabel,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onUpload,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Icon(Icons.upload_outlined, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                uploadLabel,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.86),
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.summary,
    required this.l10n,
    required this.isDownloading,
    required this.isDownloaded,
    required this.thumbnail,
    required this.onOpen,
    required this.onDownload,
  });

  final ProfileSummary summary;
  final AppLocalizations l10n;
  final bool isDownloading;
  final bool isDownloaded;
  final RoutineListThumbnailRef? thumbnail;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final metaStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final ownerText = summary.ownerName?.trim().isNotEmpty == true
        ? summary.ownerName!
        : null;
    final showThumbSlot = thumbnail != null;

    Widget downloadButton() {
      return IconButton(
        onPressed: isDownloading ? null : onDownload,
        tooltip: l10n.downloadRoutineTooltip,
        icon: isDownloading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isDownloaded
                    ? Icons.download_done_outlined
                    : Icons.download_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: showThumbSlot
              ? SizedBox(
                  width: 108,
                  child: Row(
                    children: [
                      downloadButton(),
                      const SizedBox(width: 4),
                      RoutineListThumbnail.fromRef(thumbnail!),
                    ],
                  ),
                )
              : downloadButton(),
          minLeadingWidth: showThumbSlot ? 108 : 48,
          title: Text(
            summary.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              ownerText == null
                  ? l10n.routineCountOnly(summary.exerciseCount)
                  : '${l10n.routineCountOnly(summary.exerciseCount)}  ·  $ownerText',
              style: metaStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onOpen,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        title: Text(message),
        trailing: TextButton(onPressed: onRetry, child: Text(retryLabel)),
      ),
    );
  }
}
