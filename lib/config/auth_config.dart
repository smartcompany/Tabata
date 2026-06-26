import 'package:flutter/material.dart';
import 'package:share_lib/share_lib_auth.dart';

import '../models/user.dart';
import '../screens/profile_setup_screen.dart';

/// Android Google 로그인 idToken 검증용 Web OAuth 클라이언트 ID.
/// Firebase Console → Authentication → Google → Web SDK configuration 에서 확인.
const String kGoogleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '247485339323-nkvpl0mj62k1145n0qgq41jtt368oj7t.apps.googleusercontent.com',
);

const _primaryColor = Color(0xFFE53935);

final authConfig = AuthConfig(
  primaryColor: _primaryColor,
  textPrimaryColor: const Color(0xFF1A1A1A),
  textSecondaryColor: const Color(0xFF666666),
  textTertiaryColor: const Color(0xFF999999),
  dividerColor: const Color(0xFFE0E0E0),
  backgroundColor: Colors.white,
  enableAppleLogin: true,
  enableGoogleLogin: true,
  enableKakaoLogin: true,
  shouldShowProfileSetup: (user) {
    final profile = user as User;
    return profile.fullName.trim().length < 2;
  },
  profileSetupScreenBuilder: (context) => const ProfileSetupScreen(),
);
