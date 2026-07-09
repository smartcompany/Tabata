import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../services/health_activity_catalog.dart';
import '../services/health_workout_recorder.dart';
import '../utils/health_platform_l10n.dart';
import 'health_app_info.dart';

class HealthActivityTypePicker extends StatefulWidget {
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

  @override
  State<HealthActivityTypePicker> createState() =>
      _HealthActivityTypePickerState();
}

class _HealthActivityTypePickerState extends State<HealthActivityTypePicker> {
  static const _itemPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const _menuDividerValue = '__health_activity_menu_divider__';
  static const _menuSectionValue = '__health_activity_menu_section__';
  static const _menuDividerLabel = '────────────────────────';

  bool? _healthAppReady;

  @override
  void initState() {
    super.initState();
    _loadHealthAppReady();
  }

  Future<void> _loadHealthAppReady() async {
    if (!HealthPlatformL10n.isAndroid) {
      setState(() => _healthAppReady = true);
      return;
    }
    final ready = await HealthWorkoutRecorder.isHealthAppReady();
    if (!mounted) return;
    setState(() => _healthAppReady = ready);
  }

  String? _selectedId() {
    if (widget.value == null || widget.value!.isEmpty) return null;
    if (HealthActivityCatalog.toWorkoutType(widget.value) != null) {
      return widget.value;
    }
    return null;
  }

  String _selectedLabel(AppLocalizations l10n) {
    final id = _selectedId();
    if (id == null) {
      return HealthPlatformL10n(l10n).activityTypeNone;
    }
    return HealthActivityCatalog.labelFor(l10n, id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final platform = HealthPlatformL10n(l10n);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activityOptions = HealthActivityCatalog.options(l10n);
    final menuEntries = HealthActivityCatalog.menuEntries(l10n);
    final usesHealthConnectList = HealthActivityCatalog.usesHealthConnectList;
    final selectedValue = _selectedId();
    final isSelected = selectedValue != null;
    final healthAppReady = _healthAppReady;

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (widget.showHeartStatus) ...[
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
            if (HealthPlatformL10n.isAndroid && healthAppReady != null) ...[
              const SizedBox(height: 6),
              Text(
                healthAppReady
                    ? platform.healthConnectReadyStatus
                    : platform.healthConnectUnavailableStatus,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: healthAppReady
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (HealthPlatformL10n.isAndroid && healthAppReady == false)
              OutlinedButton.icon(
                onPressed: () async {
                  await HealthWorkoutRecorder.promptInstallHealthConnect();
                  await _loadHealthAppReady();
                },
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text(l10n.healthConnectInstallPromptInstall),
              )
            else if (healthAppReady != false)
              DropdownMenu<String?>(
                key: ValueKey<String?>('health-type-$selectedValue'),
                width: menuWidth,
                initialSelection: selectedValue,
                expandedInsets: EdgeInsets.zero,
                requestFocusOnTap: false,
                hintText: platform.activityTypeNone,
                textStyle: theme.textTheme.bodyLarge,
                menuStyle: MenuStyle(
                  alignment: AlignmentDirectional.bottomStart,
                  maximumSize: WidgetStatePropertyAll(
                    Size(menuWidth, HealthActivityCatalog.usesHealthConnectList ? 420 : 360),
                  ),
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
                    label: platform.activityTypeNone,
                    style: MenuItemButton.styleFrom(padding: _itemPadding),
                  ),
                  if (usesHealthConnectList)
                    for (final entry in menuEntries)
                      switch (entry.kind) {
                        HealthActivityMenuEntryKind.sectionHeader =>
                          DropdownMenuEntry<String?>(
                            value: _menuSectionValue,
                            label: entry.label,
                            enabled: false,
                            style: MenuItemButton.styleFrom(
                              padding: _itemPadding,
                            ),
                          ),
                        HealthActivityMenuEntryKind.divider =>
                          DropdownMenuEntry<String?>(
                            value: _menuDividerValue,
                            label: _menuDividerLabel,
                            enabled: false,
                            style: MenuItemButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        HealthActivityMenuEntryKind.option =>
                          DropdownMenuEntry<String?>(
                            value: entry.id,
                            label: entry.label,
                            style: MenuItemButton.styleFrom(
                              padding: _itemPadding,
                            ),
                          ),
                      }
                  else
                    for (final option in activityOptions)
                      DropdownMenuEntry<String?>(
                        value: option.id,
                        label: option.label,
                        style: MenuItemButton.styleFrom(padding: _itemPadding),
                      ),
                ],
                onSelected: (value) {
                  if (value == _menuDividerValue ||
                      value == _menuSectionValue) {
                    return;
                  }
                  widget.onChanged(value);
                },
              ),
          ],
        );
      },
    );
  }
}
