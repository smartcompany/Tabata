import 'dart:convert';

import 'package:flutter/foundation.dart';

/// 공유 링크(Universal / App Link) 디버그 로그. Xcode / Logcat 에서 `ShareLink` 로 필터.
void shareLinkLog(String message) {
  debugPrint('[ShareLink] $message');
}

/// 카카오 TextTemplate(template_id 5793) 이 플랫폼별로 여러 URL 슬롯을 만들지만,
/// 우리는 [Link.webUrl]/[mobileWebUrl] 하나만 넣는다. 로그도 실제 링크만 출력.
void logKakaoShareDefaultUri(Uri uri, {Uri? requestedLinkUrl}) {
  final buffer = StringBuffer('[KakaoShare] shareDefault 완료\n');
  buffer.writeln('  template_id: ${uri.queryParameters['template_id'] ?? '-'}');

  final templateArgsRaw = uri.queryParameters['template_args'];
  if (templateArgsRaw == null || templateArgsRaw.isEmpty) {
    buffer.writeln(
      '  linkUrl: ${requestedLinkUrl?.toString() ?? '(없음)'}',
    );
    debugPrint(buffer.toString());
    return;
  }

  try {
    final decoded = jsonDecode(templateArgsRaw) as Map<String, dynamic>;
    String? linkUrl;
    String? buttonTitle;
    String? titlePreview;

    for (final entry in decoded.entries) {
      final key = entry.key;
      final value = entry.value?.toString() ?? '';
      if (value.isEmpty) continue;

      final isHttpUrl =
          (key.contains('URL') || key.contains('url')) &&
          value.startsWith('http');
      if (isHttpUrl) {
        linkUrl ??= value;
        continue;
      }
      if (key == r'${FIRST_BUTTON_TITLE}') {
        buttonTitle = value;
        continue;
      }
      if (key == r'${TITLE}') {
        titlePreview =
            value.length > 160 ? '${value.substring(0, 160)}…' : value;
      }
    }

    buffer.writeln(
      '  linkUrl: ${linkUrl ?? requestedLinkUrl?.toString() ?? '(없음)'}',
    );
    if (buttonTitle != null) {
      buffer.writeln('  buttonTitle: $buttonTitle');
    }
    if (titlePreview != null) {
      buffer.writeln('  title: $titlePreview');
    }
  } catch (error) {
    buffer.writeln('  template_args decode 실패: $error');
    buffer.writeln(
      '  linkUrl(fallback): ${requestedLinkUrl?.toString() ?? '(없음)'}',
    );
  }

  debugPrint(buffer.toString());
}
