import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/video_link_utils.dart';

class YoutubeEmbedPlayer extends StatefulWidget {
  const YoutubeEmbedPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<YoutubeEmbedPlayer> createState() => _YoutubeEmbedPlayerState();
}

class _YoutubeEmbedPlayerState extends State<YoutubeEmbedPlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black);

    final html = VideoLinkUtils.youtubeEmbedHtml(widget.videoUrl);
    if (html != null) {
      _controller.loadHtmlString(
        html,
        baseUrl: VideoLinkUtils.youtubeEmbedOrigin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
