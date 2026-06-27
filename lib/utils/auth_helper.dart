import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_lib/share_lib_auth.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../app_auth_provider.dart';
import '../config/auth_config.dart';
import '../features/legal/privacy_processing_consent.dart';
import '../models/user.dart';
import '../screens/profile_setup_screen.dart';

class AuthHelper {
  static Future<bool> requireAuth(BuildContext context) async {
    if (!AppAuthProvider.shared.isLoggedIn()) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ListenableProvider<AuthProvider<User>>.value(
            value: AppAuthProvider.shared,
            child: AuthScreen<User>(config: authConfig),
          ),
          fullscreenDialog: true,
        ),
      );
      if (result != true) return false;
      if (!AppAuthProvider.shared.isLoggedIn() &&
          AppAuthProvider.shared.kakaoId == null) {
        return false;
      }
    }

    if (!context.mounted) return false;

    if (!await _ensureProfileReady(context)) return false;

    if (!context.mounted) return false;

    if (await isPrivacyProcessingConsentAccepted()) return true;
    if (!context.mounted) return false;

    final consented = await ensurePrivacyProcessingConsent(context);
    if (!context.mounted) return false;
    if (consented) return true;

    await AppAuthProvider.shared.logout();
    return false;
  }

  static Future<bool> _ensureProfileReady(BuildContext context) async {
    final auth = AppAuthProvider.shared;

    if (!auth.isLoggedIn()) {
      if (auth.kakaoId == null) return false;
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );
      return result == true;
    }

    User? profile;
    try {
      profile = await auth.refreshUserProfile();
    } catch (_) {
      try {
        profile = await auth.refreshUserProfile(forceRefreshToken: true);
      } catch (_) {
        profile = auth.userProfile;
        if (profile != null && !auth.needsProfileSetupScreen(profile)) {
          return true;
        }
        if (!context.mounted) return false;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileLoadError)),
        );
        return false;
      }
    }

    if (!auth.needsProfileSetupScreen(profile)) {
      return true;
    }

    if (!context.mounted) return false;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
    );
    if (result != true) return false;

    try {
      await auth.refreshUserProfile(forceRefreshToken: true);
    } catch (_) {
      // ProfileSetupScreen already updates in-memory profile on success.
    }
    return true;
  }
}
