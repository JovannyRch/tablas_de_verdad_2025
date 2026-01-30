import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/utils/rating_helper.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:in_app_review/in_app_review.dart';
import 'dart:io';

/// Muestra un diálogo pidiendo al usuario que califique la app
Future<void> showRatingDialog(BuildContext context) async {
  if (!context.mounted) return;

  final t = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.ratingDialogTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.ratingDialogMessage, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              // Mostrar estrellas decorativas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(Icons.star, color: Colors.amber, size: 32),
                ),
              ),
            ],
          ),
          actions: [
            // Botón "No, gracias"
            TextButton(
              onPressed: () async {
                await RatingHelper.markAsNeverAskAgain();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                t.ratingNoThanks,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            // Botón "Más tarde"
            TextButton(
              onPressed: () async {
                await RatingHelper.markAsPostponed();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                t.ratingLater,
                style: const TextStyle(color: Colors.blue),
              ),
            ),

            // Botón "Calificar ahora"
            ElevatedButton.icon(
              onPressed: () async {
                await RatingHelper.markAsRated();

                // Cerrar el diálogo primero
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                // Intentar mostrar el diálogo nativo de calificación
                final InAppReview inAppReview = InAppReview.instance;

                // Verificar si está disponible el review in-app
                if (await inAppReview.isAvailable()) {
                  // Mostrar el diálogo nativo (dentro de la app)
                  await inAppReview.requestReview();
                } else {
                  // Si no está disponible, abrir la tienda
                  final String storeUrl =
                      Platform.isAndroid
                          ? 'https://play.google.com/store/apps/details?id=com.jovannyrch.tablasdeverdad'
                          : 'https://apps.apple.com/app/id1234567890'; // Reemplazar con tu ID de iOS

                  visit(storeUrl);
                }
              },
              icon: const Icon(Icons.star, color: Colors.white),
              label: Text(
                t.ratingRateNow,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
  );
}
