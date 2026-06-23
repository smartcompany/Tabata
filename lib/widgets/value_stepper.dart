import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

class ValueStepper extends StatefulWidget {
  const ValueStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.suffix = '',
    this.pixelsPerStep = 12,
  });

  final int value;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final int pixelsPerStep;
  final ValueChanged<int> onChanged;

  @override
  State<ValueStepper> createState() => _ValueStepperState();
}

class _ValueStepperState extends State<ValueStepper> {
  double _dragPixels = 0;

  double get _progress {
    if (widget.max <= widget.min) return 1;
    return (widget.value - widget.min) / (widget.max - widget.min);
  }

  void _applyDelta(int delta) {
    if (delta == 0) return;
    final next = (widget.value + delta).clamp(widget.min, widget.max);
    if (next == widget.value) return;
    HapticFeedback.selectionClick();
    widget.onChanged(next);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragPixels += details.delta.dx;
    final threshold = widget.pixelsPerStep.toDouble();
    while (_dragPixels >= threshold) {
      _dragPixels -= threshold;
      _applyDelta(widget.step);
    }
    while (_dragPixels <= -threshold) {
      _dragPixels += threshold;
      _applyDelta(-widget.step);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _dragPixels = 0;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() < 400) return;
    final extraSteps = (velocity.abs() / 800).round().clamp(1, 5);
    _applyDelta(velocity.isNegative ? -extraSteps * widget.step : extraSteps * widget.step);
  }

  Future<void> _showDirectInput() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${widget.value}');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterValueTitle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              if (parsed == null) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context, parsed.clamp(widget.min, widget.max));
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (result != null) widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showDirectInput,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.value}${widget.suffix}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.dragToAdjustHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
