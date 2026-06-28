import 'package:flutter/foundation.dart';
import 'package:share_lib/share_lib.dart';

import '../config/api_config.dart';

abstract final class AdSettings {
  static var _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      AdService.shared.setBaseUrl(ApiConfig.profileApiBaseUrl);
      final loaded = await AdService.shared.loadSettings();
      debugPrint(
        '[AdSettings] Ad settings loaded=$loaded rewardedAdId=${AdService.shared.rewardedAdId}',
      );
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('Ad settings load error: $error');
      debugPrint('$stackTrace');
    }
  }
}
