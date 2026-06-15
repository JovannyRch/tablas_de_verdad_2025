import 'package:flutter/material.dart';

const kSeedColor = Color(0xFFFF942B); // color principal
const kMainColorLight = Color(0xFFF0E5DA);
const kSecondaryColor = Color(0xFFFBE6D1);
const kDisableColor = Color(0xFFFDF6E4);
// ~65% black instead of black54 (54%): black54 drops below the WCAG AA 4.5:1
// contrast ratio over the app's cream surfaces (kMainColorLight / kSecondaryColor);
// 0xA6 clears it on both white and cream while staying visually subdued.
const kLabelColor = Color(0xA6000000);
const kLabelColorDark = Colors.grey;

final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.light,
  ),
  useMaterial3: true, // opcional si quieres fondo claro custom
  textTheme: const TextTheme(
    labelLarge: TextStyle(color: kLabelColor),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  primaryColor: kSeedColor,
  primaryColorLight: kMainColorLight,
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.black,
  textTheme: const TextTheme(
    labelLarge: TextStyle(color: kLabelColorDark),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);
