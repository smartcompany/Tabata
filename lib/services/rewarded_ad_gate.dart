import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_lib/share_lib.dart';

/// Shows a rewarded ad before AI routine generation.
class RewardedAdGate {
  /// Returns true when the user earned the reward or ads are unavailable (dev).
  static Future<bool> show() async {
    final adUnitId = _resolveAdUnitId();
    if (adUnitId == null) {
      debugPrint('[RewardedAdGate] No ad unit id; skipping ad.');
      return true;
    }

    debugPrint('[RewardedAdGate] Loading rewarded ad: $adUnitId');

    final completer = Completer<bool>();
    var rewarded = false;

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(rewarded);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[RewardedAdGate] Failed to show: $error');
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            },
          );
          ad.show(
            onUserEarnedReward: (ad, reward) {
              rewarded = true;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('[RewardedAdGate] Failed to load: $error');
          if (!completer.isCompleted) {
            completer.complete(kDebugMode);
          }
        },
      ),
    );

    return completer.future;
  }

  static String? _resolveAdUnitId() {
    final configured = AdService.shared.rewardedAdId?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917';
    }
    return null;
  }
}
