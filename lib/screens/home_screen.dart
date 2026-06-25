import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../models/routine.dart';
import '../services/admin_session.dart';
import '../services/locale_settings.dart';
import '../services/routine_api_client.dart';
import '../utils/duration_calculator.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';
import 'upload_routine_screen.dart';
import '../widgets/app_settings_sheet.dart';

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
  String? _downloadingId;

  bool get _isOfficialTab => _tabController.index == 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  List<Routine> _routinesForTab({required bool official}) {
    return widget.repository.loadAll(official: official);
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
    _load();
  }

  int _lastDownloadedIndex(List<Routine> routines) {
    var index = -1;
    for (var i = 0; i < routines.length; i++) {
      if (widget.repository.isDownloadedLocally(routines[i].id)) {
        index = i;
      }
    }
    return index;
  }

  void _onReorder({
    required bool official,
    required int oldIndex,
    required int newIndex,
  }) {
    final routines = _routinesForTab(official: official);
    final lastDownloaded = _lastDownloadedIndex(routines);
    if (lastDownloaded < 0) return;
    if (oldIndex > lastDownloaded || newIndex > lastDownloaded + 1) return;

    if (newIndex > oldIndex) newIndex--;
    final updated = List<Routine>.from(routines);
    final item = updated.removeAt(oldIndex);
    if (newIndex > lastDownloaded) {
      newIndex = lastDownloaded;
    }
    updated.insert(newIndex, item);

    widget.repository.saveListOrder(
      widget.repository.downloadedIdsInDisplayOrder(updated),
    );
    setState(() {});
  }

  Future<void> _downloadRoutine(Routine routine) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _downloadingId = routine.id);

    try {
      await widget.repository.downloadCatalogProfile(routine.id);
      if (!mounted) return;
      setState(() => _downloadingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineDownloadSuccess(routine.title))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloadingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineDownloadError)),
      );
    }
  }

  Future<void> _openRoutine(Routine routine) async {
    if (widget.repository.isCatalogStub(routine)) {
      await _downloadRoutine(routine);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          repository: widget.repository,
          routineId: routine.id,
        ),
      ),
    );
    _load();
  }

  String _subtitle(AppLocalizations l10n, Routine routine) {
    if (widget.repository.isCatalogStub(routine)) {
      final count =
          widget.repository.catalogExerciseCount(routine.id) ?? 0;
      return l10n.routineCountOnly(count);
    }

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
          IconButton(
            onPressed: _openUpload,
            icon: const Icon(Icons.upload_outlined),
            tooltip: l10n.uploadRoutineTooltip,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.homeTabOfficial),
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
              children: [
                _buildRoutineList(l10n),
                _buildRoutineList(l10n, shared: true),
              ],
            ),
      floatingActionButton: _isOfficialTab
          ? FloatingActionButton.extended(
              onPressed: _createRoutine,
              icon: const Icon(Icons.add),
              label: Text(l10n.createRoutine),
            )
          : null,
    );
  }

  Widget _buildRoutineList(AppLocalizations l10n, {bool shared = false}) {
    final official = !shared;
    final routines = _routinesForTab(official: official);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          88 + MediaQuery.paddingOf(context).bottom,
        ),
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
              child: Center(
                child: Text(
                  shared ? l10n.noSharedRoutines : l10n.noRoutines,
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: routines.length,
              onReorder: (oldIndex, newIndex) => _onReorder(
                official: official,
                oldIndex: oldIndex,
                newIndex: newIndex,
              ),
              itemBuilder: (context, index) {
                final routine = routines[index];
                final isDownloaded =
                    widget.repository.isDownloadedLocally(routine.id);
                final isDownloading = _downloadingId == routine.id;

                return Padding(
                  key: ValueKey(routine.id),
                  padding: EdgeInsets.only(
                    bottom: index == routines.length - 1 ? 0 : 12,
                  ),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: isDownloaded
                          ? ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.7),
                              ),
                            )
                          : IconButton(
                              onPressed: isDownloading
                                  ? null
                                  : () => _downloadRoutine(routine),
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
                                      Icons.download_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
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
                        child: Text(_subtitle(l10n, routine)),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openRoutine(routine),
                    ),
                  ),
                );
              },
            ),
        ],
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
