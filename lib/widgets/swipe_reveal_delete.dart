import 'package:flutter/material.dart';

/// Reveals a trailing action when swiped left (right-to-left).
class SwipeRevealDelete extends StatefulWidget {
  const SwipeRevealDelete({
    super.key,
    required this.itemKey,
    required this.openItemKey,
    required this.onOpenChanged,
    required this.onDelete,
    required this.deleteLabel,
    required this.child,
  });

  final String itemKey;
  final String? openItemKey;
  final ValueChanged<String?> onOpenChanged;
  final VoidCallback onDelete;
  final String deleteLabel;
  final Widget child;

  @override
  State<SwipeRevealDelete> createState() => _SwipeRevealDeleteState();
}

class _SwipeRevealDeleteState extends State<SwipeRevealDelete> {
  static const _actionWidth = 88.0;
  double _dragOffset = 0;

  bool get _isOpen => widget.openItemKey == widget.itemKey;

  @override
  void didUpdateWidget(covariant SwipeRevealDelete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isOpen && _dragOffset != 0) {
      _dragOffset = 0;
    } else if (_isOpen && _dragOffset != -_actionWidth) {
      _dragOffset = -_actionWidth;
    }
  }

  void _setOffset(double offset) {
    setState(() => _dragOffset = offset.clamp(-_actionWidth, 0));
  }

  void _snapOpen(bool open) {
    widget.onOpenChanged(open ? widget.itemKey : null);
    setState(() => _dragOffset = open ? -_actionWidth : 0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _actionWidth,
                child: Material(
                  color: colorScheme.error,
                  child: InkWell(
                    onTap: widget.onDelete,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: colorScheme.onError,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.deleteLabel,
                            style: TextStyle(
                              color: colorScheme.onError,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (widget.openItemKey != null &&
                  widget.openItemKey != widget.itemKey) {
                widget.onOpenChanged(null);
              }
              _setOffset(_dragOffset + details.delta.dx);
            },
            onHorizontalDragEnd: (details) {
              final shouldOpen =
                  _dragOffset < -_actionWidth / 2 ||
                  details.primaryVelocity != null &&
                      details.primaryVelocity! < -200;
              _snapOpen(shouldOpen);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(_dragOffset, 0, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
