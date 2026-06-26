import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_lib/share_lib_auth.dart';

import '../app_auth_provider.dart';
import '../config/auth_config.dart';
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
    }

    if (!context.mounted) return false;

    if (AppAuthProvider.shared.needProfileSetup()) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );
      return result == true;
    }

    return true;
  }
}
