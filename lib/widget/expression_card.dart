import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpressionCard extends StatelessWidget {
  final Expression expression;
  final VoidCallback? onTapVideo;
  late AppLocalizations t;

  ExpressionCard({Key? key, required this.expression, this.onTapVideo})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expression.expression ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${t.type}: ${getTranslatedType(expression.type)}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (expression.youtubeUrl != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onTapVideo,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        t.videoFABLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String getTranslatedType(String? type) {
    switch (type) {
      case "CONTINGENCY":
        return t.contingency;
      case "TAUTOLOGY":
        return t.tautology;
      case "CONTRADICTION":
        return t.contradiction;
      default:
        return '';
    }
  }
}
