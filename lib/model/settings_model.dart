// settings_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TruthFormat { vf, binary } // V/F  o  1/0

enum MintermOrder { asc, desc }

enum KeypadMode { advanced, simple }

class Settings extends ChangeNotifier {
  Locale locale = const Locale('es');
  ThemeMode themeMode = ThemeMode.system;
  TruthFormat truthFormat = TruthFormat.vf;
  MintermOrder mintermOrder = MintermOrder.asc;
  KeypadMode keypadMode = KeypadMode.advanced;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    locale = Locale(prefs.getString('locale') ?? 'es');
    themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    truthFormat = TruthFormat.values[prefs.getInt('truthFormat') ?? 0];
    mintermOrder = MintermOrder.values[prefs.getInt('mintermOrder') ?? 0];
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

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await load();
  }

  bool isDarkMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }
}
