import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, TargetPlatform;
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'routine_share_service.dart';

/// 운동 완료 누적 횟수를 기준으로 스토어 인앱 리뷰 팝업을 적절한 타이밍에 요청한다.
///
/// - 플랫폼(App Store / Play) 자체 쿼터가 있으므로 버튼이 아니라
///   "긍정적 행동(운동 완료)" 뒤에만 호출한다.
/// - 앱에서도 최소 완료 횟수 + 재요청 간격(쿨다운)을 둬서 과도한 호출을 막는다.
abstract final class AppReviewService {
  static const _completedCountKey = 'app_review_completed_count_v1';
  static const _lastRequestMsKey = 'app_review_last_request_ms_v1';
  static const _requestCountKey = 'app_review_request_count_v1';

  /// 최초 요청까지 필요한 운동 완료 횟수.
  static const _firstThreshold = 3;

  /// 이후 재요청 간격(완료 횟수 기준).
  static const _repeatEvery = 12;

  /// 재요청 최소 간격(일). 플랫폼 쿼터(iOS 연 3회 등)와 별개의 앱 자체 보호.
  static const _minDaysBetween = 45;

  /// 앱 생애 최대 요청 횟수(iOS 연 3회 정책 고려).
  static const _maxRequests = 3;

  static final InAppReview _inAppReview = InAppReview.instance;

  /// 운동 완료 직후 호출. 조건이 맞으면 리뷰 팝업을 요청한다.
  static Future<void> onWorkoutCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_completedCountKey) ?? 0) + 1;
      await prefs.setInt(_completedCountKey, count);

      if (!_shouldRequestAtCount(count)) return;

      final requestCount = prefs.getInt(_requestCountKey) ?? 0;
      if (requestCount >= _maxRequests) return;

      final lastMs = prefs.getInt(_lastRequestMsKey) ?? 0;
      if (lastMs > 0) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - lastMs;
        if (elapsed < _minDaysBetween * 24 * 60 * 60 * 1000) return;
      }

      if (!await _inAppReview.isAvailable()) return;

      await _inAppReview.requestReview();

      await prefs.setInt(_requestCountKey, requestCount + 1);
      await prefs.setInt(
        _lastRequestMsKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (error) {
      debugPrint('AppReview request error: $error');
    }
  }

  static bool _shouldRequestAtCount(int count) {
    if (count < _firstThreshold) return false;
    if (count == _firstThreshold) return true;
    return (count - _firstThreshold) % _repeatEvery == 0;
  }

  /// 설정의 "앱 평가하기" — 먼저 인앱 별점 팝업, 불가 시 스토어 리뷰 페이지.
  static Future<void> promptFromSettings() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        return;
      }
      await _openStoreReviewPage();
    } catch (error) {
      debugPrint('AppReview promptFromSettings error: $error');
      await _openStoreReviewPage();
    }
  }

  static Future<void> _openStoreReviewPage() async {
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? RoutineShareService.appStoreReviewLink
        : RoutineShareService.playStoreLink;

    if (!await canLaunchUrl(uri)) {
      debugPrint('AppReview cannot launch store url: $uri');
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
