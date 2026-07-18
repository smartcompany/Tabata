import '../models/description_block.dart';
import '../models/routine.dart';
import 'video_link_utils.dart';

/// Resolved list-row thumbnail: remote image URL or YouTube preview URL.
class RoutineListThumbnailRef {
  const RoutineListThumbnailRef({
    this.imageUrl,
    this.isVideo = false,
    this.localPath,
  });

  /// Network image (photo URL or YouTube `hqdefault`).
  final String? imageUrl;

  /// Relative local path from [ImageDescriptionBlock.localPath].
  final String? localPath;

  final bool isVideo;

  bool get hasSource =>
      (imageUrl != null && imageUrl!.trim().isNotEmpty) ||
      (localPath != null && localPath!.trim().isNotEmpty);
}

String? youtubeThumbnailUrl(String videoUrl) {
  final id = VideoLinkUtils.youtubeVideoId(videoUrl);
  if (id == null || id.isEmpty) return null;
  return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
}

Iterable<DescriptionBlock> _routineMediaBlocks(Routine routine) sync* {
  yield* routine.effectiveDescriptionBlocks;
  for (final exercise in routine.orderedExercises) {
    yield* exercise.effectiveInstructionBlocks;
  }
}

/// First photo, otherwise first YouTube link, for routine list thumbnails.
RoutineListThumbnailRef? pickRoutineListThumbnail(Routine routine) {
  for (final block in _routineMediaBlocks(routine)) {
    if (block is! ImageDescriptionBlock) continue;
    if (block.hasRemoteUrl) {
      return RoutineListThumbnailRef(imageUrl: block.url!.trim());
    }
    if (block.hasLocalPath) {
      return RoutineListThumbnailRef(localPath: block.localPath!.trim());
    }
  }

  for (final block in _routineMediaBlocks(routine)) {
    if (block is! VideoDescriptionBlock) continue;
    final thumb = youtubeThumbnailUrl(block.url);
    if (thumb == null) continue;
    return RoutineListThumbnailRef(imageUrl: thumb, isVideo: true);
  }

  return null;
}
