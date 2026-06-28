import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/routine.dart';
import '../utils/content_language.dart';
import 'routine_api_client.dart';

class AiRoutineService {
  AiRoutineService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Routine> generateRoutine({
    required String prompt,
    required String contentLanguage,
  }) async {
    final uri = Uri.parse('${ApiConfig.profileApiBaseUrl}/api/routines/generate');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt.trim(),
        'contentLanguage': ContentLanguage.resolve(contentLanguage),
      }),
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw RoutineApiException(
        'Failed to generate routine (${response.statusCode})',
      );
    }

    if (response.statusCode != 200) {
      final message = body['error'];
      throw RoutineApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Failed to generate routine (${response.statusCode})',
      );
    }

    final profile = body['profile'];
    if (profile is! Map<String, dynamic>) {
      throw const RoutineApiException('Invalid routine response');
    }

    return Routine.fromJson(profile);
  }
}
