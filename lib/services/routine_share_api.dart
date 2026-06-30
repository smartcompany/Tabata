import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/routine.dart';
import 'share_link_log.dart';

class RoutineShareApiException implements Exception {
  const RoutineShareApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 서버에 루틴 스냅샷을 저장하고 HTTPS 공유 URL을 받습니다.
class RoutineShareApi {
  RoutineShareApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _apiBase = Uri.parse(ApiConfig.profileApiBaseUrl);

  Uri get _createUri => _apiBase.replace(path: '/api/share/routines');

  static const appLinkScheme = 'tabata';

  /// `https://tabata-server.vercel.app/share/{id}` 에서 share id 추출.
  static String? shareIdFromUri(Uri uri) {
    final expectedHost = _apiBase.host.toLowerCase();
    final host = uri.host.toLowerCase();
    if (host != expectedHost && host != 'localhost' && host != '127.0.0.1') {
      shareLinkLog(
        'shareIdFromUri reject host=$host expected=$expectedHost uri=$uri',
      );
      return null;
    }

    final segments = uri.pathSegments.where((part) => part.isNotEmpty).toList();
    if (segments.length != 2 || segments.first != 'share') {
      shareLinkLog(
        'shareIdFromUri reject path segments=$segments uri=$uri',
      );
      return null;
    }

    final shareId = segments[1].trim();
    if (shareId.isEmpty) {
      shareLinkLog('shareIdFromUri reject empty id uri=$uri');
      return null;
    }
    shareLinkLog('shareIdFromUri ok id=$shareId');
    return shareId;
  }

  /// `tabata://share?shareId={id}` — 카카오 인앱 등 웹 UL 미동작 시 서버 페이지 폴백.
  static String? shareIdFromAppScheme(Uri uri) {
    if (uri.scheme.toLowerCase() != appLinkScheme) {
      return null;
    }
    if (uri.host.toLowerCase() != 'share') {
      shareLinkLog(
        'shareIdFromAppScheme reject host=${uri.host} uri=$uri',
      );
      return null;
    }

    final fromQuery = uri.queryParameters['shareId']?.trim();
    if (fromQuery != null && fromQuery.isNotEmpty) {
      shareLinkLog('shareIdFromAppScheme ok id=$fromQuery');
      return fromQuery;
    }

    shareLinkLog('shareIdFromAppScheme reject — no shareId query uri=$uri');
    return null;
  }

  /// HTTPS Universal Link 또는 `tabata://` 앱 스킴.
  static String? shareIdFromDeepLink(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'https' || scheme == 'http') {
      return shareIdFromUri(uri);
    }
    return shareIdFromAppScheme(uri);
  }

  Future<Uri> createShareLink(Routine routine) async {
    final response = await _client.post(
      _createUri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'routine': routine.toJson()}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final shareUrl = body['shareUrl'] as String?;
      if (shareUrl != null && shareUrl.trim().isNotEmpty) {
        return Uri.parse(shareUrl);
      }
      throw const RoutineShareApiException('Invalid share response');
    }

    if (response.statusCode == 503) {
      throw const RoutineShareApiException('Share storage is not configured');
    }

    throw RoutineShareApiException(
      'Failed to create share link (${response.statusCode})',
    );
  }

  Future<Routine> fetchSharedRoutine(String shareId) async {
    final uri = _apiBase.replace(path: '/api/share/routines/$shareId');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final routineJson = body['routine'];
      if (routineJson is! Map<String, dynamic>) {
        throw const RoutineShareApiException('Invalid share response');
      }
      return Routine.fromJson(routineJson);
    }

    if (response.statusCode == 404) {
      throw const RoutineShareApiException('Share not found');
    }

    throw RoutineShareApiException(
      'Failed to load share (${response.statusCode})',
    );
  }
}
