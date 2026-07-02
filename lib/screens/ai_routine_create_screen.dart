import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../models/routine.dart';
import '../services/ai_routine_service.dart';
import '../services/rewarded_ad_gate.dart';
import '../services/routine_api_client.dart';
import '../utils/content_language.dart';
import 'routine_editor_screen.dart';

class AiRoutineCreateScreen extends StatefulWidget {
  const AiRoutineCreateScreen({
    super.key,
    required this.repository,
    required this.aiRoutineService,
  });

  final RoutineRepository repository;
  final AiRoutineService aiRoutineService;

  @override
  State<AiRoutineCreateScreen> createState() => _AiRoutineCreateScreenState();
}

class _AiRoutineCreateScreenState extends State<AiRoutineCreateScreen> {
  late final TextEditingController _promptController;
  bool _loading = false;
  bool _loadingAd = false;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    RewardedAdGate.preload();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context);
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiRoutineCreatePromptRequired)),
      );
      return;
    }

    setState(() => _loadingAd = true);
    final rewarded = await RewardedAdGate.show();
    if (!mounted) return;
    setState(() => _loadingAd = false);
    if (!rewarded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiRoutineCreateAdRequired)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final contentLanguage = ContentLanguage.current(
        systemLocale: Localizations.localeOf(context),
      );
      final routine = await widget.aiRoutineService.generateRoutine(
        prompt: prompt,
        contentLanguage: contentLanguage,
      );
      if (!mounted) return;
      setState(() => _loading = false);

      final saved = await Navigator.of(context).push<Routine>(
        MaterialPageRoute(
          builder: (_) => RoutineEditorScreen(
            repository: widget.repository,
            routine: routine,
            isNew: true,
          ),
        ),
      );
      if (!mounted) return;
      if (saved != null) {
        Navigator.of(context).pop(saved);
      }
    } on RoutineApiException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiRoutineCreateError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiRoutineCreateTitle),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              TextField(
                controller: _promptController,
                minLines: 8,
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: l10n.aiRoutineCreatePromptHint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: (_loading || _loadingAd) ? null : _submit,
                child: Text(l10n.aiRoutineCreateSubmit),
              ),
            ],
          ),
          if (_loadingAd)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.25),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.aiRoutineCreateAdLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_loading)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.25),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.aiRoutineCreateLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
