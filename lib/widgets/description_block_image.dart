import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/description_block.dart';
import '../services/routine_description_media_service.dart';

class DescriptionBlockImage extends StatefulWidget {
  const DescriptionBlockImage({
    super.key,
    required this.block,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final ImageDescriptionBlock block;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  State<DescriptionBlockImage> createState() => _DescriptionBlockImageState();
}

class _DescriptionBlockImageState extends State<DescriptionBlockImage> {
  String? _localAbsolutePath;
  var _resolvingLocal = false;

  @override
  void initState() {
    super.initState();
    _syncLocalPath();
  }

  @override
  void didUpdateWidget(covariant DescriptionBlockImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.localPath != widget.block.localPath ||
        oldWidget.block.url != widget.block.url) {
      _localAbsolutePath = null;
      _resolvingLocal = false;
      _syncLocalPath();
    }
  }

  void _syncLocalPath() {
    final relative = widget.block.localPath;
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
    final block = widget.block;
    if (block.hasRemoteUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.network(
          block.url!,
          height: widget.height,
          width: double.infinity,
          fit: widget.fit,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _loadingPlaceholder(context, progress: progress);
          },
          errorBuilder: (context, error, stackTrace) => _errorCard(context),
        ),
      );
    }

    if (block.hasLocalPath) {
      final path = _localAbsolutePath;
      if (path == null) {
        return _loadingPlaceholder(context);
      }
      if (!File(path).existsSync()) {
        return _errorCard(context);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.file(
          File(path),
          height: widget.height,
          width: double.infinity,
          fit: widget.fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _errorCard(context),
        ),
      );
    }

    return _errorCard(context);
  }

  Widget _loadingPlaceholder(
    BuildContext context, {
    ImageChunkEvent? progress,
  }) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress?.expectedTotalBytes == null
                ? null
                : progress!.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!,
          ),
        ),
      ),
    );
  }

  Widget _errorCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(AppLocalizations.of(context).descriptionImageLoadError),
      ),
    );
  }
}
