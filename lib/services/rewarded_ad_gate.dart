import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_lib/share_lib.dart';

/// Shows a rewarded ad before AI routine generation.
class RewardedAdGate {
  RewardedAdGate._();

  static const _googleTestPublisher = '3940256099942544';
  static const _iosProductionRewardedAd =
      'ca-app-pub-5520596727761259/8278577702';
  static const _androidProductionRewardedAd =
      'ca-app-pub-5520596727761259/7135484056';
  static const _loadTimeout = Duration(seconds: 20);
  static const _maxAttempts = 3;

  static RewardedAd? _preloadedAd;
  static String? _preloadedAdUnitId;
  static Future<void>? _preloadFuture;

  /// Warms a rewarded ad while the AI prompt screen is open.
  static Future<void> preload() {
    return _preloadFuture ??= _preloadInternal().whenComplete(() {
      _preloadFuture = null;
    });
  }

  static Future<void> _preloadInternal() async {
    final adUnitId = _resolveAdUnitId();
    if (adUnitId == null) return;

    _disposePreloadedAd();
    final completer = Completer<void>();
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _preloadedAd = ad;
          _preloadedAdUnitId = adUnitId;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[RewardedAdGate] Preload failed: $error');
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    await completer.future.timeout(
      _loadTimeout,
      onTimeout: () {
        debugPrint('[RewardedAdGate] Preload timed out');
      },
    );
  }

  /// Returns true when the user earned the reward or ads are unavailable (dev).
  static Future<bool> show() async {
    final adUnitId = _resolveAdUnitId();
    if (adUnitId == null) {
      debugPrint('[RewardedAdGate] No ad unit id; skipping ad.');
      return true;
    }

    final preloaded = _takePreloadedAd(adUnitId);
    if (preloaded != null) {
      debugPrint('[RewardedAdGate] Showing preloaded rewarded ad');
      return _presentAd(preloaded);
    }

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      debugPrint(
        '[RewardedAdGate] Loading rewarded ad (attempt $attempt/$_maxAttempts): $adUnitId',
      );
      final rewarded = await _loadAndPresent(adUnitId);
      if (rewarded) return true;
      if (attempt < _maxAttempts) {
        await Future<void>.delayed(Duration(seconds: attempt));
      }
    }

    return false;
  }

  static RewardedAd? _takePreloadedAd(String adUnitId) {
    final ad = _preloadedAd;
    if (ad == null || _preloadedAdUnitId != adUnitId) return null;
    _preloadedAd = null;
    _preloadedAdUnitId = null;
    return ad;
  }

  static void _disposePreloadedAd() {
    _preloadedAd?.dispose();
    _preloadedAd = null;
    _preloadedAdUnitId = null;
  }

  static Future<bool> _loadAndPresent(String adUnitId) async {
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

    return completer.future.timeout(
      _loadTimeout,
      onTimeout: () {
        debugPrint('[RewardedAdGate] Load/show timed out');
        return false;
      },
    );
  }

  static Future<bool> _presentAd(RewardedAd ad) async {
    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(rewarded);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[RewardedAdGate] Failed to show preloaded ad: $error');
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

    return completer.future.timeout(
      _loadTimeout,
      onTimeout: () {
        debugPrint('[RewardedAdGate] Preloaded show timed out');
        return false;
      },
    );
  }

  static String? _resolveAdUnitId() {
    final configured = AdService.shared.rewardedAdId?.trim();
    if (configured != null && configured.isNotEmpty) {
      if (!kDebugMode && configured.contains(_googleTestPublisher)) {
        debugPrint(
          '[RewardedAdGate] Ignoring test ad unit in release; using production fallback.',
        );
        return _productionFallback();
      }
      return configured;
    }
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917';
    }
    return _productionFallback();
  }

  static String _productionFallback() {
    return Platform.isIOS
        ? _iosProductionRewardedAd
        : _androidProductionRewardedAd;
  }
}
