import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/utils/rating_helper.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'dart:io';
import 'package:tablas_de_verdad_2025/const/const.dart';

/// Muestra un diálogo pidiendo al usuario que califique la app
Future<void> showRatingDialog(BuildContext context) async {
  if (!context.mounted) return;

  final t = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  await showDialog(
    context: context,
    barrierDismissible: false,
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
                  // Accent Gradient top right
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
                            Colors.amber.withOpacity(0.15),
                            Colors.orange.withOpacity(0.05),
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
                        // Star Icon with Gradient
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8C00).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          t.ratingDialogTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Message
                        Text(
                          t.ratingDialogMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Decorative Stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD700),
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Rate Now Button
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFF8C00),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF8C00,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await RatingHelper.markAsRated();
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }

                                  try {
                                    final String storeUrl =
                                        Platform.isAndroid
                                            ? 'https://play.google.com/store/apps/details?id=$APP_ID'
                                            : 'https://apps.apple.com/app/id1234567890';
                                    await visit(storeUrl);
                                  } catch (e) {
                                    if (kDebugMode) {
                                      print('❌ Error opening store: $e');
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Error opening store'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
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
                                  t.ratingRateNow,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Secondary actions row
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async {
                                      await RatingHelper.markAsPostponed();
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                    ),
                                    child: Text(t.ratingLater),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async {
                                      await RatingHelper.markAsNeverAskAgain();
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                    ),
                                    child: Text(t.ratingNoThanks),
                                  ),
                                ),
                              ],
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
