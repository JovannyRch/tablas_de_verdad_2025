// settings_model.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/const/translations.dart';
import 'package:tablas_de_verdad_2025/service/purchase_service.dart';

enum TruthFormat { vf, binary } // V/F  o  1/0

enum MintermOrder { asc, desc }

enum KeypadMode { advanced, simple }

class Settings extends ChangeNotifier {
  Locale locale =
      APP_ID == "com.jovannyrch.tablasdeverdad"
          ? const Locale('es')
          : const Locale('en');
  ThemeMode themeMode = ThemeMode.system;
  TruthFormat truthFormat = TruthFormat.vf;
  MintermOrder mintermOrder = MintermOrder.asc;
  KeypadMode keypadMode = KeypadMode.advanced;
  bool isProVersion = false;
  int operationsCount = 0;
  int adFrequency =
      5; // Mostrar ad cada N operaciones (equilibrio retención/monetización)

  // Anti-stacking: cooldown entre anuncios de pantalla completa (60s)
  DateTime? _lastFullscreenAdTime;
  static const int _fullscreenCooldownSeconds = 60;

  // Usos gratuitos diarios de operadores premium
  int _dailyPremiumUsesCount = 0;
  String _lastPremiumUsesDate = '';
  static const int maxDailyPremiumUses = 3;

  final PurchaseService _purchaseService = PurchaseService();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    locale = Locale(prefs.getString('locale') ?? _detectSystemLocale());
    themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    truthFormat = TruthFormat.values[prefs.getInt('truthFormat') ?? 0];
    mintermOrder = MintermOrder.values[prefs.getInt('mintermOrder') ?? 0];

    // Restaurar operationsCount persistido
    operationsCount = prefs.getInt('operationsCount') ?? 0;

    // Restaurar usos premium diarios
    _lastPremiumUsesDate = prefs.getString('lastPremiumUsesDate') ?? '';
    _dailyPremiumUsesCount = prefs.getInt('dailyPremiumUsesCount') ?? 0;
    _resetDailyUsesIfNewDay();

    // Escuchar cambios del estado Pro
    _purchaseService.isProVersion.addListener(() {
      isProVersion = _purchaseService.isProVersion.value;
      notifyListeners();
    });

    // Inicializar listener y restaurar compras
    _purchaseService.initPurchaseListener();
    await _purchaseService.restorePurchases();

    // Leer local por si ya se activó previamente (fallback)
    final localFlag = prefs.getBool('isProVersion') ?? false;
    if (!isProVersion && localFlag) {
      isProVersion = true;
      notifyListeners();
    }

    notifyListeners();
  }

  Future<void> update({
    Locale? locale,
    ThemeMode? themeMode,
    TruthFormat? truthFormat,
    MintermOrder? mintermOrder,
    KeypadMode? keypadMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      this.locale = locale;
      prefs.setString('locale', locale.languageCode);
    }
    if (themeMode != null) {
      this.themeMode = themeMode;
      prefs.setInt('themeMode', themeMode.index);
    }
    if (truthFormat != null) {
      this.truthFormat = truthFormat;
      prefs.setInt('truthFormat', truthFormat.index);
    }
    if (mintermOrder != null) {
      this.mintermOrder = mintermOrder;
      prefs.setInt('mintermOrder', mintermOrder.index);
    }

    if (keypadMode != null) {
      this.keypadMode = keypadMode;
      prefs.setInt('keypadMode', keypadMode.index);
    }
    notifyListeners();
  }

  Future<void> incrementOperationsCount() async {
    operationsCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('operationsCount', operationsCount);
    notifyListeners();
  }

  bool shouldShowInterstitialAd() {
    return !isProVersion &&
        operationsCount % adFrequency == 0 &&
        canShowFullscreenAd();
  }

  /// Anti-stacking: verifica si ha pasado suficiente tiempo desde el último ad fullscreen
  bool canShowFullscreenAd() {
    if (isProVersion) return false;
    if (_lastFullscreenAdTime == null) return true;
    return DateTime.now().difference(_lastFullscreenAdTime!).inSeconds >=
        _fullscreenCooldownSeconds;
  }

  /// Marca que se acaba de mostrar un anuncio de pantalla completa
  void markFullscreenAdShown() {
    _lastFullscreenAdTime = DateTime.now();
  }

  /// Verifica si el usuario puede usar operadores premium gratis hoy
  bool hasFreePremmiumUsesRemaining() {
    _resetDailyUsesIfNewDay();
    return _dailyPremiumUsesCount < maxDailyPremiumUses;
  }

  /// Retorna la cantidad de usos gratuitos restantes hoy
  int get remainingFreePremiumUses {
    _resetDailyUsesIfNewDay();
    return maxDailyPremiumUses - _dailyPremiumUsesCount;
  }

  /// Consume un uso gratuito diario de operador premium
  Future<void> consumeFreePremiumUse() async {
    _resetDailyUsesIfNewDay();
    _dailyPremiumUsesCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyPremiumUsesCount', _dailyPremiumUsesCount);
    notifyListeners();
  }

  /// Reinicia el contador diario si cambió el día
  void _resetDailyUsesIfNewDay() {
    final today = DateTime.now().toIso8601String().substring(
      0,
      10,
    ); // YYYY-MM-DD
    if (_lastPremiumUsesDate != today) {
      _dailyPremiumUsesCount = 0;
      _lastPremiumUsesDate = today;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('lastPremiumUsesDate', today);
        prefs.setInt('dailyPremiumUsesCount', 0);
      });
    }
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await load();
  }

  bool isDarkMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }

  Future<void> activateProLocally() async {
    final prefs = await SharedPreferences.getInstance();
    isProVersion = true;
    await prefs.setBool('isProVersion', true);
    notifyListeners();
  }

  Future<void> desactivateProLocally() async {
    final prefs = await SharedPreferences.getInstance();
    isProVersion = false;
    await prefs.setBool('isProVersion', false);
    notifyListeners();
  }

  Future<void> buyPro() async {
    await _purchaseService.buyProVersion();
  }

  /// Detecta el idioma del sistema y retorna el código de idioma soportado más cercano
  String _detectSystemLocale() {
    // Obtener el idioma del sistema
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final languageCode = systemLocale.languageCode;

    // Lista de idiomas soportados
    const supportedLanguages = [
      'es',
      'en',
      'pt',
      'fr',
      'de',
      'hi',
      'ru',
      'it',
      'zh',
      'ja',
    ];

    // Si el idioma del sistema está soportado, usarlo
    if (supportedLanguages.contains(languageCode)) {
      return languageCode;
    }

    // Fallback: usar el valor por defecto según APP_ID
    return defaultLocale();
  }

  String defaultLocale() {
    if (APP_ID == "com.jovannyrch.tablasdeverdad") {
      return 'es';
    } else {
      return 'en';
    }
  }
}
