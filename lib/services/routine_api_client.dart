import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/profile_summary.dart';
import '../models/routine.dart';

class RoutineApiException implements Exception {
  const RoutineApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RoutineApiClient {
  RoutineApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _baseUri => Uri.parse(ApiConfig.profileApiBaseUrl);

  Future<List<ProfileSummary>> fetchProfileSummaries({
    bool official = true,
  }) async {
    final listUri = _baseUri.replace(
      path: '/api/profiles',
      queryParameters: {'scope': official ? 'official' : 'shared'},
    );
    final listResponse = await _client.get(listUri);
    if (listResponse.statusCode != 200) {
      throw RoutineApiException(
        'Failed to load profiles (${listResponse.statusCode})',
      );
    }

    final listBody = jsonDecode(listResponse.body) as Map<String, dynamic>;
    final summaries = listBody['profiles'] as List<dynamic>? ?? [];
    return [
      for (final summary in summaries)
        ProfileSummary.fromJson(summary as Map<String, dynamic>),
    ];
  }

  Future<List<String>> fetchProfileIds() async {
    final summaries = await fetchProfileSummaries();
    return summaries.map((summary) => summary.id).toList();
  }

  Future<List<String>> fetchDashboardProfileIds({
    required String adminToken,
  }) async {
    final routines = await fetchDashboardProfiles(adminToken: adminToken);
    return routines.map((routine) => routine.id).toList();
  }

  Future<List<Routine>> fetchDashboardProfiles({
    required String adminToken,
  }) async {
    final uri = _baseUri.replace(path: '/api/dashboard/profiles');
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $adminToken'},
    );

    if (response.statusCode == 401) {
      throw const RoutineApiException('Unauthorized');
    }
    if (response.statusCode != 200) {
      throw RoutineApiException(
        'Failed to load dashboard profiles (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rows = body['profiles'] as List<dynamic>? ?? [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          Routine.fromJson(row['profile'] as Map<String, dynamic>),
    ];
  }

  Future<List<Routine>> fetchAllProfiles() async {
    final ids = await fetchProfileIds();
    if (ids.isEmpty) return [];

    return Future.wait(ids.map(fetchProfile));
  }

  Future<Routine> fetchProfile(String id) async {
    final uri = _baseUri.replace(path: '/api/profiles/$id');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw RoutineApiException(
        'Failed to load profile $id (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Routine.fromJson(body);
  }

  Future<String> loginDashboard({
    required String username,
    required String password,
  }) async {
    final uri = _baseUri.replace(path: '/api/dashboard/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final message = _errorMessage(response) ?? 'Login failed';
      throw RoutineApiException(message);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const RoutineApiException('Login response missing token');
    }
    return token;
  }

  Future<UploadProfileResult> uploadProfile({
    required Routine routine,
    required String adminToken,
  }) async {
    final uri = _baseUri.replace(path: '/api/dashboard/profiles/upsert');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $adminToken',
      },
      body: jsonEncode(routine.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = _errorMessage(response) ?? 'Upload failed';
      throw RoutineApiException(message);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final action = body['action'] as String? ?? 'updated';
    return UploadProfileResult(
      action: action == 'created'
          ? UploadProfileAction.created
          : UploadProfileAction.updated,
    );
  }

  Future<void> deleteDashboardProfile({
    required String profileId,
    required String adminToken,
  }) async {
    final uri = _baseUri.replace(
      path: '/api/dashboard/profiles/${Uri.encodeComponent(profileId)}',
    );
    final response = await _client.delete(
      uri,
      headers: {'Authorization': 'Bearer $adminToken'},
    );

    if (response.statusCode == 404) {
      throw const RoutineApiException('Profile not found');
    }
    if (response.statusCode != 200) {
      final message = _errorMessage(response) ?? 'Delete failed';
      throw RoutineApiException(message);
    }
  }

  String? _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['error'] as String?;
    } catch (_) {
      return null;
    }
  }
}

enum UploadProfileAction { created, updated }

class UploadProfileResult {
  const UploadProfileResult({required this.action});

  final UploadProfileAction action;
}
