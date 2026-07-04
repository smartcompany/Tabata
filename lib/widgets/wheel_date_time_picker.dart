import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

/// Scroll-wheel date/time picker with roomy columns for easier touch control.
abstract final class WheelDateTimePicker {
  static const _dateItemExtent = 42.0;
  static const _datePickerHeight = 252.0;
  static const _timePickerHeight = 272.0;

  static Future<DateTime?> showDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime minimumDate,
    required DateTime maximumDate,
    String? title,
  }) {
    return _show(
      context,
      title: title,
      pickerHeight: _datePickerHeight,
      builder: (onChanged, _) => CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(
          textTheme: CupertinoTheme.of(context).textTheme.copyWith(
                dateTimePickerTextStyle: const TextStyle(fontSize: 21),
              ),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _clampDate(initialDate, minimumDate, maximumDate),
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          itemExtent: _dateItemExtent,
          onDateTimeChanged: onChanged,
        ),
      ),
      initialValue: _dateOnly(initialDate),
      normalize: _dateOnly,
    );
  }

  static Future<DateTime?> showTime(
    BuildContext context, {
    required TimeOfDay initialTime,
    String? title,
  }) {
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    final initial = DateTime(2000, 1, 1, initialTime.hour, initialTime.minute);

    return _show(
      context,
      title: title,
      pickerHeight: _timePickerHeight,
      builder: (onChanged, _) => _ScrollWheelTimePicker(
        initialTime: initialTime,
        use24hFormat: use24h,
        onChanged: onChanged,
      ),
      initialValue: initial,
      normalize: (value) =>
          DateTime(2000, 1, 1, value.hour, value.minute),
    );
  }

  static Future<DateTime?> _show(
    BuildContext context, {
    required String? title,
    required double pickerHeight,
    required Widget Function(ValueChanged<DateTime> onChanged, DateTime value)
        builder,
    required DateTime initialValue,
    required DateTime Function(DateTime value) normalize,
  }) {
    var picked = normalize(initialValue);
    final l10n = AppLocalizations.of(context);

    return showModalBottomSheet<DateTime>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(l10n.cancel),
                  ),
                  if (title != null) ...[
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                      ),
                    ),
                  ] else
                    const Spacer(),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(sheetContext, normalize(picked)),
                    child: Text(l10n.confirm),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: pickerHeight,
              child: builder((value) => picked = normalize(value), picked),
            ),
            SizedBox(height: MediaQuery.viewPaddingOf(sheetContext).bottom),
          ],
        );
      },
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _clampDate(
    DateTime value,
    DateTime minimumDate,
    DateTime maximumDate,
  ) {
    final date = _dateOnly(value);
    final min = _dateOnly(minimumDate);
    final max = _dateOnly(maximumDate);
    if (date.isBefore(min)) return min;
    if (date.isAfter(max)) return max;
    return date;
  }
}

class _ScrollWheelTimePicker extends StatefulWidget {
  const _ScrollWheelTimePicker({
    required this.initialTime,
    required this.use24hFormat,
    required this.onChanged,
  });

  final TimeOfDay initialTime;
  final bool use24hFormat;
  final ValueChanged<DateTime> onChanged;

  @override
  State<_ScrollWheelTimePicker> createState() => _ScrollWheelTimePickerState();
}

class _ScrollWheelTimePickerState extends State<_ScrollWheelTimePicker> {
  static const _itemExtent = 48.0;
  static const _wheelTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.1,
  );

  late int _hour24;
  late int _minute;
  late int _hour12;
  late bool _isPm;

  late FixedExtentScrollController _minuteController;
  FixedExtentScrollController? _periodController;
  FixedExtentScrollController? _hourController;

  @override
  void initState() {
    super.initState();
    _hour24 = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _isPm = _hour24 >= 12;
    _hour12 = _hour24 == 0 ? 12 : (_hour24 > 12 ? _hour24 - 12 : _hour24);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
    _initHourControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  void _initHourControllers() {
    if (widget.use24hFormat) {
      _hourController = FixedExtentScrollController(initialItem: _hour24);
      return;
    }
    _periodController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _periodController?.dispose();
    _hourController?.dispose();
    super.dispose();
  }

  int _toHour24({required int hour12, required bool isPm}) {
    if (isPm) {
      return hour12 == 12 ? 12 : hour12 + 12;
    }
    return hour12 == 12 ? 0 : hour12;
  }

  void _syncHour24From12h() {
    _hour24 = _toHour24(hour12: _hour12, isPm: _isPm);
  }

  void _emit() {
    widget.onChanged(DateTime(2000, 1, 1, _hour24, _minute));
  }

  Widget _wheelColumn({
    required FixedExtentScrollController controller,
    required List<Widget> children,
    required ValueChanged<int> onSelectedItemChanged,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CupertinoPicker(
          scrollController: controller,
          itemExtent: _itemExtent,
          squeeze: 1.0,
          magnification: 1.06,
          diameterRatio: 1.35,
          useMagnifier: true,
          onSelectedItemChanged: onSelectedItemChanged,
          children: children,
        ),
      ),
    );
  }

  Widget _wheelLabel(String text) {
    return Center(
      child: Text(
        text,
        style: _wheelTextStyle,
        maxLines: 1,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _wheelLabelPadded(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: _wheelLabel(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final amLabel = material.anteMeridiemAbbreviation;
    final pmLabel = material.postMeridiemAbbreviation;

    if (widget.use24hFormat) {
      return Row(
        children: [
          _wheelColumn(
            flex: 3,
            controller: _hourController!,
            onSelectedItemChanged: (index) {
              setState(() => _hour24 = index);
              _emit();
            },
            children: List.generate(
              24,
              (index) => _wheelLabel(index.toString().padLeft(2, '0')),
            ),
          ),
          _wheelColumn(
            flex: 3,
            controller: _minuteController,
            onSelectedItemChanged: (index) {
              setState(() => _minute = index);
              _emit();
            },
            children: List.generate(
              60,
              (index) => _wheelLabel(index.toString().padLeft(2, '0')),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _wheelColumn(
          flex: 4,
          controller: _periodController!,
          onSelectedItemChanged: (index) {
            setState(() {
              _isPm = index == 1;
              _syncHour24From12h();
            });
            _emit();
          },
          children: [
            _wheelLabelPadded(amLabel),
            _wheelLabelPadded(pmLabel),
          ],
        ),
        _wheelColumn(
          flex: 3,
          controller: _hourController!,
          onSelectedItemChanged: (index) {
            setState(() {
              _hour12 = index + 1;
              _syncHour24From12h();
            });
            _emit();
          },
          children: List.generate(
            12,
            (index) => _wheelLabel('${index + 1}'),
          ),
        ),
        _wheelColumn(
          flex: 3,
          controller: _minuteController,
          onSelectedItemChanged: (index) {
            setState(() => _minute = index);
            _emit();
          },
          children: List.generate(
            60,
            (index) => _wheelLabel(index.toString().padLeft(2, '0')),
          ),
        ),
      ],
    );
  }
}
