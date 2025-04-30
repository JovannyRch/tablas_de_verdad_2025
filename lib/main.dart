import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/const/routes.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/calculator_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/screens/expression_library_screen.dart';
import 'package:tablas_de_verdad_2025/screens/privacy_policy_screen.dart';
import 'package:tablas_de_verdad_2025/screens/settings_screen.dart';

const Color kSeedColor = Colors.deepOrange;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = Settings();
  await settings.load();
  /*  await InAppPurchase.instance
      .restorePurchases(); // TODO: Check if this is needed */

  runApp(
    ChangeNotifierProvider.value(value: settings, child: const TruthTableApp()),
  );
}

class TruthTableApp extends StatelessWidget {
  const TruthTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final t = AppLocalizations.of(context);

    return MaterialApp(
      locale: settings.locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      title: t?.appName ?? APP_NAME,

      initialRoute: Routes.calculator,
      routes: {
        Routes.calculator: (context) => const CalculatorScreen(),
        Routes.settings: (context) => const SettingsScreen(),
        Routes.library: (context) => const ExpressionLibraryScreen(),
        Routes.privacy: (context) => PrivacyPolicyScreen(),
      },
    );
  }
}
