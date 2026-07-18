import 'dart:io';

import 'package:flutter/material.dart';

import '../models/description_block.dart';
import '../services/routine_description_media_service.dart';
import '../utils/routine_list_thumbnail.dart';

/// Compact square thumbnail for routine list rows.
///
/// Shows a solid placeholder first; network/local image fades in when ready.
class RoutineListThumbnail extends StatefulWidget {
  const RoutineListThumbnail({
    super.key,
    this.imageUrl,
    this.localPath,
    this.isVideo = false,
    this.size = 56,
  });

  factory RoutineListThumbnail.fromRef(
    RoutineListThumbnailRef ref, {
    Key? key,
    double size = 56,
  }) {
    return RoutineListThumbnail(
      key: key,
      imageUrl: ref.imageUrl,
      localPath: ref.localPath,
      isVideo: ref.isVideo,
      size: size,
    );
  }

  /// Placeholder-only slot (e.g. catalog thumbnail still resolving).
  const RoutineListThumbnail.placeholder({
    super.key,
    this.size = 56,
  })  : imageUrl = null,
        localPath = null,
        isVideo = false;

  final String? imageUrl;
  final String? localPath;
  final bool isVideo;
  final double size;

  @override
  State<RoutineListThumbnail> createState() => _RoutineListThumbnailState();
}

class _RoutineListThumbnailState extends State<RoutineListThumbnail> {
  String? _localAbsolutePath;
  var _resolvingLocal = false;

  @override
  void initState() {
    super.initState();
    _syncLocalPath();
  }

  @override
  void didUpdateWidget(covariant RoutineListThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localPath != widget.localPath) {
      _localAbsolutePath = null;
      _resolvingLocal = false;
      _syncLocalPath();
    }
  }

  void _syncLocalPath() {
    final relative = widget.localPath?.trim();
    if (relative == null || relative.isEmpty) return;

    final cached = RoutineDescriptionMediaService.cachedAbsolutePath(relative);
    if (cached != null) {
      _localAbsolutePath = cached;
      return;
    }

    if (_resolvingLocal) return;
    _resolvingLocal = true;
    RoutineDescriptionMediaService().absolutePath(relative).then((path) {
      if (!mounted) return;
      setState(() {
        _localAbsolutePath = path;
        _resolvingLocal = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _resolvingLocal = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final networkUrl = widget.imageUrl?.trim();
    final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;
    final localPath = _localAbsolutePath;
    final hasLocal = localPath != null && File(localPath).existsSync();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Icon(
                widget.isVideo
                    ? Icons.play_circle_outline_rounded
                    : Icons.image_outlined,
                size: widget.size * 0.36,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
              ),
            ),
            if (hasLocal)
              Image.file(
                File(localPath),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              )
            else if (hasNetwork)
              Image.network(
                networkUrl,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox.shrink();
                },
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            if (widget.isVideo && (hasNetwork || hasLocal)) ...[
              ColoredBox(color: Colors.black.withValues(alpha: 0.22)),
              Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white.withValues(alpha: 0.92),
                  size: widget.size * 0.43,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Optional helper when the source is still a [DescriptionBlock].
RoutineListThumbnailRef? thumbnailRefFromBlock(DescriptionBlock block) {
  if (block is ImageDescriptionBlock) {
    if (block.hasRemoteUrl) {
      return RoutineListThumbnailRef(imageUrl: block.url!.trim());
    }
    if (block.hasLocalPath) {
      return RoutineListThumbnailRef(localPath: block.localPath!.trim());
    }
  }
  if (block is VideoDescriptionBlock) {
    final thumb = youtubeThumbnailUrl(block.url);
    if (thumb != null) {
      return RoutineListThumbnailRef(imageUrl: thumb, isVideo: true);
    }
  }
  return null;
}
