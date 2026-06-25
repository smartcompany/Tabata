import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../models/profile_summary.dart';
import '../models/routine.dart';
import '../services/admin_session.dart';
import '../services/locale_settings.dart';
import '../services/routine_api_client.dart';
import '../utils/duration_calculator.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';
import 'upload_routine_screen.dart';
import '../widgets/app_settings_sheet.dart';
import '../widgets/swipe_reveal_delete.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.apiClient,
    required this.adminSession,
    required this.localeSettings,
    required this.onLocaleChanged,
  });

  final RoutineRepository repository;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;
  final LocaleSettings localeSettings;
  final VoidCallback onLocaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loading = true;
  String? _loadError;
  String? _downloadingCatalogId;
  String? _openSwipeItemKey;

  static const _bottomBarHeight = 64.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      await widget.repository.refreshRemoteProfiles();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = AppLocalizations.of(context).profileLoadError;
      });
    }
  }

  Future<void> _openUpload() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UploadRoutineScreen(
          repository: widget.repository,
          apiClient: widget.apiClient,
          adminSession: widget.adminSession,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _createRoutine() async {
    final l10n = AppLocalizations.of(context);
    final routine =
        createEmptyRoutine().copyWith(title: l10n.defaultRoutineName);
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
      final forked = await widget.repository.forkCatalogProfile(summary.id);
      if (!mounted) return;
      setState(() => _downloadingCatalogId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.routineAddedToMyRoutines(forked.title)),
          action: SnackBarAction(
            label: l10n.homeTabMyRoutines,
            onPressed: () {
              _tabController.animateTo(0);
              _openLocalRoutine(forked.id);
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloadingCatalogId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineDownloadError)),
      );
    }
  }

  Future<void> _openCatalogRoutine(String catalogId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          repository: widget.repository,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => showAppSettingsSheet(context),
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
      body: _loading
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
          : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMyRoutinesTab(l10n),
                _buildDownloadCatalogTab(l10n),
              ],
            ),
      bottomNavigationBar: _HomeBottomActions(
        createLabel: l10n.createRoutine,
        uploadLabel: l10n.uploadRoutineTitle,
        onCreate: _createRoutine,
        onUpload: _openUpload,
      ),
    );
  }

  double get _listBottomPadding =>
      _bottomBarHeight + 16 + MediaQuery.paddingOf(context).bottom;

  Widget _buildMyRoutinesTab(AppLocalizations l10n) {
    final routines = widget.repository.myRoutines;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 12, 16, _listBottomPadding),
        children: [
          if (_loadError != null) ...[
            _ErrorBanner(
              message: _loadError!,
              onRetry: _load,
              retryLabel: l10n.retry,
            ),
            const SizedBox(height: 12),
          ],
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
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      title: Text(
                        routine.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(_myRoutineSubtitle(l10n, routine)),
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
      ),
    );
  }

  Widget _buildDownloadCatalogTab(AppLocalizations l10n) {
    final official = widget.repository.officialCatalogSummaries;
    final shared = widget.repository.sharedCatalogSummaries;
    final isEmpty = official.isEmpty && shared.isEmpty;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 12, 16, _listBottomPadding),
        children: [
          if (_loadError != null) ...[
            _ErrorBanner(
              message: _loadError!,
              onRetry: _load,
              retryLabel: l10n.retry,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            l10n.homeDownloadCatalogHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 16),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text(l10n.noSharedRoutines)),
            )
          else ...[
            if (official.isNotEmpty) ...[
              _SectionTitle(l10n.homeCatalogOfficialSection),
              const SizedBox(height: 8),
              ...official.map(
                (summary) => _CatalogCard(
                  summary: summary,
                  l10n: l10n,
                  isDownloading: _downloadingCatalogId == summary.id,
                  isDownloaded: widget.repository.hasDownloadedCatalog(
                    summary.id,
                  ),
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
                  isDownloading: _downloadingCatalogId == summary.id,
                  isDownloaded: widget.repository.hasDownloadedCatalog(
                    summary.id,
                  ),
                  onOpen: () => _openCatalogRoutine(summary.id),
                  onDownload: () => _forkCatalogProfile(summary),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _HomeBottomActions extends StatelessWidget {
  const _HomeBottomActions({
    required this.createLabel,
    required this.uploadLabel,
    required this.onCreate,
    required this.onUpload,
  });

  final String createLabel;
  final String uploadLabel;
  final VoidCallback onCreate;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(createLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_outlined, size: 20),
                  label: Text(uploadLabel),
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
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
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
    required this.onOpen,
    required this.onDownload,
  });

  final ProfileSummary summary;
  final AppLocalizations l10n;
  final bool isDownloading;
  final bool isDownloaded;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: IconButton(
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
          title: Text(
            summary.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l10n.routineCountOnly(summary.exerciseCount)),
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
        trailing: TextButton(
          onPressed: onRetry,
          child: Text(retryLabel),
        ),
      ),
    );
  }
}
