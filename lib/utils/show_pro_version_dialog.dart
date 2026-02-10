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
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder:
        (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  // Top Gradient Accent
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withOpacity(0.15),
                            const Color(0xFFFF8C00).withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Premium Icon
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A00E0).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.diamond_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          localizations.becomePro,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Benefits List
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black12,
                            ),
                          ),
                          child: Column(
                            children: [
                              BenefitItem(
                                icon: Icons.ads_click_rounded,
                                text: localizations.noAds,
                              ),
                              BenefitItem(
                                icon: Icons.auto_awesome_rounded,
                                text: localizations.fullFeatureAccess,
                              ),
                              BenefitItem(
                                icon: Icons.terminal_rounded,
                                text: localizations.premiumOperatorsAccess,
                              ),
                              BenefitItem(
                                icon: Icons.library_books_rounded,
                                text: localizations.fullLibraryAccess,
                              ),
                              BenefitItem(
                                icon: Icons.support_agent_rounded,
                                text: localizations.premiumSupport,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Action Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E2DE2),
                                    Color(0xFF4A00E0),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4A00E0,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
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
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  localizations.buyPro,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed:
                                  () => Navigator.of(dialogContext).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                foregroundColor:
                                    isDark ? Colors.white60 : Colors.black54,
                              ),
                              child: Text(
                                localizations.later,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
