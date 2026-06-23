import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../l10n/l10n_extensions.dart';
import '../services/routine_json_codec.dart';
import '../services/routine_share_service.dart';

class ImportRoutineScreen extends StatefulWidget {
  const ImportRoutineScreen({super.key});

  @override
  State<ImportRoutineScreen> createState() => _ImportRoutineScreenState();
}

class _ImportRoutineScreenState extends State<ImportRoutineScreen> {
  final _controller = TextEditingController();
  final _shareService = RoutineShareService();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _import() {
    final l10n = AppLocalizations.of(context);
    try {
      final routine = _shareService.parse(_controller.text);
      Navigator.of(context).pop(routine);
    } on RoutineJsonException catch (error) {
      setState(() => _error = error.error.message(l10n));
    } catch (_) {
      setState(() => _error = l10n.errorInvalidRoutineJson);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importRoutineTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.importRoutineHint),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: l10n.importRoutineJsonHint,
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _import,
              child: Text(l10n.import),
            ),
          ],
        ),
      ),
    );
  }
}
