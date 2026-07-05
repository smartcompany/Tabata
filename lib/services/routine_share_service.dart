import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:share_lib/share_lib.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../config/api_config.dart';
import '../models/routine.dart';
import '../utils/duration_calculator.dart';
import 'routine_json_codec.dart';

class RoutineShareService {
  static const appStoreId = '6783721406';

  static final playStoreLink = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.smartcompany.tabata',
  );

  static final appStoreLink = Uri.parse(
    'https://apps.apple.com/app/id$appStoreId',
  );

  /// 루틴 공유 실패 등 플랫폼별 스토어 직링크 폴백.
  static Uri get storeLink =>
      defaultTargetPlatform == TargetPlatform.iOS ? appStoreLink : playStoreLink;

  /// 앱 소개 공유용 — 서버 settings `down_load_url` (UA별 스토어 302).
  static Uri get appShareLink {
    final url = AdService.shared.downloadUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Uri.parse(url);
    }
    return Uri.parse('${ApiConfig.profileApiBaseUrl}/applink');
  }

  /// 카카오 TextTemplate 본문 최대 길이(여유 포함).
  static const kakaoTextMaxLength = 200;

  String encode(Routine routine) => RoutineJsonCodec.encode(routine);

  String buildShareMessage(Routine routine, AppLocalizations l10n) {
    final lines = <String>[routine.title.trim()];

    final description = routine.description.trim();
    if (description.isNotEmpty) {
      lines.add(description);
    }

    lines.add(
      l10n.estimatedDuration(
        formatDuration(routineDurationSec(routine), l10n),
      ),
    );

    final exerciseNames = routine.orderedExercises
        .map((exercise) => exercise.name.trim())
        .where((name) => name.isNotEmpty)
        .join(', ');
    if (exerciseNames.isNotEmpty) {
      lines.add(exerciseNames);
    }

    lines.add(l10n.shareRoutineFooter(l10n.appTitle));
    return lines.join('\n');
  }

  String buildKakaoShareMessage(Routine routine, AppLocalizations l10n) {
    final message = buildShareMessage(routine, l10n);
    if (message.length <= kakaoTextMaxLength) {
      return message;
    }
    return '${message.substring(0, kakaoTextMaxLength - 1)}…';
  }

  String buildAppShareMessage(AppLocalizations l10n) =>
      l10n.shareAppMessage(l10n.appTitle);

  String buildAppKakaoShareMessage(AppLocalizations l10n) {
    final message = buildAppShareMessage(l10n);
    if (message.length <= kakaoTextMaxLength) {
      return message;
    }
    return '${message.substring(0, kakaoTextMaxLength - 1)}…';
  }

  Routine parse(String raw) => RoutineJsonCodec.decode(raw);
}
