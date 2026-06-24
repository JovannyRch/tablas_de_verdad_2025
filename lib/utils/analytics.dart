/// Analytics helper — Firebase Analytics + Supabase + local SharedPreferences.
///
/// Call-sites use [Analytics.instance] unchanged.
/// Both Firebase and Supabase are optional: if initialization fails
/// (e.g. missing config, no network) events are only stored locally and the
/// app continues normally.
library;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Analytics {
  Analytics._();
  static final instance = Analytics._();

  bool _firebaseReady = false;
  bool _supabaseReady = false;
  String? _appVersion;
  String? _cachedDeviceId;

  /// Called by main() after Firebase.initializeApp() succeeds.
  void markFirebaseReady() => _firebaseReady = true;

  /// Called by main() after Supabase.initialize() succeeds.
  /// Preloads the app version and ensures the anonymous device id exists.
  Future<void> markSupabaseReady() async {
    _supabaseReady = true;
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
    } catch (_) {
      // package_info unavailable — leave version null.
    }
    await _deviceId();
  }

  // ── Public API (unchanged) ─────────────────────────────────────────────────

  Future<void> logExpressionCalculated(String expression) async {
    _fa('expression_calculated', {'expression': _cap(expression)});
    _sb('expression_calculated', expression: expression);
    await _increment('stat_expressions_calculated');
  }

  Future<void> logPdfExported() async {
    _fa('pdf_exported');
    _sb('pdf_exported');
    await _increment('stat_pdfs_exported');
  }

  Future<void> logProConversion() async {
    _fa('pro_conversion');
    _sb('pro_conversion');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stat_pro_converted', true);
  }

  Future<void> logFavoriteAdded(String expression) async {
    _fa('favorite_added', {'expression': _cap(expression)});
    _sb('favorite_added', expression: expression);
    await _increment('stat_favorites_added');
  }

  Future<void> logExpressionShared() async {
    _fa('expression_shared');
    _sb('expression_shared');
    await _increment('stat_expressions_shared');
  }

  Future<void> logOnboardingCompleted() async {
    _fa('onboarding_completed');
    _sb('onboarding_completed');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stat_onboarding_completed', true);
  }

  /// Track a generic custom event.
  /// [name] must be snake_case; illegal chars are replaced with underscores.
  Future<void> logEvent(String name) async {
    final safeName = _safeName(name);
    _fa(safeName);
    _sb(safeName);
    await _increment('stat_$name');
  }

  /// Local stats snapshot — useful for a debug/settings screen.
  Future<Map<String, int>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('stat_'));
    return {
      for (final k in keys) k.replaceFirst('stat_', ''): prefs.getInt(k) ?? 0,
    };
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  /// Fire-and-forget Firebase Analytics event. Never throws.
  void _fa(String name, [Map<String, Object>? parameters]) {
    if (!_firebaseReady) return;
    FirebaseAnalytics.instance
        .logEvent(name: name, parameters: parameters)
        .catchError((Object e) => debugPrint('Analytics._fa: $e'));
  }

  Future<void> _increment(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  /// Fire-and-forget mirror of an event into Supabase `tv_events`.
  /// Never throws and never blocks the caller.
  void _sb(String name, {String? expression, Map<String, dynamic>? params}) {
    if (!_supabaseReady) return;
    unawaited(_sendToSupabase(name, expression: expression, params: params));
  }

  Future<void> _sendToSupabase(
    String name, {
    String? expression,
    Map<String, dynamic>? params,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Supabase.instance.client.from('tv_events').insert({
        'device_id': await _deviceId(),
        'event_name': name,
        if (expression != null) 'expression': _cap(expression),
        'locale': prefs.getString('locale'),
        'is_pro': prefs.getBool('isProVersion') ?? false,
        'platform': _platform(),
        'app_version': _appVersion,
        if (params != null && params.isNotEmpty) 'params': params,
      });
    } catch (e) {
      debugPrint('Analytics._sb: $e');
    }
  }

  /// Anonymous, per-install device id (UUID v4) persisted in SharedPreferences.
  Future<String> _deviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('tv_device_id');
    if (id == null) {
      id = _uuidV4();
      await prefs.setString('tv_device_id', id);
    }
    return _cachedDeviceId = id;
  }

  static String _platform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    return 'other';
  }

  /// Minimal UUID v4 generator (avoids adding the `uuid` dependency).
  static String _uuidV4() {
    final r = Random();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // version 4
    b[8] = (b[8] & 0x3f) | 0x80; // variant 1
    String h(int i) => b[i].toRadixString(16).padLeft(2, '0');
    final s = List.generate(16, h).join();
    return '${s.substring(0, 8)}-${s.substring(8, 12)}-'
        '${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
  }

  /// Truncate string parameter values to Firebase's 100-char limit.
  static String _cap(String s) => s.length > 100 ? s.substring(0, 100) : s;

  /// Sanitize event names: letters/digits/underscores, max 40 chars.
  static String _safeName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return sanitized.length > 40 ? sanitized.substring(0, 40) : sanitized;
  }
}
