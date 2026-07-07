import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../app_auth_provider.dart';
import '../data/routine_repository.dart';
import '../features/legal/privacy_processing_consent.dart';
import '../models/routine.dart';
import '../services/routine_api_client.dart';
import '../utils/account_deletion.dart';
import '../utils/content_language.dart';
import '../utils/duration_calculator.dart';
import '../widgets/swipe_reveal_delete.dart';
import 'routine_editor_screen.dart';

class UploadRoutineScreen extends StatefulWidget {
  const UploadRoutineScreen({
    super.key,
    required this.repository,
    required this.apiClient,
  });

  final RoutineRepository repository;
  final RoutineApiClient apiClient;

  @override
  State<UploadRoutineScreen> createState() => _UploadRoutineScreenState();
}

class _UploadRoutineScreenState extends State<UploadRoutineScreen> {
  List<Routine> _serverRoutines = [];
  List<Routine> _localRoutines = [];
  Set<String> _serverRoutineIds = {};
  bool _loading = true;
  bool _uploading = false;
  String? _loadError;
  String? _openSwipeItemKey;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
    AppAuthProvider.shared.refreshUserProfile();
  }

  String? _userDisplayName() {
    final profileName = AppAuthProvider.shared.userProfile?.fullName.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }
    final firebaseName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    if (firebaseName != null && firebaseName.isNotEmpty) {
      return firebaseName;
    }
    return null;
  }

  Widget _userNameHeader(BuildContext context) {
    return ListenableBuilder(
      listenable: AppAuthProvider.shared,
      builder: (context, _) {
        final name = _userDisplayName();
        if (name == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _userToken() => AppAuthProvider.shared.getIdToken();

  Future<void> _loadRoutines() async {
    final token = await _userToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _serverRoutines = [];
        _localRoutines = [];
        _serverRoutineIds = {};
        _loading = false;
        _loadError = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final serverRoutines = await widget.apiClient.fetchUserProfiles(
        userToken: token,
      );
      final localRoutines = widget.repository.loadLocalOnly();

      if (!mounted) return;
      setState(() {
        _serverRoutines = serverRoutines;
        _localRoutines = localRoutines;
        _serverRoutineIds =
            serverRoutines.map((routine) => routine.id).toSet();
        _loading = false;
      });
    } on RoutineApiException catch (_) {
      if (!mounted) return;
      setState(() {
        _serverRoutines = [];
        _localRoutines = [];
        _serverRoutineIds = {};
        _loading = false;
        _loadError = AppLocalizations.of(context).uploadLoadServerIdsError;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _serverRoutines = [];
        _localRoutines = [];
        _serverRoutineIds = {};
        _loading = false;
        _loadError = AppLocalizations.of(context).uploadLoadServerIdsError;
      });
    }
  }

  Future<void> _signOut() async {
    await clearPrivacyProcessingConsent();
    await AppAuthProvider.shared.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _deleteAccount() async {
    await confirmAndDeleteAccount(context);
  }

  Future<void> _editServerRoutine(Routine routine) async {
    final token = await _userToken();
    if (token == null) return;

    await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
          apiClient: widget.apiClient,
          userAuthToken: token,
          persistToServer: true,
        ),
      ),
    );
    if (!mounted) return;
    await _loadRoutines();
  }

  Future<void> _editLocalRoutine(Routine routine) async {
    await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
        ),
      ),
    );
    if (!mounted) return;
    await _loadRoutines();
  }

  Future<void> _uploadLocalRoutine(Routine routine) async {
    final l10n = AppLocalizations.of(context);
    final contentLanguage = ContentLanguage.current(
      systemLocale: Localizations.localeOf(context),
    );
    final token = await _userToken();
    if (token == null) return;

    final serverProfileId =
        widget.repository.uploadedServerProfileIdFor(routine.id);
    final onServer = serverProfileId != null &&
        _serverRoutineIds.contains(serverProfileId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.uploadConfirmTitle),
        content: Text(
          onServer
              ? l10n.uploadConfirmUpdate(routine.title)
              : l10n.uploadConfirmCreate(routine.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.upload),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _uploading = true);

    try {
      var serverCopy = widget.repository.copyForServerUpload(
        routine,
        existingServerProfileId: serverProfileId,
        contentLanguage: contentLanguage,
      );
      UploadProfileResult result;
      try {
        result = await widget.apiClient.uploadUserProfile(
          routine: serverCopy,
          userToken: token,
        );
      } on RoutineApiException catch (error) {
        final staleLink = serverProfileId != null &&
            error.message.toLowerCase().contains('profile id already in use');
        if (!staleLink) rethrow;
        serverCopy = widget.repository.copyForServerUpload(
          routine,
          contentLanguage: contentLanguage,
        );
        result = await widget.apiClient.uploadUserProfile(
          routine: serverCopy,
          userToken: token,
        );
      }
      if (!mounted) return;

      await widget.repository.setUploadedServerProfileId(
        localRoutineId: routine.id,
        serverProfileId: serverCopy.id,
      );

      setState(() => _uploading = false);
      await _loadRoutines();
      if (!mounted) return;

      final message = result.action == UploadProfileAction.created
          ? l10n.uploadSuccessCreated(routine.title)
          : l10n.uploadSuccessUpdated(routine.title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on RoutineApiException catch (error) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.uploadError)),
      );
    }
  }

  Future<void> _confirmDeleteServerRoutine(Routine routine) async {
    if (_uploading) return;
    final l10n = AppLocalizations.of(context);
    final token = await _userToken();
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoutineTitle),
        content: Text(l10n.uploadDeleteServerRoutineMessage),
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

    setState(() => _uploading = true);
    try {
      await widget.apiClient.deleteUserProfile(
        profileId: routine.id,
        userToken: token,
      );
      await widget.repository.clearUploadedServerProfileLink(routine.id);
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _openSwipeItemKey = null;
      });
      await _loadRoutines();
    } on RoutineApiException catch (error) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.uploadError)),
      );
    }
  }

  Future<void> _confirmDeleteLocalRoutine(Routine routine) async {
    if (_uploading) return;
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
    await _loadRoutines();
  }

  Widget _routineCard({
    required String swipeKey,
    required Routine routine,
    required AppLocalizations l10n,
    required Widget trailing,
    required VoidCallback onDelete,
    VoidCallback? onTap,
  }) {
    final duration = routineDurationSec(routine);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SwipeRevealDelete(
        itemKey: swipeKey,
        openItemKey: _openSwipeItemKey,
        onOpenChanged: (key) => setState(() => _openSwipeItemKey = key),
        deleteLabel: l10n.delete,
        onDelete: onDelete,
        child: Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text(routine.title),
            subtitle: Text(
              l10n.routineCountDuration(
                routine.orderedExercises.length,
                formatDurationShort(duration, l10n),
              ),
            ),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadRoutineTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                _userNameHeader(context),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  if (_loadError != null) ...[
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        title: Text(_loadError!),
                        trailing: TextButton(
                          onPressed: _loadRoutines,
                          child: Text(l10n.retry),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    l10n.uploadServerRoutineSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.uploadServerRoutineHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_serverRoutines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(child: Text(l10n.uploadNoAdminRoutines)),
                    )
                  else
                    ..._serverRoutines.map(
                      (routine) => _routineCard(
                        swipeKey: 'server:${routine.id}',
                        routine: routine,
                        l10n: l10n,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: l10n.editTooltip,
                          onPressed: _uploading
                              ? null
                              : () => _editServerRoutine(routine),
                        ),
                        onDelete: () => _confirmDeleteServerRoutine(routine),
                        onTap: _uploading
                            ? null
                            : () => _editServerRoutine(routine),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.uploadLocalRoutineSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.uploadLocalRoutineHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_localRoutines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text(l10n.uploadNoLocalRoutines)),
                    )
                  else
                    ..._localRoutines.map(
                      (routine) => _routineCard(
                        swipeKey: 'local:${routine.id}',
                        routine: routine,
                        l10n: l10n,
                        trailing: FilledButton.tonal(
                          onPressed: _uploading
                              ? null
                              : () => _uploadLocalRoutine(routine),
                          child: Text(l10n.upload),
                        ),
                        onDelete: () => _confirmDeleteLocalRoutine(routine),
                        onTap:
                            _uploading ? null : () => _editLocalRoutine(routine),
                      ),
                    ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploading ? null : _signOut,
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.settingsSignOut),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploading ? null : _deleteAccount,
                      icon: const Icon(Icons.person_remove_outlined),
                      label: Text(l10n.settingsDeleteAccount),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
