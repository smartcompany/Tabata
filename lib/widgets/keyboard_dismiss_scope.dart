import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Dismisses the keyboard when tapping outside inputs and optionally shows an
/// accessory bar flush against the top edge of the software keyboard.
///
/// When [showAccessoryBar] is true this widget consumes bottom viewInsets and
/// places the bar in a [Column] above the keyboard gap. That avoids wrapping the
/// navigator [Overlay] in a [Stack], which breaks Leader/Follower paint order.
class KeyboardDismissScope extends StatelessWidget {
  const KeyboardDismissScope({
    super.key,
    required this.child,
    this.showAccessoryBar = true,
  });

  final Widget child;

  /// When false, only tap-outside dismiss is enabled (no keyboard accessory).
  final bool showAccessoryBar;

  static void dismiss(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static bool get _useIosAccessoryStyle => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final showBar = showAccessoryBar && bottomInset > 0;

    final content = GestureDetector(
      onTap: () => dismiss(context),
      behavior: HitTestBehavior.translucent,
      child: child,
    );

    if (!showBar) {
      return content;
    }

    return MediaQuery(
      data: mediaQuery.removeViewInsets(removeBottom: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: content),
          _KeyboardAccessoryBar(onDismiss: () => dismiss(context)),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}

class _KeyboardAccessoryBar extends StatelessWidget {
  const _KeyboardAccessoryBar({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final iosAccessory = KeyboardDismissScope._useIosAccessoryStyle;
    final theme = Theme.of(context);

    return Material(
      elevation: 0,
      color: iosAccessory
          ? const Color(0xFFD1D3D9)
          : theme.colorScheme.surfaceContainerHighest,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: iosAccessory
                  ? const Color(0xFFAEAEB2)
                  : theme.dividerColor,
              width: iosAccessory ? 0.33 : 1,
            ),
          ),
        ),
        child: SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              button: true,
              label: MaterialLocalizations.of(context).closeButtonTooltip,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDismiss,
                  child: SizedBox(
                    width: 52,
                    height: 44,
                    child: Center(
                      child: Icon(
                        Icons.keyboard_hide_outlined,
                        size: 28,
                        color: iosAccessory
                            ? const Color(0xFF007AFF)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
