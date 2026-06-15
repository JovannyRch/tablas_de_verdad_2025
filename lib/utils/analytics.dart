/// Analytics helper — Firebase Analytics + local SharedPreferences counters.
///
/// Call-sites use [Analytics.instance] unchanged.
/// Firebase is optional: if initialization fails (e.g. missing config),
/// events are only stored locally and the app continues normally.
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Analytics {
  Analytics._();
  static final instance = Analytics._();

  bool _firebaseReady = false;

  /// Called by main() after Firebase.initializeApp() succeeds.
  void markFirebaseReady() => _firebaseReady = true;

  // ── Public API (unchanged) ─────────────────────────────────────────────────

  Future<void> logExpressionCalculated(String expression) async {
    _fa('expression_calculated', {'expression': _cap(expression)});
    await _increment('stat_expressions_calculated');
  }

  Future<void> logPdfExported() async {
    _fa('pdf_exported');
    await _increment('stat_pdfs_exported');
  }

  Future<void> logProConversion() async {
    _fa('pro_conversion');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stat_pro_converted', true);
  }

  Future<void> logFavoriteAdded(String expression) async {
    _fa('favorite_added', {'expression': _cap(expression)});
    await _increment('stat_favorites_added');
  }

  Future<void> logExpressionShared() async {
    _fa('expression_shared');
    await _increment('stat_expressions_shared');
  }

  Future<void> logOnboardingCompleted() async {
    _fa('onboarding_completed');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stat_onboarding_completed', true);
  }

  /// Track a generic custom event.
  /// [name] must be snake_case; illegal chars are replaced with underscores.
  Future<void> logEvent(String name) async {
    final safeName = _safeName(name);
    _fa(safeName);
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

  /// Truncate string parameter values to Firebase's 100-char limit.
  static String _cap(String s) =>
      s.length > 100 ? s.substring(0, 100) : s;

  /// Sanitize event names: letters/digits/underscores, max 40 chars.
  static String _safeName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return sanitized.length > 40 ? sanitized.substring(0, 40) : sanitized;
  }
}
