import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
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

  Future<List<Routine>> fetchAllProfiles() async {
    final listUri = _baseUri.replace(path: '/api/profiles');
    final listResponse = await _client.get(listUri);
    if (listResponse.statusCode != 200) {
      throw RoutineApiException(
        'Failed to load profiles (${listResponse.statusCode})',
      );
    }

    final listBody = jsonDecode(listResponse.body) as Map<String, dynamic>;
    final summaries = listBody['profiles'] as List<dynamic>? ?? [];
    if (summaries.isEmpty) return [];

    final routines = await Future.wait(
      summaries.map((summary) async {
        final id = (summary as Map<String, dynamic>)['id'] as String;
        return fetchProfile(id);
      }),
    );
    return routines;
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
}
