import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Remote app configuration from `GET /api/settings`.
abstract final class AppSettingsService {
  static List<String>? _cachedOnboardingRoutineIds;

  static Future<List<String>> onboardingRecommendedRoutineIds({
    http.Client? client,
  }) async {
    if (_cachedOnboardingRoutineIds != null) {
      return List.unmodifiable(_cachedOnboardingRoutineIds!);
    }

    final httpClient = client ?? http.Client();
    final shouldClose = client == null;
    try {
      final uri = Uri.parse('${ApiConfig.profileApiBaseUrl}/api/settings');
      final response = await httpClient.get(uri);
      if (response.statusCode != 200) {
        debugPrint(
          '[AppSettingsService] settings HTTP ${response.statusCode}',
        );
        return const [];
      }

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) return const [];

      final raw = json['onboarding_recommended_routine_ids'];
      if (raw is! List) return const [];

      final ids = raw.whereType<String>().where((id) => id.isNotEmpty).toList();
      _cachedOnboardingRoutineIds = ids;
      return List.unmodifiable(ids);
    } catch (error, stackTrace) {
      debugPrint('[AppSettingsService] Failed to load settings: $error');
      debugPrint('$stackTrace');
      return const [];
    } finally {
      if (shouldClose) {
        httpClient.close();
      }
    }
  }

  @visibleForTesting
  static void clearCacheForTest() {
    _cachedOnboardingRoutineIds = null;
  }
}
