import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../data/workout_history_repository.dart';
import '../models/profile_summary.dart';
import '../models/routine.dart';
import '../models/description_block.dart';
import '../services/ai_routine_service.dart';
import '../services/admin_session.dart';
import '../services/app_analytics_service.dart';
import '../services/content_settings.dart';
import '../services/routine_api_client.dart';
import '../services/routine_share_service.dart';
import '../services/shared_routine_link_coordinator.dart';
import '../services/share_link_log.dart';
import '../services/workout_completion_recorder.dart';
import '../services/workout_launch_coordinator.dart';
import '../utils/auth_helper.dart';
import '../utils/catalog_thumbnail.dart';
import '../utils/duration_calculator.dart';
import '../utils/video_link_utils.dart';
import 'admin_upload_routine_screen.dart';
import 'ai_routine_create_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';
import 'upload_routine_screen.dart';
import 'workout_history_screen.dart';
import 'app_settings_screen.dart';
import '../widgets/description_block_image.dart';
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
  });

  final RoutineRepository repository;
  final WorkoutHistoryRepository workoutHistoryRepository;
  final WorkoutCompletionRecorder workoutCompletionRecorder;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;
  final SharedRoutineLinkCoordinator linkCoordinator;
  final WorkoutLaunchCoordinator workoutLaunchCoordinator;
  final Future<void> Function()? onShowOnboardingAgain;

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
  final Map<String, String?> _catalogThumbnailImageUrls = {};

  static const _bottomBarHeight = 120.0;
  static const _adminTapTarget = 7;
  static const _adminTapWindow = Duration(seconds: 2);

  int _titleTapCount = 0;
  DateTime? _lastTitleTapAt;
  final _shareService = RoutineShareService();

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
    });
    ContentSettings.addListener(_onCatalogRefreshPreferencesChanged);
    _loadCatalogInitial();
  }

  @override
  void dispose() {
    ContentSettings.removeListener(_onCatalogRefreshPreferencesChanged);
    _catalogSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onCatalogRefreshPreferencesChanged() async {
    if (!mounted) return;
    await _refreshCatalog();
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

    try {
      await widget.repository.forkCatalogProfile(summary.id);
      await AppAnalyticsService.logRoutineDownload(
        source: 'catalog',
        catalogId: summary.id,
      );
      if (!mounted) return;
      setState(() => _downloadingCatalogId = null);
    } catch (_) {
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

  Future<void> _openLocalRoutine(String routineId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          repository: widget.repository,
          workoutCompletionRecorder: widget.workoutCompletionRecorder,
          routineId: routineId,
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

  DescriptionBlock? _pickRoutineThumbnailBlock(Routine routine) {
    for (final block in routine.effectiveDescriptionBlocks) {
      if (block is ImageDescriptionBlock) return block;
    }
    for (final block in routine.effectiveDescriptionBlocks) {
      if (block is VideoDescriptionBlock) return block;
    }
    return null;
  }

  Future<void> _loadCatalogThumbnailImages() async {
    final summaries = [
      ...widget.repository.officialCatalogSummaries,
      ...widget.repository.sharedCatalogSummaries,
    ];
    final unresolvedIds = <String>[
      for (final summary in summaries)
        if (!_catalogThumbnailImageUrls.containsKey(summary.id)) summary.id,
    ];
    if (unresolvedIds.isEmpty) return;

    for (final id in unresolvedIds) {
      String? thumbnailUrl;
      try {
        final routine = await widget.apiClient.fetchProfile(
          id,
          localize: false,
        );
        thumbnailUrl = pickCatalogThumbnailImageUrl(routine);
      } catch (_) {
        thumbnailUrl = null;
      }
      if (!mounted) return;
      setState(() => _catalogThumbnailImageUrls[id] = thumbnailUrl);
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

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 12, 16, _listBottomPadding),
      children: [
        if (routines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text(l10n.noMyRoutines)),
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
              final thumbnailBlock = _pickRoutineThumbnailBlock(routine);
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
                        width: thumbnailBlock != null ? 88 : 36,
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
                            if (thumbnailBlock != null) ...[
                              const SizedBox(width: 8),
                              _RoutineListThumbnail(block: thumbnailBlock),
                            ],
                          ],
                        ),
                      ),
                      minLeadingWidth: thumbnailBlock != null ? 88 : 36,
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
                              thumbnailImageUrl:
                                  _catalogThumbnailImageUrls[summary.id],
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
                              thumbnailImageUrl:
                                  _catalogThumbnailImageUrls[summary.id],
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

class _RoutineListThumbnail extends StatelessWidget {
  const _RoutineListThumbnail({required this.block});

  final DescriptionBlock block;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: switch (block) {
          ImageDescriptionBlock imageBlock => DescriptionBlockImage(
              block: imageBlock,
              borderRadius: 10,
              fit: BoxFit.cover,
            ),
          VideoDescriptionBlock(:final url) => _RoutineVideoThumbnail(url: url),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _RoutineVideoThumbnail extends StatelessWidget {
  const _RoutineVideoThumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final videoId = VideoLinkUtils.youtubeVideoId(url);
    final thumbnailUrl = videoId == null
        ? null
        : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnailUrl != null)
          Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
          )
        else
          Container(color: Theme.of(context).colorScheme.surfaceContainer),
        Container(color: Colors.black.withValues(alpha: 0.22)),
        Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: Colors.white.withValues(alpha: 0.92),
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.summary,
    required this.l10n,
    required this.isDownloading,
    required this.isDownloaded,
    required this.thumbnailImageUrl,
    required this.onOpen,
    required this.onDownload,
  });

  final ProfileSummary summary;
  final AppLocalizations l10n;
  final bool isDownloading;
  final bool isDownloaded;
  final String? thumbnailImageUrl;
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
    final resolvedUrl = thumbnailImageUrl?.trim();
    final hasImage = resolvedUrl != null && resolvedUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: hasImage
              ? SizedBox(
                  width: 108,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: isDownloading ? null : onDownload,
                        tooltip: l10n.downloadRoutineTooltip,
                        icon: isDownloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isDownloaded
                                    ? Icons.download_done_outlined
                                    : Icons.download_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      const SizedBox(width: 4),
                      _CatalogThumbnailSlot(imageUrl: resolvedUrl),
                    ],
                  ),
                )
              : IconButton(
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
                ),
          minLeadingWidth: hasImage ? 108 : 48,
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

class _CatalogThumbnailSlot extends StatelessWidget {
  const _CatalogThumbnailSlot({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: DescriptionBlockImage(
          block: ImageDescriptionBlock(url: imageUrl),
          borderRadius: 10,
          fit: BoxFit.cover,
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
