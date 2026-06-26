import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/description_block.dart';
import '../services/routine_description_media_service.dart';

class DescriptionBlockImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (block.hasRemoteUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          block.url!,
          height: height,
          width: double.infinity,
          fit: fit,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _loadingPlaceholder(context, progress: progress);
          },
          errorBuilder: (context, error, stackTrace) => _errorCard(context),
        ),
      );
    }

    if (block.hasLocalPath) {
      return FutureBuilder<String>(
        key: ValueKey(block.localPath),
        future: RoutineDescriptionMediaService().absolutePath(block.localPath!),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _loadingPlaceholder(context);
          }
          final path = snapshot.data;
          if (path == null || !File(path).existsSync()) {
            return _errorCard(context);
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.file(
              File(path),
              height: height,
              width: double.infinity,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _errorCard(context),
            ),
          );
        },
      );
    }

    return _errorCard(context);
  }

  Widget _loadingPlaceholder(
    BuildContext context, {
    ImageChunkEvent? progress,
  }) {
    return SizedBox(
      height: height ?? 160,
      width: double.infinity,
      child: Center(
        child: CircularProgressIndicator(
          value: progress?.expectedTotalBytes == null
              ? null
              : progress!.cumulativeBytesLoaded / progress.expectedTotalBytes!,
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
