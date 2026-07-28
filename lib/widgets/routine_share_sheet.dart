import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_lib/share_lib.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../services/routine_share_service.dart';
import '../services/app_analytics_service.dart';
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
    /// 카카오 하단 버튼 문구. 빈 문자열이면 버튼을 넣지 않습니다(카드 탭만 링크).
    String? linkButtonTitle,
    String shareType = 'routine',
    Uint8List? imageBytes,
    /// Caption title when sharing an image to Kakao as a photo message.
    String? kakaoFeedTitle,
    /// Caption body when sharing an image to Kakao as a photo message.
    String? kakaoFeedDescription,
    /// 시스템 공유 시 이미지만 전달 (운동 완료 공유용).
    bool systemShareImageOnly = false,
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
        // null → 기본 '루틴 열기'. 빈 문자열 → 버튼 없음(카드 탭만 링크).
        final String? resolvedButtonTitle = linkButtonTitle == null
            ? l10n.shareKakaoLinkButton
            : (linkButtonTitle.trim().isEmpty
                ? null
                : linkButtonTitle.trim());

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
                      var shareFailed = false;
                      if (imageBytes != null) {
                        // FeedTemplate은 이미지 탭이 항상 링크 이동 → 사진 메시지로 공유
                        await ShareService.shareToKakaoWithImage(
                          imageBytes: imageBytes,
                          title: kakaoFeedTitle?.trim().isNotEmpty == true
                              ? kakaoFeedTitle!.trim()
                              : (subject?.trim().isNotEmpty == true
                                  ? subject!.trim()
                                  : kakaoShareText.split('\n').first),
                          description: kakaoFeedDescription ?? kakaoShareText,
                          linkUrl: resolvedLink,
                          linkButtonTitle: resolvedButtonTitle,
                          sharePositionOrigin: shareOrigin,
                          onShareDefaultUri: (uri) => logKakaoShareDefaultUri(
                            uri,
                            requestedLinkUrl: resolvedLink,
                          ),
                          onError: (_) {
                            shareFailed = true;
                            _showShareFailed(context, l10n);
                            unawaited(
                              AppAnalyticsService.logProductEvent(
                                'routine_share_failed',
                                properties: {
                                  'share_type': shareType,
                                  'channel': 'kakao',
                                },
                              ),
                            );
                          },
                        );
                      } else {
                        // 도파민 자산과 동일: 본문은 텍스트만, 클릭은 linkUrl(Universal Link).
                        await _shareToKakaoCompat(
                          kakaoShareText,
                          linkUrl: resolvedLink,
                          linkButtonTitle: resolvedButtonTitle,
                          onError: (_) {
                            shareFailed = true;
                            _showShareFailed(context, l10n);
                            unawaited(
                              AppAnalyticsService.logProductEvent(
                                'routine_share_failed',
                                properties: {
                                  'share_type': shareType,
                                  'channel': 'kakao',
                                },
                              ),
                            );
                          },
                        );
                      }
                      if (!shareFailed) {
                        await AppAnalyticsService.logRoutineShare(
                          shareType: shareType,
                          channel: 'kakao',
                        );
                      }
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
                    try {
                      if (imageBytes != null) {
                        await ShareService.shareWithImage(
                          systemShareImageOnly ? '' : mergedText,
                          imageBytes,
                          subject: systemShareImageOnly ? null : subject,
                          sharePositionOrigin: shareOrigin,
                        );
                      } else {
                        await ShareService.shareText(
                          mergedText,
                          subject: subject,
                          sharePositionOrigin: shareOrigin,
                        );
                      }
                      await AppAnalyticsService.logRoutineShare(
                        shareType: shareType,
                        channel: 'system',
                      );
                    } catch (_) {
                      await AppAnalyticsService.logProductEvent(
                        'routine_share_failed',
                        properties: {
                          'share_type': shareType,
                          'channel': 'system',
                        },
                      );
                      if (context.mounted) {
                        _showShareFailed(context, l10n);
                      }
                    }
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
    String? linkButtonTitle,
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
