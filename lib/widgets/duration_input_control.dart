import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../utils/duration_format.dart';
import 'duration_wheel_picker.dart';

class DurationInputControl extends StatelessWidget {
  const DurationInputControl({
    super.key,
    required this.valueSec,
    required this.minSec,
    required this.maxSec,
    required this.pickerTitle,
    required this.onChanged,
  });

  final int valueSec;
  final int minSec;
  final int maxSec;
  final String pickerTitle;
  final ValueChanged<int> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showDurationWheelPicker(
      context,
      initialSeconds: valueSec,
      minSeconds: minSec,
      maxSeconds: maxSec,
      title: pickerTitle,
    );
    if (result == null) return;
    onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatDurationClock(valueSec),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.unfold_more,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.tapToSetDuration,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
