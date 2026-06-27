import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../app_auth_provider.dart';

Future<bool> confirmAndDeleteAccount(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteAccountTitle),
      content: Text(l10n.deleteAccountMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.deleteAccountConfirm),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) {
    return false;
  }

  try {
    await AppAuthProvider.shared.deleteAccountCompletely();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.deleteAccountSuccess)),
    );
    return true;
  } on FirebaseAuthException catch (error) {
    if (!context.mounted) return false;
    final message = error.code == 'requires-recent-login'
        ? l10n.deleteAccountRecentLoginRequired
        : l10n.deleteAccountFailed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    return false;
  } catch (_) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deleteAccountFailed)),
    );
    return false;
  }
}
