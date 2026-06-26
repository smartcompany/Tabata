import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebViewScreen extends StatefulWidget {
  const LegalWebViewScreen({
    super.key,
    required this.url,
    this.pageTitle,
  });

  final Uri url;
  final String? pageTitle;

  static Future<void> open(
    BuildContext context, {
    required Uri url,
    String? pageTitle,
  }) async {
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => LegalWebViewScreen(
          url: url,
          pageTitle: pageTitle,
        ),
      ),
    );
  }

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late final WebViewController _controller;
  var _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    unawaited(_startWebView());
  }

  Future<void> _startWebView() async {
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _progress = 100);
        },
      ),
    );
    await _controller.loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle ?? ''),
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
