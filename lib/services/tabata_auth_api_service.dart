import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:share_lib/share_lib_auth.dart';

import '../config/api_config.dart';
import '../models/user.dart';

class TabataAuthApiService implements AuthServiceInterface {
  TabataAuthApiService._();

  static TabataAuthApiService? _instance;

  static TabataAuthApiService get shared {
    _instance ??= TabataAuthApiService._();
    return _instance!;
  }

  static String get baseUrl => '${ApiConfig.profileApiBaseUrl}/api';

  String? _token;

  @override
  void setToken(String token) {
    _token = token.isEmpty ? null : token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  @override
  Future<Map<String, String>> loginWithKakao(String accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/kakao/firebase'),
      headers: _headers,
      body: jsonEncode({'access_token': accessToken}),
    );
    if (response.statusCode != 200) {
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Failed to login with Kakao');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to login with Kakao (${response.statusCode})');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = <String, String>{
      'uid': data['uid'] as String,
      'kakao_id': data['kakao_id'] as String,
    };
    final customToken = data['custom_token'] as String?;
    if (customToken != null) {
      result['custom_token'] = customToken;
    }
    return result;
  }

  @override
  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );
    if (response.statusCode == 404) {
      throw Exception('PROFILE_NOT_SETUP');
    }
    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      }
      throw Exception('Failed to get user');
    }
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<dynamic> updateProfile({
    required String fullName,
    String? kakaoId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
      body: jsonEncode({
        'full_name': fullName,
        if (kakaoId != null) 'kakao_id': kakaoId,
      }),
    );
    if (response.statusCode != 200) {
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Failed to update user');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to update user (${response.statusCode})');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['custom_token'] != null) {
      return data;
    }
    return User.fromJson(data);
  }
}
