import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics wrapper for retention and funnel metrics.
abstract final class AppAnalyticsService {
  static FirebaseAnalytics? _analytics;
  static bool _skipInitialAuthEvent = true;
  static String? _lastLoggedAuthUid;

  static Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
      await logAppOpen();
      FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    } catch (error) {
      debugPrint('AppAnalytics init error: $error');
    }
  }

  static Future<void> logAppOpen() async {
    try {
      await _analytics?.logAppOpen();
    } catch (error) {
      debugPrint('Analytics logAppOpen error: $error');
    }
  }

  static Future<void> logOnboardingComplete({required String path}) async {
    await _logEvent('onboarding_complete', {'path': path});
  }

  static Future<void> logWorkoutComplete({
    required int durationSec,
    required int exerciseCount,
    String? routineId,
  }) async {
    await _logEvent('workout_complete', {
      'duration_sec': durationSec,
      'exercise_count': exerciseCount,
      if (routineId != null && routineId.isNotEmpty) 'routine_id': routineId,
    });
  }

  /// [source]: catalog, catalog_detail, onboarding, shared_link
  static Future<void> logRoutineDownload({
    required String source,
    String? catalogId,
    int count = 1,
  }) async {
    await _logEvent('routine_download', {
      'source': source,
      'count': count,
      if (catalogId != null && catalogId.isNotEmpty) 'catalog_id': catalogId,
    });
  }

  /// [shareType]: routine, app — [channel]: kakao, system
  static Future<void> logRoutineShare({
    required String shareType,
    required String channel,
  }) async {
    await _logEvent('routine_share', {
      'share_type': shareType,
      'channel': channel,
    });
  }

  static Future<void> _onAuthStateChanged(User? user) async {
    if (_skipInitialAuthEvent) {
      _skipInitialAuthEvent = false;
      if (user != null) {
        await _analytics?.setUserId(id: user.uid);
      }
      return;
    }

    if (user == null) {
      await _analytics?.setUserId(id: null);
      _lastLoggedAuthUid = null;
      return;
    }

    if (_lastLoggedAuthUid == user.uid) return;
    _lastLoggedAuthUid = user.uid;
    await _analytics?.setUserId(id: user.uid);

    final method = _authMethod(user);
    final created = user.metadata.creationTime;
    final lastSignIn = user.metadata.lastSignInTime;
    final isNewUser = created != null &&
        lastSignIn != null &&
        lastSignIn.difference(created).inSeconds.abs() <= 10;

    try {
      if (isNewUser) {
        await _analytics?.logSignUp(signUpMethod: method);
      } else {
        await _analytics?.logLogin(loginMethod: method);
      }
    } catch (error) {
      debugPrint('Analytics auth event error: $error');
    }
  }

  static String _authMethod(User user) {
    for (final info in user.providerData) {
      switch (info.providerId) {
        case 'google.com':
          return 'google';
        case 'apple.com':
          return 'apple';
        case 'password':
          return 'email';
        default:
          if (info.providerId.contains('kakao')) return 'kakao';
      }
    }
    return 'unknown';
  }

  static Future<void> _logEvent(
    String name,
    Map<String, Object> parameters,
  ) async {
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (error) {
      debugPrint('Analytics log error ($name): $error');
    }
  }
}
