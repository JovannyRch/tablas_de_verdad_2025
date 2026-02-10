import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/const/routes.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/calculator_screen.dart';
import 'package:tablas_de_verdad_2025/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/screens/expression_library_screen.dart';
import 'package:tablas_de_verdad_2025/screens/practice_mode_screen.dart';
import 'package:tablas_de_verdad_2025/screens/privacy_policy_screen.dart';
import 'package:tablas_de_verdad_2025/screens/settings_screen.dart';

// kSeedColor se define en colors.dart — no redefinir aquí

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = Settings();
  await settings.load();
  MobileAds.instance.initialize();

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: TruthTableApp(showOnboarding: !hasSeenOnboarding),
    ),
  );
}

class TruthTableApp extends StatelessWidget {
  final bool showOnboarding;

  const TruthTableApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final t = AppLocalizations.of(context);

    //settings.desactivateProLocally(); // Forzar desactivación de Pro

    return MaterialApp(
      locale: settings.locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
        Locale('pt'),
        Locale('fr'),
        Locale('de'),
        Locale('hi'),
        Locale('ru'),
        Locale('it'),
        Locale('zh'),
        Locale('ja'),
      ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      title: t?.appName ?? APP_NAME,

      initialRoute: showOnboarding ? Routes.onboarding : Routes.calculator,
      routes: {
        Routes.onboarding: (context) => const OnboardingScreen(),
        Routes.calculator: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return CalculatorScreen(initialExpression: args);
        },
        Routes.settings: (context) => const SettingsScreen(),
        Routes.library: (context) => const ExpressionLibraryScreen(),
        Routes.practice: (context) => const PracticeModeScreen(),
        Routes.privacy: (context) => PrivacyPolicyScreen(),
      },
    );
  }
}
