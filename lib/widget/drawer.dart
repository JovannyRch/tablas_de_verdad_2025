import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/const/routes.dart';
import 'package:tablas_de_verdad_2025/dialogs/history_dialog.dart';
import 'package:tablas_de_verdad_2025/main.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/open_support_chat.dart';
import 'package:tablas_de_verdad_2025/utils/show_pro_version_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/show_rating_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';

class AppDrawer extends StatelessWidget {
  final bool isPro;
  final VoidCallback onUpgrade;
  final VoidCallback onLogout;
  final void Function(String) onExpressionSelected;

  const AppDrawer({
    super.key,

    this.isPro = false,
    required this.onUpgrade,
    required this.onLogout,
    required this.onExpressionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settings = context.watch<Settings>();

    Widget buildTile(IconData icon, String title, String routeName) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, routeName);
        },
      );
    }

    Widget buildHistoryDialog(
      IconData icon,
      String title,
      Function(BuildContext context) onTap,
    ) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.pop(context);
          onTap(context);
        },
      );
    }

    return Drawer(
      child: Column(
        children: [
          // -- HEADER --
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: kSeedColor),
            accountName: Text(
              t.appName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(""),

            otherAccountsPictures:
                isPro
                    ? [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                    : null,
          ),

          // -- ITEMS --
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildHistoryDialog(
                  Icons.calculate_outlined,
                  t.calculationHistory,
                  (BuildContext context) async {
                    final selectedExpr = await showDialog<String>(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => const HistoryDialog(),
                    );
                    if (selectedExpr != null) {
                      onExpressionSelected(selectedExpr);
                    }
                  },
                ),
                buildTile(
                  Icons.folder_outlined,
                  t.expressionLibrary,
                  Routes.library,
                ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.youtube,
                    color: Colors.red,
                  ),
                  title: Text(t.youtubeChannel),
                  onTap: () {
                    visit(YOUTUBE_URL);
                  },
                ),

                if (settings.isProVersion)
                  ListTile(
                    leading: const Icon(Icons.support_agent),
                    title: Text(t.premiumSupport),
                    onTap: openSupportChat,
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: Text(t.premiumSupport),
                    onTap: () => showProVersionDialog(context, settings, t),
                  ),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(t.rateTheApp),
                  onTap: () {
                    Navigator.pop(context);
                    showRatingDialog(context);
                  },
                ),
                buildTile(Icons.settings, t.settings, Routes.settings),
              ],
            ),
          ),

          const Divider(height: 1),

          // -- SECTION: UPGRADE or LOGOUT --
          if (!isPro)
            ListTile(
              leading: Icon(Icons.diamond, color: Colors.amber),
              title: Text(t.upgradePro),
              onTap: () {
                Navigator.pop(context);
                onUpgrade();
              },
              tileColor: Colors.amber.withOpacity(0.1),
            ),

          /*   ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
            hoverColor: Colors.redAccent,
          ), */
        ],
      ),
    );
  }
}
