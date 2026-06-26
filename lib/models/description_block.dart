/// Ordered rich-description blocks stored in routine JSON as `descriptionBlocks`.
///
/// ```json
/// "descriptionBlocks": [
///   { "type": "text", "text": "준비 자세 설명" },
///   { "type": "image", "url": "https://...", "alt": "참고 자세" }, // server / remote
///   { "type": "image", "localPath": "routine_media/{id}/file.jpg" }, // local draft
///   { "type": "text", "text": "이어서 주의할 점" },
///   { "type": "video", "url": "https://www.youtube.com/watch?v=...", "provider": "youtube" }
/// ]
/// ```
///
/// `description` (plain string) is kept for search/list excerpts and legacy clients.
sealed class DescriptionBlock {
  const DescriptionBlock();

  String get type;

  Map<String, dynamic> toJson();

  factory DescriptionBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'text':
        return TextDescriptionBlock(
          text: json['text'] as String? ?? '',
        );
      case 'image':
        final url = json['url'] as String?;
        final localPath = json['localPath'] as String?;
        if ((url == null || url.isEmpty) &&
            (localPath == null || localPath.isEmpty)) {
          throw const FormatException('image block requires url or localPath');
        }
        return ImageDescriptionBlock(
          url: url,
          localPath: localPath,
          alt: json['alt'] as String?,
        );
      case 'video':
        final url = json['url'] as String?;
        if (url == null || url.isEmpty) {
          throw const FormatException('video block requires url');
        }
        return VideoDescriptionBlock(
          url: url,
          provider: json['provider'] as String?,
        );
      default:
        throw FormatException('Unknown description block type: $type');
    }
  }

  static List<DescriptionBlock> listFromJson(dynamic raw) {
    if (raw == null) return const [];
    if (raw is! List) {
      throw const FormatException('descriptionBlocks must be a list');
    }
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) DescriptionBlock.fromJson(item),
    ];
  }

  static List<Map<String, dynamic>> listToJson(List<DescriptionBlock> blocks) {
    return blocks.map((block) => block.toJson()).toList();
  }

  static String plainText(List<DescriptionBlock> blocks) {
    return blocks
        .whereType<TextDescriptionBlock>()
        .map((block) => block.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n\n');
  }

  static List<DescriptionBlock> fromLegacyDescription(String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) return const [];
    return [TextDescriptionBlock(text: trimmed)];
  }
}

final class TextDescriptionBlock extends DescriptionBlock {
  const TextDescriptionBlock({required this.text});

  @override
  String get type => 'text';

  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  TextDescriptionBlock copyWith({String? text}) {
    return TextDescriptionBlock(text: text ?? this.text);
  }
}

final class ImageDescriptionBlock extends DescriptionBlock {
  ImageDescriptionBlock({this.url, this.localPath, this.alt})
      : assert(
          (url != null && url.isNotEmpty) ||
              (localPath != null && localPath.isNotEmpty),
        );

  @override
  String get type => 'image';

  final String? url;
  final String? localPath;
  final String? alt;

  bool get hasLocalPath => localPath != null && localPath!.isNotEmpty;
  bool get hasRemoteUrl => url != null && url!.isNotEmpty;

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (hasRemoteUrl) 'url': url,
        if (hasLocalPath) 'localPath': localPath,
        if (alt != null && alt!.isNotEmpty) 'alt': alt,
      };
}

final class VideoDescriptionBlock extends DescriptionBlock {
  const VideoDescriptionBlock({required this.url, this.provider});

  @override
  String get type => 'video';

  final String url;
  final String? provider;

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        if (provider != null && provider!.isNotEmpty) 'provider': provider,
      };
}
