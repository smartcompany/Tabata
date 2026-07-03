import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_lib/share_lib.dart';

enum RewardedAdOutcome {
  rewarded,
  dismissedEarly,
  loadFailed,
  skipped,
}

/// Shows a rewarded ad before AI routine generation.
class RewardedAdGate {
  RewardedAdGate._();

  static const _loadTimeout = Duration(seconds: 25);
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

  static Future<RewardedAdOutcome> show() async {
    final adUnitId = _resolveAdUnitId();
    if (adUnitId == null) {
      debugPrint('[RewardedAdGate] No ad unit id; skipping ad.');
      return RewardedAdOutcome.skipped;
    }

    debugPrint('[RewardedAdGate] Using ad unit: $adUnitId');

    final preloaded = _takePreloadedAd(adUnitId);
    if (preloaded != null) {
      debugPrint('[RewardedAdGate] Showing preloaded rewarded ad');
      return _presentAd(preloaded);
    }

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      debugPrint(
        '[RewardedAdGate] Loading rewarded ad (attempt $attempt/$_maxAttempts)',
      );
      final outcome = await _loadAndPresent(adUnitId);
      if (outcome != RewardedAdOutcome.loadFailed) {
        return outcome;
      }
      if (attempt < _maxAttempts) {
        await Future<void>.delayed(Duration(seconds: attempt));
      }
    }

    return RewardedAdOutcome.loadFailed;
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

  static Future<RewardedAdOutcome> _loadAndPresent(String adUnitId) async {
    final completer = Completer<RewardedAdOutcome>();
    var rewarded = false;
    var loaded = false;

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          loaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(
                  rewarded
                      ? RewardedAdOutcome.rewarded
                      : RewardedAdOutcome.dismissedEarly,
                );
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[RewardedAdGate] Failed to show: $error');
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(RewardedAdOutcome.loadFailed);
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
            completer.complete(RewardedAdOutcome.loadFailed);
          }
        },
      ),
    );

    return completer.future.timeout(
      _loadTimeout,
      onTimeout: () {
        debugPrint('[RewardedAdGate] Load/show timed out (loaded=$loaded)');
        return loaded
            ? RewardedAdOutcome.dismissedEarly
            : RewardedAdOutcome.loadFailed;
      },
    );
  }

  static Future<RewardedAdOutcome> _presentAd(RewardedAd ad) async {
    final completer = Completer<RewardedAdOutcome>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(
            rewarded
                ? RewardedAdOutcome.rewarded
                : RewardedAdOutcome.dismissedEarly,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[RewardedAdGate] Failed to show preloaded ad: $error');
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(RewardedAdOutcome.loadFailed);
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
        return rewarded
            ? RewardedAdOutcome.rewarded
            : RewardedAdOutcome.dismissedEarly;
      },
    );
  }

  static String? _resolveAdUnitId() {
    final configured = AdService.shared.rewardedAdId?.trim();
    if (configured == null || configured.isEmpty) {
      return null;
    }
    return configured;
  }
}
