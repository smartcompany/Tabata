import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/api_config.dart';

const _uuid = Uuid();

/// Best-effort first-party analytics transport.
///
/// Events are persisted before upload, sent in batches, and never block product
/// flows. No prompts, routine content, URLs, health values, or ad identifiers
/// belong in [properties].
class ProductAnalyticsTransport {
  ProductAnalyticsTransport._();

  static final shared = ProductAnalyticsTransport._();

  static const _installIdKey = 'product_analytics_install_id_v1';
  static const _firstOpenSentKey = 'product_analytics_first_open_v1';
  static const _queueKey = 'product_analytics_queue_v1';
  static const _enabledKey = 'product_analytics_enabled_v1';
  static const _maxQueueSize = 200;
  static const _batchSize = 50;

  final _sessionId = _uuid.v4();
  SharedPreferences? _preferences;
  String? _installId;
  var _flushInProgress = false;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    await ensureInstallId();

    if (!isEnabled) return;
    if (!(_preferences!.getBool(_firstOpenSentKey) ?? false)) {
      await log('first_open');
      await _preferences!.setBool(_firstOpenSentKey, true);
    }
    await log('app_open');
  }

  bool get isEnabled => _preferences?.getBool(_enabledKey) ?? true;

  /// Stable pseudonymous install id (SharedPreferences). Used by analytics
  /// and server entitlements when the user is not logged in.
  Future<String> ensureInstallId() async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;
    var id = _installId ?? prefs.getString(_installIdKey);
    if (id == null || id.isEmpty) {
      id = _uuid.v4();
      await prefs.setString(_installIdKey, id);
    }
    _installId = id;
    return id;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;
    await prefs.setBool(_enabledKey, enabled);
    if (!enabled) {
      await prefs.remove(_queueKey);
    } else {
      unawaited(flush());
    }
  }

  Future<void> log(
    String eventName, {
    Map<String, Object> properties = const {},
  }) async {
    if (!isEnabled) return;
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;
    _installId ??= prefs.getString(_installIdKey);
    if (_installId == null || _installId!.isEmpty) {
      _installId = _uuid.v4();
      await prefs.setString(_installIdKey, _installId!);
    }

    final queue = _readQueue(prefs);
    queue.add({
      'eventId': _uuid.v4(),
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
      'installId': _installId,
      'sessionId': _sessionId,
      'eventName': eventName,
      'platform': _platform,
      'appVersion': const String.fromEnvironment(
        'APP_VERSION',
        defaultValue: '',
      ),
      'locale': Platform.localeName.split(RegExp('[-_]')).first,
      'properties': properties,
    });
    if (queue.length > _maxQueueSize) {
      queue.removeRange(0, queue.length - _maxQueueSize);
    }
    await prefs.setString(_queueKey, jsonEncode(queue));
    unawaited(flush());
  }

  Future<void> flush() async {
    if (_flushInProgress || !isEnabled) return;
    final prefs = _preferences;
    if (prefs == null) return;
    final queue = _readQueue(prefs);
    if (queue.isEmpty) return;

    _flushInProgress = true;
    final batch = queue.take(_batchSize).toList(growable: false);
    try {
      final status = await _postEvents(batch);
      if (status >= 200 && status < 300) {
        await _removeSent(prefs, batch);
        return;
      }

      debugPrint(
        'Product analytics upload failed ($status) batch=${batch.length}',
      );

      // One invalid event used to reject the whole batch and block the queue.
      if (status == 400) {
        if (batch.length == 1) {
          debugPrint(
            'Product analytics drop event ${batch.first['eventName']}',
          );
          await _removeSent(prefs, batch);
          return;
        }
        for (final event in batch) {
          final oneStatus = await _postEvents([event]);
          if (oneStatus >= 200 && oneStatus < 300) {
            await _removeSent(prefs, [event]);
            continue;
          }
          if (oneStatus == 400) {
            debugPrint(
              'Product analytics drop event ${event['eventName']} ($oneStatus)',
            );
            await _removeSent(prefs, [event]);
          }
        }
      }
    } catch (error) {
      debugPrint('Product analytics upload error: $error');
    } finally {
      _flushInProgress = false;
    }
  }

  Future<int> _postEvents(List<Map<String, dynamic>> batch) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http
        .post(
          Uri.parse(
            '${ApiConfig.profileApiBaseUrl}/api/analytics/events',
          ),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'events': batch}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = response.body;
      if (body.isNotEmpty) {
        final preview =
            body.length > 240 ? '${body.substring(0, 240)}…' : body;
        debugPrint('Product analytics response: $preview');
      }
    }
    return response.statusCode;
  }

  Future<void> _removeSent(
    SharedPreferences prefs,
    List<Map<String, dynamic>> batch,
  ) async {
    final latest = _readQueue(prefs);
    final sentIds = batch.map((e) => e['eventId']).toSet();
    latest.removeWhere((e) => sentIds.contains(e['eventId']));
    await prefs.setString(_queueKey, jsonEncode(latest));
  }

  List<Map<String, dynamic>> _readQueue(SharedPreferences prefs) {
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String get _platform {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return kIsWeb ? 'web' : 'other';
  }
}
