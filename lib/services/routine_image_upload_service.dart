import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../config/api_config.dart';
import 'routine_api_client.dart';

enum RoutineImageUploadTarget { user, dashboard }

class RoutineImageUploadService {
  RoutineImageUploadService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uploadUriFor(RoutineImageUploadTarget target) => Uri.parse(
        '${ApiConfig.profileApiBaseUrl}/api/${target == RoutineImageUploadTarget.dashboard ? 'dashboard' : 'user'}/routine-images',
      );

  MediaType _mediaTypeForPath(String path) {
    switch (p.extension(path).toLowerCase()) {
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.gif':
        return MediaType('image', 'gif');
      case '.jpg':
      case '.jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<String> uploadLocalFile({
    required String localFilePath,
    required String routineId,
    required String authToken,
    RoutineImageUploadTarget target = RoutineImageUploadTarget.user,
  }) async {
    final file = File(localFilePath);
    if (!await file.exists()) {
      throw const RoutineApiException('Local image file not found');
    }

    final contentType = _mediaTypeForPath(localFilePath);
    var filename = p.basename(localFilePath);
    if (p.extension(filename).isEmpty) {
      filename = '$filename.jpg';
    }

    final request = http.MultipartRequest('POST', _uploadUriFor(target))
      ..headers['Authorization'] = 'Bearer $authToken'
      ..fields['routineId'] = routineId
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          localFilePath,
          filename: filename,
          contentType: contentType,
        ),
      );

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401) {
      throw const RoutineApiException('Unauthorized');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      String? message;
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['error'] as String?;
      } catch (_) {}
      throw RoutineApiException(
        message ?? 'Failed to upload image (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const RoutineApiException('Upload response missing url');
    }
    return url;
  }
}
