import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../utils/health_platform_l10n.dart';

Future<void> showHealthAppInfoDialog(
  BuildContext context, {
  required String body,
}) {
  final platform = HealthPlatformL10n(AppLocalizations.of(context));
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(platform.infoTitle),
      content: SingleChildScrollView(
        child: Text(body),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(AppLocalizations.of(context).confirm),
        ),
      ],
    ),
  );
}

class HealthAppInfoIconButton extends StatelessWidget {
  const HealthAppInfoIconButton({
    super.key,
    required this.detailText,
  });

  final String detailText;

  @override
  Widget build(BuildContext context) {
    final platform = HealthPlatformL10n(AppLocalizations.of(context));
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      tooltip: platform.infoTitle,
      onPressed: () => showHealthAppInfoDialog(context, body: detailText),
    );
  }
}

class HealthAppLabel extends StatelessWidget {
  const HealthAppLabel({
    super.key,
    required this.detailText,
    this.style,
  });

  final String detailText;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final platform = HealthPlatformL10n(AppLocalizations.of(context));
    return Row(
      children: [
        Expanded(
          child: Text(
            platform.label,
            style: style,
          ),
        ),
        HealthAppInfoIconButton(detailText: detailText),
      ],
    );
  }
}
