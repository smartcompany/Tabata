import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/health_activity_type.dart';
import '../utils/health_platform_l10n.dart';
import 'health_app_info.dart';

class HealthActivityTypePicker extends StatelessWidget {
  const HealthActivityTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.showHeartStatus = false,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  /// When true, shows a filled/outline heart beside the header label.
  final bool showHeartStatus;

  static const _itemPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  String _selectedLabel(AppLocalizations l10n) {
    final type = RoutineHealthActivityType.fromId(value);
    if (type == null) return l10n.healthActivityTypeNone;
    return type.label(l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final platform = HealthPlatformL10n(l10n);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedValue = RoutineHealthActivityType.fromId(value)?.id;
    final isSelected = selectedValue != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (showHeartStatus) ...[
                  Icon(
                    isSelected ? Icons.favorite : Icons.favorite_outline,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    platform.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                HealthAppInfoIconButton(
                  detailText: isSelected
                      ? platform.routineWillSaveDetail(_selectedLabel(l10n))
                      : platform.activityTypeDetail,
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownMenu<String?>(
              key: ValueKey<String?>('health-type-$selectedValue'),
              width: menuWidth,
              initialSelection: selectedValue,
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              hintText: l10n.healthActivityTypeNone,
              textStyle: theme.textTheme.bodyLarge,
              menuStyle: MenuStyle(
                alignment: AlignmentDirectional.bottomStart,
                maximumSize: WidgetStatePropertyAll(Size(menuWidth, 360)),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
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
          ],
        );
      },
    );
  }
}
