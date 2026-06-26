import 'package:flutter/foundation.dart';
import 'package:share_lib/share_lib.dart';

import '../config/api_config.dart';

abstract final class AdSettings {
  static Future<void> initialize() async {
    try {
      AdService.shared.setBaseUrl(ApiConfig.profileApiBaseUrl);
      await AdService.shared.loadSettings();
    } catch (error, stackTrace) {
      debugPrint('Ad settings load error: $error');
      debugPrint('$stackTrace');
    }
  }
}
