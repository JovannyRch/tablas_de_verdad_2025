import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/const/routes.dart';
import 'package:tablas_de_verdad_2025/dialogs/history_dialog.dart';
import 'package:tablas_de_verdad_2025/dialogs/favorites_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/open_support_chat.dart';
import 'package:tablas_de_verdad_2025/utils/show_pro_version_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/show_rating_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        children: [
          // -- CUSTOM HEADER --
          _buildHeader(context, t),

          // -- ITEMS --
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerTile(
                  icon: Icons.history_rounded,
                  title: t.calculationHistory,
                  onTap: () async {
                    Navigator.pop(context);
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
                _DrawerTile(
                  icon: Icons.favorite_rounded,
                  title: t.favorites,
                  iconColor: Colors.redAccent,
                  onTap: () async {
                    Navigator.pop(context);
                    final selectedExpr = await showDialog<String>(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => const FavoritesDialog(),
                    );
                    if (selectedExpr != null) {
                      onExpressionSelected(selectedExpr);
                    }
                  },
                ),
                _DrawerTile(
                  icon: Icons.auto_stories_outlined,
                  title: t.expressionLibrary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.library);
                  },
                ),
                _DrawerTile(
                  icon: Icons.quiz_rounded,
                  title: t.practiceMode,
                  iconColor: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.practice);
                  },
                ),
                _DrawerTile(
                  icon: Icons.compare_arrows_rounded,
                  title: t.equivalenceChecker,
                  iconColor: const Color(0xFF2196F3),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.equivalence);
                  },
                ),
                _DrawerTile(
                  icon: FontAwesomeIcons.youtube,
                  title: t.youtubeChannel,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    visit(YOUTUBE_URL);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(thickness: 0.5),
                ),
                _DrawerTile(
                  icon:
                      settings.isProVersion
                          ? Icons.support_agent_rounded
                          : Icons.lock_outline_rounded,
                  title: t.premiumSupport,
                  onTap: () {
                    if (settings.isProVersion) {
                      openSupportChat();
                    } else {
                      showProVersionDialog(context, settings, t);
                    }
                  },
                ),
                _DrawerTile(
                  icon: Icons.star_outline_rounded,
                  title: t.rateTheApp,
                  iconColor: Colors.amber,
                  onTap: () {
                    Navigator.pop(context);
                    showRatingDialog(context);
                  },
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  title: t.settings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.settings);
                  },
                ),
              ],
            ),
          ),

          // -- BOTTOM CTA SECTION --
          if (!isPro) _buildUpgradeCard(context, t, settings),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kSeedColor, kSeedColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.functions,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              if (isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            t.appName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version =
                  snapshot.hasData ? "v${snapshot.data!.version}" : "...";
              return Text(
                version,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context,
    AppLocalizations t,
    Settings settings,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFACC15), Color(0xFFEAB308)], // Yellow-400 to 600
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            onUpgrade();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.diamond_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.upgradePro,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        t.fullFeatureAccess,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading:
            icon is IconData
                ? Icon(
                  icon,
                  color:
                      iconColor ?? (isDark ? Colors.white70 : Colors.black54),
                  size: 22,
                )
                : FaIcon(icon as IconData, color: iconColor, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            letterSpacing: -0.2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
      ),
    );
  }
}
