import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../config/api_config.dart';
import '../data/routine_repository.dart';
import 'app_analytics_service.dart';
import 'routine_share_api.dart';
import 'share_link_log.dart';

/// `https://tabata-server.vercel.app/share/{id}` Universal Link / App Link,
/// `tabata://share?shareId={id}` 앱 스킴(카카오 인앱 웹 폴백) 수신 후 가져오기 다이얼로그.
class SharedRoutineLinkCoordinator {
  SharedRoutineLinkCoordinator({
    required this.navigatorKey,
    required this.repository,
    RoutineShareApi? shareApi,
  }) : _shareApi = shareApi ?? RoutineShareApi();

  final GlobalKey<NavigatorState> navigatorKey;
  final RoutineRepository repository;
  final RoutineShareApi _shareApi;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  Timer? _delayedPresentRetryTimer;
  String? _pendingShareId;
  String? _presentingShareId;
  String? _lastHandledUri;
  bool _homeReady = false;
  bool _started = false;
  int _presentRetryCount = 0;

  static const _maxPresentRetries = 60;
  static const _delayedPresentRetry = Duration(milliseconds: 500);

  VoidCallback? onRoutineImported;

  Future<void> start() async {
    if (_started) {
      shareLinkLog('start() skipped — already started');
      return;
    }
    _started = true;
    shareLinkLog(
      'start() apiBase=${ApiConfig.profileApiBaseUrl} homeReady=$_homeReady',
    );

    _linkSubscription ??= _appLinks.uriLinkStream.listen(
      (uri) {
        shareLinkLog('uriLinkStream uri=$uri');
        _handleUri(uri, source: 'stream');
      },
      onError: (Object error, StackTrace stack) {
        shareLinkLog('uriLinkStream error=$error\n$stack');
      },
    );

    final initial = await _appLinks.getInitialLink();
    shareLinkLog('getInitialLink => $initial');
    if (initial != null) {
      _handleUri(initial, source: 'initial');
    }

    final latest = await _appLinks.getLatestLink();
    shareLinkLog('getLatestLink => $latest');
    if (latest != null && latest.toString() != initial?.toString()) {
      _handleUri(latest, source: 'latest');
    }
  }

  void dispose() {
    shareLinkLog('dispose()');
    _delayedPresentRetryTimer?.cancel();
    _delayedPresentRetryTimer = null;
    unawaited(_linkSubscription?.cancel());
    _linkSubscription = null;
    _started = false;
  }

  /// 백그라운드에서 공유 링크로 복귀할 때 `uriLinkStream`이 누락되거나
  /// 네비게이터가 준비되기 전에 재시도가 소진되는 경우를 복구한다.
  Future<void> onAppResumed() async {
    shareLinkLog(
      'onAppResumed() pending=$_pendingShareId presenting=$_presentingShareId',
    );
    _presentRetryCount = 0;

    try {
      final latest = await _appLinks.getLatestLink();
      shareLinkLog('onAppResumed getLatestLink => $latest');
      if (latest != null) {
        _handleUri(latest, source: 'resume');
      }
    } catch (error, stack) {
      shareLinkLog('onAppResumed getLatestLink error=$error\n$stack');
    }

    if (_pendingShareId != null) {
      unawaited(_presentPending());
    }
  }

  void onHomeReady() {
    shareLinkLog(
      'onHomeReady() pending=$_pendingShareId presenting=$_presentingShareId',
    );
    _homeReady = true;
    _presentRetryCount = 0;
    unawaited(_presentPending());
  }

  void _handleUri(Uri uri, {required String source}) {
    shareLinkLog(
      'handleUri source=$source uri=$uri host=${uri.host} path=${uri.path}',
    );

    if (uri.scheme.toLowerCase() != 'https' &&
        uri.scheme.toLowerCase() != 'http' &&
        uri.scheme.toLowerCase() != RoutineShareApi.appLinkScheme) {
      shareLinkLog('handleUri ignored — unsupported scheme ${uri.scheme}');
      return;
    }

    final uriKey = uri.toString();
    if (uriKey == _lastHandledUri) {
      if (_pendingShareId != null) {
        shareLinkLog(
          'handleUri duplicate uri — retry present pending=$_pendingShareId',
        );
        _presentRetryCount = 0;
        unawaited(_presentPending());
      } else {
        shareLinkLog('handleUri ignored — duplicate uri');
      }
      return;
    }

    final shareId = RoutineShareApi.shareIdFromDeepLink(uri);
    if (shareId == null) {
      if (uri.scheme.toLowerCase() == 'https' ||
          uri.scheme.toLowerCase() == 'http') {
        shareLinkLog(
          'handleUri ignored — shareId parse failed (expected host '
          '${Uri.parse(ApiConfig.profileApiBaseUrl).host})',
        );
      }
      return;
    }

    _lastHandledUri = uriKey;
    shareLinkLog('handleUri enqueue shareId=$shareId');
    _enqueueShareId(shareId);
  }

  void _enqueueShareId(String shareId) {
    if (shareId.isEmpty) return;
    if (shareId == _presentingShareId) {
      shareLinkLog('enqueue ignored — already presenting shareId=$shareId');
      return;
    }
    _pendingShareId = shareId;
    unawaited(_presentPending());
  }

  void _schedulePresentRetry(String reason) {
    if (_pendingShareId == null) return;
    if (_presentRetryCount >= _maxPresentRetries) {
      shareLinkLog(
        'present frame retries exhausted ($reason) — scheduling delayed retry',
      );
      _scheduleDelayedPresentRetry();
      return;
    }
    _presentRetryCount++;
    shareLinkLog(
      'present retry #$_presentRetryCount in next frame ($reason)',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_presentPending());
    });
  }

  void _scheduleDelayedPresentRetry() {
    if (_pendingShareId == null) return;
    _delayedPresentRetryTimer?.cancel();
    _delayedPresentRetryTimer = Timer(_delayedPresentRetry, () {
      _delayedPresentRetryTimer = null;
      if (_pendingShareId == null) return;
      shareLinkLog('present delayed retry pending=$_pendingShareId');
      _presentRetryCount = 0;
      unawaited(_presentPending());
    });
  }

  Future<void> _presentPending() async {
    if (!_homeReady) {
      shareLinkLog(
        'presentPending deferred — home not ready (pending=$_pendingShareId)',
      );
      return;
    }
    if (_pendingShareId == null) {
      shareLinkLog('presentPending noop — no pending shareId');
      return;
    }
    if (_presentingShareId != null) {
      shareLinkLog(
        'presentPending deferred — already presenting $_presentingShareId',
      );
      return;
    }

    final navigator = navigatorKey.currentState;
    final context = navigatorKey.currentContext;
    if (navigator == null || context == null || !context.mounted) {
      _schedulePresentRetry('navigator/context not ready');
      return;
    }

    final shareId = _pendingShareId!;
    _pendingShareId = null;
    _presentingShareId = shareId;
    _presentRetryCount = 0;
    shareLinkLog('presentPending showing dialog shareId=$shareId');

    try {
      await _presentImportFlow(context, shareId);
    } finally {
      if (_presentingShareId == shareId) {
        _presentingShareId = null;
      }
      if (_pendingShareId != null) {
        unawaited(_presentPending());
      }
    }
  }

  Future<void> _presentImportFlow(BuildContext context, String shareId) async {
    final l10n = AppLocalizations.of(context);
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      shareLinkLog('presentImportFlow aborted — navigator null');
      return;
    }

    shareLinkLog('showDialog confirm shareId=$shareId');
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sharedRoutineImportTitle),
        content: Text(l10n.sharedRoutineImportPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.sharedRoutineImportYes),
          ),
        ],
      ),
    );

    shareLinkLog('confirm dialog result=$confirmed');
    if (confirmed != true || !context.mounted) return;

    shareLinkLog('fetchSharedRoutine shareId=$shareId');
    unawaited(
      showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (ctx) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final routine = await _shareApi.fetchSharedRoutine(shareId);
      shareLinkLog('fetchSharedRoutine ok title=${routine.title}');
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      final saved = await repository.importSharedRoutine(routine);
      shareLinkLog('importSharedRoutine ok localId=${saved.id}');
      await AppAnalyticsService.logRoutineDownload(source: 'shared_link');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineAddedToMyRoutines(saved.title))),
      );
      onRoutineImported?.call();
    } on RoutineShareApiException catch (error) {
      shareLinkLog('fetch/import RoutineShareApiException: ${error.message}');
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      final message = error.message.contains('not found')
          ? l10n.sharedRoutineNotFound
          : l10n.sharedRoutineImportError;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error, stack) {
      shareLinkLog('fetch/import error=$error\n$stack');
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineDownloadError)),
      );
    }
  }
}
