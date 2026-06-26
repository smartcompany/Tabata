import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/description_block.dart';
import '../utils/video_link_utils.dart';
import 'description_block_image.dart';
import 'youtube_embed_player.dart';

class DescriptionBlocksView extends StatelessWidget {
  const DescriptionBlocksView({
    super.key,
    required this.blocks,
  });

  final List<DescriptionBlock> blocks;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _DescriptionBlockTile(block: blocks[i]),
        ],
      ],
    );
  }
}

class _DescriptionBlockTile extends StatelessWidget {
  const _DescriptionBlockTile({required this.block});

  final DescriptionBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      TextDescriptionBlock(:final text) => Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ImageDescriptionBlock imageBlock => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DescriptionBlockImage(block: imageBlock),
            if (imageBlock.alt != null && imageBlock.alt!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                imageBlock.alt!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ],
        ),
      VideoDescriptionBlock(:final url) => _RoutineVideoBlock(url: url),
    };
  }
}

class _RoutineVideoBlock extends StatefulWidget {
  const _RoutineVideoBlock({required this.url});

  final String url;

  @override
  State<_RoutineVideoBlock> createState() => _RoutineVideoBlockState();
}

class _RoutineVideoBlockState extends State<_RoutineVideoBlock> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final embedUrl = VideoLinkUtils.youtubeEmbedUrl(widget.url);

    if (embedUrl != null) {
      if (!_playing) {
        final videoId = VideoLinkUtils.youtubeVideoId(widget.url);
        final thumb = videoId == null
            ? null
            : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _playing = true),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null)
                    Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const ColoredBox(
                        color: Colors.black12,
                      ),
                    )
                  else
                    const ColoredBox(color: Colors.black12),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.descriptionVideoPlay),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubeEmbedPlayer(videoUrl: widget.url),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline),
        title: Text(l10n.descriptionVideoExternal),
        subtitle: Text(widget.url, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          final uri = Uri.tryParse(widget.url);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      ),
    );
  }
}
