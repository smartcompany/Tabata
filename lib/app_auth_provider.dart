import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:flutter/scheduler.dart';
import 'package:share_lib/share_lib_auth.dart';

import 'config/auth_config.dart' show kGoogleServerClientId;
import 'features/legal/privacy_processing_consent.dart';
import 'models/user.dart';
import 'services/tabata_auth_api_service.dart';

class AppAuthProvider extends AuthProvider<User> {
  static AppAuthProvider? _instance;

  static AppAuthProvider get shared {
    _instance ??= AppAuthProvider._();
    return _instance!;
  }

  AppAuthProvider._()
      : super(
          firebaseAuth: FirebaseAuth.instance,
          authService: TabataAuthApiService.shared,
          googleServerClientId: kGoogleServerClientId,
        ) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initialize();
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        fbUser.getIdToken().then((token) {
          if (token != null) {
            TabataAuthApiService.shared.setToken(token);
          }
        });
      }
    });
  }

  Future<void> ensureInitialized() async {
    if (!isInitialized) {
      await initialize();
    }
    while (isInitializing) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  /// 서버에서 최신 프로필을 불러옵니다. 등록된 프로필이 있으면 메모리에 반영합니다.
  Future<User?> refreshUserProfile({bool forceRefreshToken = false}) async {
    await ensureInitialized();
    if (!isLoggedIn()) return null;

    try {
      final token = await getIdToken(forceRefreshToken);
      if (token == null || token.isEmpty) {
        return userProfile;
      }
      TabataAuthApiService.shared.setToken(token);
      final profile = await TabataAuthApiService.shared.getCurrentUser();
      setUserProfile(profile);
      return profile;
    } on Exception catch (error) {
      if (error.toString().contains('PROFILE_NOT_SETUP')) {
        setUserProfile(null);
        return null;
      }
      rethrow;
    }
  }

  bool needsProfileSetupScreen(User? profile) {
    if (profile == null) return true;
    return profile.fullName.trim().length < 2;
  }

  /// 서버 데이터 삭제 후 로컬·소셜·Firebase 세션을 정리합니다.
  Future<void> deleteAccountCompletely() async {
    await ensureInitialized();
    if (!isLoggedIn()) {
      return;
    }

    final token = await getIdToken(true);
    if (token == null || token.isEmpty) {
      throw Exception('AUTH_REQUIRED');
    }

    TabataAuthApiService.shared.setToken(token);
    await TabataAuthApiService.shared.deleteAccount();

    try {
      await deleteAccount();
    } on FirebaseAuthException catch (error) {
      if (error.code != 'user-not-found' && error.code != 'no-current-user') {
        rethrow;
      }
      await FirebaseAuth.instance.signOut();
      setUserProfile(null);
      TabataAuthApiService.shared.setToken('');
      notifyListeners();
    }

    await clearPrivacyProcessingConsent();
  }
}
