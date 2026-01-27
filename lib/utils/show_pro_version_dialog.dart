import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/widget/benefit_item.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';

Future<void> showProVersionDialog(
  BuildContext context,
  Settings settings,
  AppLocalizations localizations,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder:
        (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono o imagen grande
                Container(
                  padding: const EdgeInsets.all(12),
                  /*  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ), */
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Título
                Text(
                  localizations.becomePro,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),
                // Lista de beneficios
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BenefitItem(
                      icon: Icons.lock_open,
                      text: localizations.fullFeatureAccess,
                    ),
                    /*     BenefitItem(
                      icon: Icons.show_chart,
                      text: 'Gráficas avanzadas',
                    ),
                    BenefitItem(
                      icon: Icons.download,
                      text: 'Exporta a Excel y PDF',
                    ),
                     */
                    BenefitItem(
                      icon: Icons.support_agent,
                      text: localizations.premiumSupport,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(localizations.later),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (IS_TESTING) {
                            settings.activateProLocally();
                          } else {
                            settings.buyPro();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          localizations.buyPro,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}
