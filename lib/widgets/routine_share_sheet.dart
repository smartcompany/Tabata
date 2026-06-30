import 'package:flutter/material.dart';
import 'package:share_lib/share_lib.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../services/routine_share_service.dart';
import '../services/share_link_log.dart';

/// 루틴 등 앱 내 공유 바텀 시트. [ShareService]로 실제 공유를 수행합니다.
abstract final class RoutineShareSheet {
  static Rect? _shareOriginFromContext(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  static Future<void> show({
    required BuildContext context,
    required String shareText,
    required String kakaoShareText,
    String? subject,
    Uri? linkUrl,
  }) async {
    final shareOrigin = _shareOriginFromContext(context);
    final kakaoAvailable = await ShareService.isKakaoTalkAvailable();
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        final mergedText = _mergeTextAndUrl(shareText, linkUrl);
        final resolvedLink = linkUrl ?? RoutineShareService.storeLink;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                if (kakaoAvailable)
                  ListTile(
                    leading: Icon(
                      Icons.chat_bubble_rounded,
                      color: colorScheme.tertiary,
                    ),
                    title: Text(
                      l10n.shareSheetKakaoTalk,
                      style: textTheme.titleMedium,
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      // 도파민 자산과 동일: 본문은 텍스트만, 클릭은 linkUrl(Universal Link).
                      await _shareToKakaoCompat(
                        kakaoShareText,
                        linkUrl: resolvedLink,
                        linkButtonTitle: l10n.shareKakaoLinkButton,
                        onError: (_) => _showShareFailed(context, l10n),
                      );
                    },
                  ),
                ListTile(
                  leading: Icon(
                    Icons.share_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    l10n.shareSheetSystemShare,
                    style: textTheme.titleMedium,
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await ShareService.shareText(
                      mergedText,
                      subject: subject,
                      sharePositionOrigin: shareOrigin,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _shareToKakaoCompat(
    String shareText, {
    required Uri linkUrl,
    required String linkButtonTitle,
    Function(String error)? onError,
  }) async {
    shareLinkLog('kakao 요청 linkUrl=$linkUrl');
    await ShareService.shareToKakao(
      shareText,
      linkUrl: linkUrl,
      linkButtonTitle: linkButtonTitle,
      onShareDefaultUri: (uri) =>
          logKakaoShareDefaultUri(uri, requestedLinkUrl: linkUrl),
      onError: onError,
    );
  }

  static void _showShareFailed(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.shareFailed)),
    );
  }

  static String _mergeTextAndUrl(String shareText, Uri? linkUrl) {
    if (linkUrl == null) return shareText;
    return '$shareText\n${linkUrl.toString()}';
  }
}
