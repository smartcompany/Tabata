import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'product_analytics_transport.dart';

/// Server-backed one-time onboarding AI ad waiver.
abstract final class OnboardingAdWaiverService {
  static Future<bool> isEligible() async {
    try {
      final installId = await ProductAnalyticsTransport.shared.ensureInstallId();
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final uri = Uri.parse(
        '${ApiConfig.profileApiBaseUrl}/api/entitlements/onboarding-ai-ad-waiver'
        '?installId=$installId',
      );
      final response = await http
          .get(
            uri,
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        debugPrint(
          'Onboarding ad waiver check failed (${response.statusCode})',
        );
        return false;
      }
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return false;
      return body['eligible'] == true;
    } catch (error) {
      debugPrint('Onboarding ad waiver check error: $error');
      return false;
    }
  }

  /// Attach anonymous install grants to the logged-in account.
  static Future<void> linkInstallToUser() async {
    try {
      final installId = await ProductAnalyticsTransport.shared.ensureInstallId();
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null || token.isEmpty) return;
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.profileApiBaseUrl}/api/entitlements/link-install',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'installId': installId}),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Onboarding ad waiver link failed (${response.statusCode})',
        );
      }
    } catch (error) {
      debugPrint('Onboarding ad waiver link error: $error');
    }
  }

  static Future<void> recordUsed() async {
    try {
      final installId = await ProductAnalyticsTransport.shared.ensureInstallId();
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.profileApiBaseUrl}/api/entitlements/onboarding-ai-ad-waiver',
            ),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'installId': installId}),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Onboarding ad waiver record failed (${response.statusCode})',
        );
      }
    } catch (error) {
      debugPrint('Onboarding ad waiver record error: $error');
    }
  }
}
