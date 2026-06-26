import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

/// Dismisses the keyboard when tapping outside inputs and shows a Done bar
/// above the software keyboard while text fields are focused.
class KeyboardDismissScope extends StatelessWidget {
  const KeyboardDismissScope({super.key, required this.child});

  final Widget child;

  static void dismiss(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => dismiss(context),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          child,
          if (bottomInset > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset,
              child: Material(
                elevation: 2,
                color: Theme.of(context).colorScheme.surface,
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => dismiss(context),
                        child: Text(l10n.done),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
