import 'package:flutter/material.dart';

import 'integer_wheel_picker.dart';

class IntegerInputControl extends StatelessWidget {
  const IntegerInputControl({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.pickerTitle,
    required this.unitLabel,
    required this.hintText,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final String pickerTitle;
  final String unitLabel;
  final String hintText;
  final ValueChanged<int> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showIntegerWheelPicker(
      context,
      initialValue: value,
      minValue: min,
      maxValue: max,
      title: pickerTitle,
      unitLabel: unitLabel,
    );
    if (result == null) return;
    onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
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
                    '$value$unitLabel',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 0.5,
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
                hintText,
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
