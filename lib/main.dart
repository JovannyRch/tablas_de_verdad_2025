import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/utils/analytics.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/const/routes.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/calculator_screen.dart';
import 'package:tablas_de_verdad_2025/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/screens/expression_library_screen.dart';
import 'package:tablas_de_verdad_2025/screens/equivalence_screen.dart';
import 'package:tablas_de_verdad_2025/screens/argument_validator_screen.dart';
import 'package:tablas_de_verdad_2025/screens/practice_mode_screen.dart';
import 'package:tablas_de_verdad_2025/screens/privacy_policy_screen.dart';
import 'package:tablas_de_verdad_2025/screens/settings_screen.dart';

// kSeedColor se define en colors.dart — no redefinir aquí

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebase();

  final settings = Settings();
  await settings.load();
  MobileAds.instance.initialize();

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Check if the app was opened from a deep link (cold start)
  final appLinks = AppLinks();
  final initialUri = await appLinks.getInitialLink();
  final initialExpression = _extractExpression(initialUri);

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: TruthTableApp(
        showOnboarding: !hasSeenOnboarding,
        initialExpression: initialExpression,
      ),
    ),
  );
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();

    // Pass Flutter framework errors to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass uncaught asynchronous errors (Platform exceptions, isolate errors).
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    Analytics.instance.markFirebaseReady();
  } catch (e, stack) {
    // Firebase not configured or google-services.json missing — app still works,
    // just without remote analytics/crash reporting.
    debugPrint('Firebase init skipped: $e\n$stack');
  }
}

/// Extracts the `expression` query parameter from a deep link URI.
String? _extractExpression(Uri? uri) {
  if (uri == null) return null;
  final expr = uri.queryParameters['expression'];
  if (expr == null || expr.isEmpty) return null;
  return expr;
}

class TruthTableApp extends StatefulWidget {
  final bool showOnboarding;
  final String? initialExpression;

  const TruthTableApp({
    super.key,
    this.showOnboarding = false,
    this.initialExpression,
  });

  @override
  State<TruthTableApp> createState() => _TruthTableAppState();
}

class _TruthTableAppState extends State<TruthTableApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // Listen for deep links while the app is running (warm/hot start)
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      final expression = _extractExpression(uri);
      if (expression != null) {
        // Pop to root and push calculator with expression
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        _navigatorKey.currentState?.pushReplacementNamed(
          Routes.calculator,
          arguments: expression,
        );
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final t = AppLocalizations.of(context);

    //settings.desactivateProLocally(); // Forzar desactivación de Pro

    return MaterialApp(
      navigatorKey: _navigatorKey,
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

      initialRoute:
          widget.showOnboarding ? Routes.onboarding : Routes.calculator,
      routes: {
        Routes.onboarding: (context) => const OnboardingScreen(),
        Routes.calculator: (context) {
          // Deep link expression takes priority over route arguments
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return CalculatorScreen(
            initialExpression: args ?? widget.initialExpression,
          );
        },
        Routes.settings: (context) => const SettingsScreen(),
        Routes.library: (context) => const ExpressionLibraryScreen(),
        Routes.practice: (context) => const PracticeModeScreen(),
        Routes.equivalence: (context) => const EquivalenceScreen(),
        Routes.argumentValidator: (context) => const ArgumentValidatorScreen(),
        Routes.privacy: (context) => PrivacyPolicyScreen(),
      },
    );
  }
}
