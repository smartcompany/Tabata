import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/health_activity_type.dart';

class HealthActivityTypePicker extends StatelessWidget {
  const HealthActivityTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  static const _itemPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selectedValue = RoutineHealthActivityType.fromId(value)?.id;

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.healthActivityTypeSection,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.healthActivityTypeHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String?>(
              key: ValueKey<String?>(selectedValue),
              width: menuWidth,
              initialSelection: selectedValue,
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              menuStyle: MenuStyle(
                alignment: AlignmentDirectional.bottomStart,
                maximumSize: WidgetStatePropertyAll(Size(menuWidth, 360)),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              dropdownMenuEntries: [
                DropdownMenuEntry<String?>(
                  value: null,
                  label: l10n.healthActivityTypeNone,
                  style: MenuItemButton.styleFrom(padding: _itemPadding),
                ),
                for (final type in RoutineHealthActivityType.values)
                  DropdownMenuEntry<String?>(
                    value: type.id,
                    label: type.label(l10n),
                    style: MenuItemButton.styleFrom(padding: _itemPadding),
                  ),
              ],
              onSelected: onChanged,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.healthActivityTypeHelper,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        );
      },
    );
  }
}
