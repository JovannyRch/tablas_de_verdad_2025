/// Lightweight analytics helper.
///
/// Currently persists key events locally via SharedPreferences counters.
/// When Firebase Analytics is added later, swap the implementation inside
/// each method without touching call-sites.
library;

import 'package:shared_preferences/shared_preferences.dart';

class Analytics {
  Analytics._();
  static final instance = Analytics._();

  /// Track when a truth table is calculated
  Future<void> logExpressionCalculated(String expression) async {
    await _increment('stat_expressions_calculated');
  }

  /// Track when a PDF is exported
  Future<void> logPdfExported() async {
    await _increment('stat_pdfs_exported');
  }

  /// Track when user upgrades to Pro
  Future<void> logProConversion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stat_pro_converted', true);
  }

  /// Track when a favorite is added
  Future<void> logFavoriteAdded(String expression) async {
    await _increment('stat_favorites_added');
  }

  /// Track when an expression is shared
  Future<void> logExpressionShared() async {
    await _increment('stat_expressions_shared');
  }

  /// Track onboarding completion
  Future<void> logOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stat_onboarding_completed', true);
  }

  /// Track a generic custom event
  Future<void> logEvent(String name) async {
    await _increment('stat_$name');
  }

  /// Retrieve all local stats (useful for debugging / settings screen)
  Future<Map<String, int>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('stat_'));
    return {
      for (final k in keys) k.replaceFirst('stat_', ''): prefs.getInt(k) ?? 0,
    };
  }

  // ── Internal ──────────────────────────────────────────

  Future<void> _increment(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }
}
