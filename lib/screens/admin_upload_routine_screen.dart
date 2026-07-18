import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../models/routine.dart';
import '../services/admin_session.dart';
import '../services/routine_api_client.dart';
import '../utils/duration_calculator.dart';
import '../utils/routine_list_thumbnail.dart';
import '../widgets/routine_list_thumbnail.dart';
import 'routine_editor_screen.dart';

/// Hidden admin entry: dashboard username/password login, then official catalog upload.
class AdminUploadRoutineScreen extends StatefulWidget {
  const AdminUploadRoutineScreen({
    super.key,
    required this.repository,
    required this.apiClient,
    required this.adminSession,
  });

  final RoutineRepository repository;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;

  @override
  State<AdminUploadRoutineScreen> createState() =>
      _AdminUploadRoutineScreenState();
}

class _AdminUploadRoutineScreenState extends State<AdminUploadRoutineScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Routine> _serverRoutines = [];
  List<Routine> _localRoutines = [];
  bool _loading = false;
  bool _loggingIn = false;
  bool _uploading = false;
  String? _loadError;
  String? _loginError;

  bool get _isLoggedIn => widget.adminSession.isLoggedIn;

  @override
  void initState() {
    super.initState();
    if (_isLoggedIn) {
      _loadAfterLogin();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAfterLogin() async {
    final token = widget.adminSession.token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _serverRoutines = [];
        _localRoutines = [];
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
      final serverRoutines = await widget.apiClient.fetchDashboardProfiles(
        adminToken: token,
      );
      final serverIds = serverRoutines.map((routine) => routine.id).toSet();
      final localRoutines = widget.repository
          .loadLocalOnly()
          .where((routine) => !serverIds.contains(routine.id))
          .toList();

      if (!mounted) return;
      setState(() {
        _serverRoutines = serverRoutines;
        _localRoutines = localRoutines;
        _loading = false;
      });
    } on RoutineApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Unauthorized') {
        await widget.adminSession.clear();
      }
      setState(() {
        _serverRoutines = [];
        _localRoutines = [];
        _loading = false;
        _loadError = AppLocalizations.of(context).uploadLoadServerIdsError;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _serverRoutines = [];
        _localRoutines = [];
        _loading = false;
        _loadError = AppLocalizations.of(context).uploadLoadServerIdsError;
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _loggingIn = true;
      _loginError = null;
    });

    try {
      final token = await widget.apiClient.loginDashboard(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      await widget.adminSession.saveToken(token);
      if (!mounted) return;
      setState(() {
        _loggingIn = false;
        _passwordController.clear();
      });
      await _loadAfterLogin();
    } on RoutineApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loggingIn = false;
        _loginError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loggingIn = false;
        _loginError = AppLocalizations.of(context).uploadLoginError;
      });
    }
  }

  Future<void> _logout() async {
    await widget.adminSession.clear();
    if (!mounted) return;
    setState(() {
      _serverRoutines = [];
      _localRoutines = [];
      _loadError = null;
      _loginError = null;
    });
  }

  Future<void> _editServerRoutine(Routine routine) async {
    final token = widget.adminSession.token;
    if (token == null) return;

    final saved = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
          apiClient: widget.apiClient,
          adminToken: token,
          persistToDashboard: true,
        ),
      ),
    );
    if (!mounted) return;
    if (saved != null) {
      await _loadAfterLogin();
    }
  }

  Future<void> _uploadLocalRoutine(Routine routine) async {
    final l10n = AppLocalizations.of(context);
    final token = widget.adminSession.token;
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.uploadConfirmTitle),
        content: Text(l10n.uploadConfirmCreate(routine.title)),
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
      final result = await widget.apiClient.uploadProfile(
        routine: routine,
        adminToken: token,
      );
      if (!mounted) return;

      setState(() => _uploading = false);
      await _loadAfterLogin();
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

  Widget _routineCard({
    required Routine routine,
    required AppLocalizations l10n,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final duration = routineDurationSec(routine);
    final thumbnail = pickRoutineListThumbnail(routine);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: thumbnail == null
              ? null
              : RoutineListThumbnail.fromRef(thumbnail),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadRoutineTitle),
        actions: [
          if (_isLoggedIn)
            TextButton(
              onPressed: _uploading ? null : _logout,
              child: Text(l10n.uploadLogout),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (!_isLoggedIn) ...[
            Text(
              l10n.uploadAdminLoginHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.uploadAdminUsername,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.uploadAdminPassword,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              onSubmitted: (_) => _login(),
            ),
            if (_loginError != null) ...[
              const SizedBox(height: 8),
              Text(
                _loginError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loggingIn ? null : _login,
                child: _loggingIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.uploadAdminLogin),
              ),
            ),
          ] else ...[
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
                      onPressed: _loadAfterLogin,
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
                    routine: routine,
                    l10n: l10n,
                    trailing: const Icon(Icons.chevron_right),
                    onTap:
                        _uploading ? null : () => _editServerRoutine(routine),
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
                    routine: routine,
                    l10n: l10n,
                    trailing: FilledButton.tonal(
                      onPressed: _uploading
                          ? null
                          : () => _uploadLocalRoutine(routine),
                      child: Text(l10n.upload),
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
