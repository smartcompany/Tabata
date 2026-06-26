import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/description_block.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import 'routine_image_upload_service.dart';

const _uuid = Uuid();
const _mediaDirName = 'routine_media';

/// Local-first storage and sync for rich description/instruction image blocks.
class RoutineDescriptionMediaService {
  RoutineDescriptionMediaService({
    RoutineImageUploadService? uploadService,
    http.Client? httpClient,
  })  : _uploadService = uploadService ?? RoutineImageUploadService(client: httpClient),
        _httpClient = httpClient ?? http.Client();

  final RoutineImageUploadService _uploadService;
  final http.Client _httpClient;

  static String relativePath(String scopeId, String filename) =>
      '$_mediaDirName/$scopeId/$filename';

  Future<String> documentsRoot() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> absolutePath(String relativePath) async {
    final root = await documentsRoot();
    return p.join(root, relativePath);
  }

  Future<String> savePickedImage({
    required String scopeId,
    required XFile file,
  }) async {
    final sourceExt = p.extension(file.path).toLowerCase();
    final normalizedExt = switch (sourceExt) {
      '.png' => '.png',
      '.webp' => '.webp',
      '.gif' => '.gif',
      _ => '.jpg',
    };
    final filename = '${_uuid.v4()}$normalizedExt';
    final relative = relativePath(scopeId, filename);
    final destination = await absolutePath(relative);
    await Directory(p.dirname(destination)).create(recursive: true);
    await File(file.path).copy(destination);
    return relative;
  }

  Future<List<ImageDescriptionBlock>> blocksFromPickedImages({
    required String scopeId,
    required List<XFile> files,
  }) async {
    final blocks = <ImageDescriptionBlock>[];
    for (final file in files) {
      final localPath = await savePickedImage(scopeId: scopeId, file: file);
      blocks.add(ImageDescriptionBlock(localPath: localPath));
    }
    return blocks;
  }

  Future<Routine> prepareForServerUpload(
    Routine routine,
    String userToken,
  ) async {
    final blocks = await _prepareBlocksForUpload(
      blocks: routine.effectiveDescriptionBlocks,
      uploadScopeId: routine.id,
      userToken: userToken,
    );

    final exercises = <Exercise>[];
    for (final exercise in routine.orderedExercises) {
      final instructionBlocks = await _prepareBlocksForUpload(
        blocks: exercise.effectiveInstructionBlocks,
        uploadScopeId: routine.id,
        userToken: userToken,
      );
      exercises.add(
        exercise.copyWith(
          instructionBlocks: instructionBlocks,
          instruction: DescriptionBlock.plainText(instructionBlocks),
        ),
      );
    }

    return routine.copyWith(
      descriptionBlocks: blocks,
      description: DescriptionBlock.plainText(blocks),
      exercises: exercises,
    );
  }

  Future<Routine> localizeDescriptionImages(Routine routine) async {
    final blocks = await _localizeBlocks(
      blocks: routine.effectiveDescriptionBlocks,
      storageScopeId: routine.id,
    );

    final exercises = <Exercise>[];
    for (final exercise in routine.orderedExercises) {
      final instructionBlocks = await _localizeBlocks(
        blocks: exercise.effectiveInstructionBlocks,
        storageScopeId: exercise.id,
      );
      exercises.add(
        exercise.copyWith(
          instructionBlocks: instructionBlocks,
          instruction: DescriptionBlock.plainText(instructionBlocks),
        ),
      );
    }

    return routine.copyWith(
      descriptionBlocks: blocks,
      description: DescriptionBlock.plainText(blocks),
      exercises: exercises,
    );
  }

  Future<List<DescriptionBlock>> _prepareBlocksForUpload({
    required List<DescriptionBlock> blocks,
    required String uploadScopeId,
    required String userToken,
  }) async {
    final prepared = <DescriptionBlock>[];
    for (final block in blocks) {
      if (block is ImageDescriptionBlock && block.hasLocalPath) {
        final absolute = await absolutePath(block.localPath!);
        final url = await _uploadService.uploadLocalFile(
          localFilePath: absolute,
          routineId: uploadScopeId,
          userToken: userToken,
        );
        prepared.add(ImageDescriptionBlock(url: url, alt: block.alt));
      } else {
        prepared.add(block);
      }
    }
    return prepared;
  }

  Future<List<DescriptionBlock>> _localizeBlocks({
    required List<DescriptionBlock> blocks,
    required String storageScopeId,
  }) async {
    final localized = <DescriptionBlock>[];
    for (final block in blocks) {
      if (block is ImageDescriptionBlock &&
          block.hasRemoteUrl &&
          !block.hasLocalPath) {
        try {
          final localPath = await _downloadImage(
            storageScopeId: storageScopeId,
            url: block.url!,
          );
          localized.add(ImageDescriptionBlock(localPath: localPath, alt: block.alt));
        } catch (_) {
          localized.add(block);
        }
      } else {
        localized.add(block);
      }
    }
    return localized;
  }

  Future<String> _downloadImage({
    required String storageScopeId,
    required String url,
  }) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw StateError('Failed to download image (${response.statusCode})');
    }

    final contentType = response.headers['content-type'] ?? '';
    final ext =
        _extensionFromContentType(contentType) ?? _extensionFromUrl(url) ?? '.jpg';
    final filename = '${_uuid.v4()}$ext';
    final relative = relativePath(storageScopeId, filename);
    final destination = await absolutePath(relative);
    await Directory(p.dirname(destination)).create(recursive: true);
    await File(destination).writeAsBytes(response.bodyBytes);
    return relative;
  }

  String? _extensionFromContentType(String contentType) {
    final lower = contentType.toLowerCase();
    if (lower.contains('png')) return '.png';
    if (lower.contains('webp')) return '.webp';
    if (lower.contains('gif')) return '.gif';
    if (lower.contains('jpeg') || lower.contains('jpg')) return '.jpg';
    return null;
  }

  String? _extensionFromUrl(String url) {
    final ext = p.extension(Uri.parse(url).path);
    return ext.isEmpty ? null : ext;
  }
}
