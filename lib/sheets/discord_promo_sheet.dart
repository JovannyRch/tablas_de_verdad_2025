import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
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
    builder: (_) => const _DiscordPromoSheet(),
  );
}

class _DiscordPromoSheet extends StatelessWidget {
  const _DiscordPromoSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF5865F2).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.discord,
              color: Color(0xFF5865F2),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Únete a la comunidad!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comparte expresiones, resuelve dudas y aprende lógica junto con otros estudiantes en nuestro servidor de Discord.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                visit(DISCORD_URL, mode: LaunchMode.platformDefault);
              },
              icon: const FaIcon(FontAwesomeIcons.discord, size: 18),
              label: const Text(
                'Unirse al Discord',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5865F2),
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
                'Quizás más tarde',
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
