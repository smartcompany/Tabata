abstract final class VideoLinkUtils {
  /// HTTPS origin sent as WebView base URL / embed `origin` for YouTube policy.
  static const String youtubeEmbedOrigin = 'https://com.smartcompany.tabata';

  static String? youtubeVideoId(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    if (host == 'youtu.be') {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      return id.isEmpty ? null : id;
    }

    if (host.contains('youtube.com') || host.contains('youtube-nocookie.com')) {
      if (uri.pathSegments.contains('embed') && uri.pathSegments.length >= 2) {
        return uri.pathSegments.last;
      }
      final fromQuery = uri.queryParameters['v'];
      if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
      if (uri.pathSegments.contains('shorts') && uri.pathSegments.length >= 2) {
        return uri.pathSegments.last;
      }
    }

    return null;
  }

  static String? detectProvider(String url) {
    if (youtubeVideoId(url) != null) return 'youtube';
    final host = Uri.tryParse(url.trim())?.host.toLowerCase() ?? '';
    if (host.contains('vimeo.com')) return 'vimeo';
    return null;
  }

  static String youtubeEmbedSrc(String videoId) {
    final origin = Uri.encodeComponent(youtubeEmbedOrigin);
    return 'https://www.youtube.com/embed/$videoId'
        '?playsinline=1&rel=0&modestbranding=1&origin=$origin';
  }

  static String? youtubeEmbedUrl(String url) {
    final id = youtubeVideoId(url);
    if (id == null) return null;
    return youtubeEmbedSrc(id);
  }

  /// HTML page for in-app WebView playback with a valid Referer for YouTube.
  static String? youtubeEmbedHtml(String url) {
    final id = youtubeVideoId(url);
    if (id == null) return null;

    final src = youtubeEmbedSrc(id);
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background: #000;
      overflow: hidden;
    }
    iframe {
      border: 0;
      width: 100%;
      height: 100%;
    }
  </style>
</head>
<body>
  <iframe
    src="$src"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen>
  </iframe>
</body>
</html>
''';
  }
}
