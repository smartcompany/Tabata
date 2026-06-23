import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../utils/duration_format.dart';

Future<int?> showDurationWheelPicker(
  BuildContext context, {
  required int initialSeconds,
  required int minSeconds,
  required int maxSeconds,
  required String title,
}) {
  return Navigator.of(context).push<int>(
    PageRouteBuilder(
      fullscreenDialog: true,
      opaque: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DurationWheelPickerPage(
          initialSeconds: initialSeconds.clamp(minSeconds, maxSeconds),
          minSeconds: minSeconds,
          maxSeconds: maxSeconds,
          title: title,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    ),
  );
}

class DurationWheelPickerPage extends StatefulWidget {
  const DurationWheelPickerPage({
    super.key,
    required this.initialSeconds,
    required this.minSeconds,
    required this.maxSeconds,
    required this.title,
  });

  final int initialSeconds;
  final int minSeconds;
  final int maxSeconds;
  final String title;

  @override
  State<DurationWheelPickerPage> createState() => _DurationWheelPickerPageState();
}

class _DurationWheelPickerPageState extends State<DurationWheelPickerPage> {
  static const _itemExtent = 52.0;

  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;
  late int _minutes;
  late int _seconds;
  int? _lastHapticTotal;

  int get _minMinute => widget.minSeconds ~/ 60;
  int get _maxMinute => widget.maxSeconds ~/ 60;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialSeconds ~/ 60;
    _seconds = widget.initialSeconds % 60;
    _clampSelection();
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes - _minMinute,
    );
    _secondController = FixedExtentScrollController(
      initialItem: _seconds - _minSecondForMinute(_minutes),
    );
    _lastHapticTotal = durationFromClock(_minutes, _seconds);
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  int _minSecondForMinute(int minute) {
    if (minute > widget.minSeconds ~/ 60) return 0;
    if (minute == widget.minSeconds ~/ 60) {
      return widget.minSeconds % 60;
    }
    return 0;
  }

  int _maxSecondForMinute(int minute) {
    if (minute < _maxMinute) return 59;
    return widget.maxSeconds % 60;
  }

  void _clampSelection() {
    _minutes = _minutes.clamp(_minMinute, _maxMinute);
    final minSec = _minSecondForMinute(_minutes);
    final maxSec = _maxSecondForMinute(_minutes);
    _seconds = _seconds.clamp(minSec, maxSec);
  }

  void _syncSecondWheel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_secondController.hasClients) return;
      final targetIndex = _seconds - _minSecondForMinute(_minutes);
      _secondController.jumpToItem(targetIndex);
    });
  }

  void _onMinuteChanged(int minute) {
    setState(() {
      _minutes = minute;
      _clampSelection();
      _syncSecondWheel();
      _maybeHaptic();
    });
  }

  void _onSecondChanged(int second) {
    setState(() {
      _seconds = second;
      _clampSelection();
      _maybeHaptic();
    });
  }

  void _maybeHaptic() {
    final total = durationFromClock(_minutes, _seconds);
    if (_lastHapticTotal == total) return;
    _lastHapticTotal = total;
    HapticFeedback.selectionClick();
  }

  void _done() {
    Navigator.of(context).pop(durationFromClock(_minutes, _seconds));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const accent = Color(0xFFCDDC39);
    final minSecond = _minSecondForMinute(_minutes);
    final maxSecond = _maxSecondForMinute(_minutes);

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
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DurationWheelColumn(
                            controller: _minuteController,
                            minValue: _minMinute,
                            maxValue: _maxMinute,
                            selectedValue: _minutes,
                            unitLabel: l10n.unitMinutes,
                            onSelectedItemChanged: _onMinuteChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DurationWheelColumn(
                            controller: _secondController,
                            minValue: minSecond,
                            maxValue: maxSecond,
                            selectedValue: _seconds,
                            unitLabel: l10n.unitSeconds,
                            onSelectedItemChanged: _onSecondChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      height: _itemExtent,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
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

class _DurationWheelColumn extends StatelessWidget {
  const _DurationWheelColumn({
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
                  final display = value.toString().padLeft(2, '0');
                  final selected = value == selectedValue;
                  return Center(
                    child: Text(
                      display,
                      style: TextStyle(
                        fontSize: selected ? 34 : 28,
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
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Text(
              unitLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
