import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

const _prefKey = 'discordPromoShown';
const _showAfterEvaluations = 5;

Future<bool> shouldShowDiscordPromo(int operationsCount) async {
  if (operationsCount != _showAfterEvaluations) return false;
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_prefKey) ?? false);
}

Future<void> markDiscordPromoShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_prefKey, true);
}

Future<void> showDiscordPromoSheet(BuildContext context) async {
  await markDiscordPromoShown();
  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _InstagramPromoSheet(),
  );
}

class _InstagramPromoSheet extends StatelessWidget {
  const _InstagramPromoSheet();

  static const _igColor = Color(0xFFE1306C);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _igColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.instagram,
              color: _igColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.instagramPromoTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '@jovanny.rch',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _igColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                visit(INSTAGRAM_URL, mode: LaunchMode.platformDefault);
              },
              icon: const FaIcon(FontAwesomeIcons.instagram, size: 18),
              label: Text(
                t.instagramPromoButton,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _igColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                t.instagramPromoLater,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
