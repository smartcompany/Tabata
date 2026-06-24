import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

Future<int?> showIntegerWheelPicker(
  BuildContext context, {
  required int initialValue,
  required int minValue,
  required int maxValue,
  required String title,
  required String unitLabel,
}) {
  return Navigator.of(context).push<int>(
    PageRouteBuilder(
      fullscreenDialog: true,
      opaque: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return IntegerWheelPickerPage(
          initialValue: initialValue.clamp(minValue, maxValue),
          minValue: minValue,
          maxValue: maxValue,
          title: title,
          unitLabel: unitLabel,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    ),
  );
}

class IntegerWheelPickerPage extends StatefulWidget {
  const IntegerWheelPickerPage({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.title,
    required this.unitLabel,
  });

  final int initialValue;
  final int minValue;
  final int maxValue;
  final String title;
  final String unitLabel;

  @override
  State<IntegerWheelPickerPage> createState() => _IntegerWheelPickerPageState();
}

class _IntegerWheelPickerPageState extends State<IntegerWheelPickerPage> {
  static const _itemExtent = 52.0;

  late FixedExtentScrollController _controller;
  late int _value;
  int? _lastHapticValue;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = FixedExtentScrollController(
      initialItem: _value - widget.minValue,
    );
    _lastHapticValue = _value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onValueChanged(int value) {
    setState(() => _value = value);
    if (_lastHapticValue == value) return;
    _lastHapticValue = value;
    HapticFeedback.selectionClick();
  }

  void _done() {
    Navigator.of(context).pop(_value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const accent = Color(0xFFCDDC39);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n.back,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _done,
                    child: Text(
                      l10n.done,
                      style: const TextStyle(
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: _IntegerWheelColumn(
                      controller: _controller,
                      minValue: widget.minValue,
                      maxValue: widget.maxValue,
                      selectedValue: _value,
                      unitLabel: widget.unitLabel,
                      onSelectedItemChanged: _onValueChanged,
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      height: _itemExtent,
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntegerWheelColumn extends StatelessWidget {
  const _IntegerWheelColumn({
    required this.controller,
    required this.minValue,
    required this.maxValue,
    required this.selectedValue,
    required this.unitLabel,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final int minValue;
  final int maxValue;
  final int selectedValue;
  final String unitLabel;
  final ValueChanged<int> onSelectedItemChanged;

  static const _itemExtent = 52.0;

  int get _itemCount => maxValue - minValue + 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemExtent * 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: _itemExtent,
              perspective: 0.0028,
              diameterRatio: 1.4,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                onSelectedItemChanged(minValue + index);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _itemCount,
                builder: (context, index) {
                  final value = minValue + index;
                  final selected = value == selectedValue;
                  return Center(
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: selected ? 40 : 30,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.28),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              unitLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
