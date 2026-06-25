import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../models/routine.dart';
import '../services/admin_session.dart';
import '../services/routine_api_client.dart';
import '../utils/duration_calculator.dart';

class UploadRoutineScreen extends StatefulWidget {
  const UploadRoutineScreen({
    super.key,
    required this.repository,
    required this.apiClient,
    required this.adminSession,
  });

  final RoutineRepository repository;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;

  @override
  State<UploadRoutineScreen> createState() => _UploadRoutineScreenState();
}

class _UploadRoutineScreenState extends State<UploadRoutineScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Routine> _localRoutines = [];
  Set<String> _serverIds = {};
  bool _loading = true;
  bool _loggingIn = false;
  bool _uploading = false;
  String? _loadError;
  String? _loginError;

  bool get _isLoggedIn => widget.adminSession.isLoggedIn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final ids = await widget.apiClient.fetchProfileIds();
      if (!mounted) return;
      setState(() {
        _serverIds = ids.toSet();
        _localRoutines = widget.repository.loadLocalOnly();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _localRoutines = widget.repository.loadLocalOnly();
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
    setState(() {});
  }

  Future<void> _upload(Routine routine) async {
    final l10n = AppLocalizations.of(context);
    final token = widget.adminSession.token;
    if (token == null) return;

    final isUpdate = _serverIds.contains(routine.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.uploadConfirmTitle),
        content: Text(
          isUpdate
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
      final result = await widget.apiClient.uploadProfile(
        routine: routine,
        adminToken: token,
      );
      if (!mounted) return;

      setState(() {
        _uploading = false;
        _serverIds = {..._serverIds, routine.id};
      });

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (_loadError != null) ...[
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      title: Text(_loadError!),
                      trailing: TextButton(
                        onPressed: _load,
                        child: Text(l10n.retry),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
                  const SizedBox(height: 24),
                ] else ...[
                  Text(
                    l10n.uploadSelectRoutine,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_localRoutines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text(l10n.uploadNoLocalRoutines)),
                  )
                else
                  ..._localRoutines.map((routine) {
                    final onServer = _serverIds.contains(routine.id);
                    final duration = routineDurationSec(routine);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          title: Text(routine.title),
                          subtitle: Text(
                            l10n.routineCountDuration(
                              routine.orderedExercises.length,
                              formatDurationShort(duration, l10n),
                            ),
                          ),
                          trailing: _isLoggedIn
                              ? FilledButton.tonal(
                                  onPressed: _uploading
                                      ? null
                                      : () => _upload(routine),
                                  child: Text(
                                    onServer ? l10n.uploadUpdate : l10n.upload,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
