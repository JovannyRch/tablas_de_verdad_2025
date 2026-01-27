import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/routes.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';

import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/video_screen.dart';
import 'package:tablas_de_verdad_2025/utils/go_to_solution.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:tablas_de_verdad_2025/widget/banner_ad_widget.dart';

class ExpressionCard extends StatelessWidget {
  final Expression expression;
  late AppLocalizations t;
  late Settings _settings;
  final bool showAds;

  ExpressionCard({super.key, required this.expression, required this.showAds});

  void _handleTap(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      Routes.calculator,
      arguments: expression.expression,
    );
  }

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    _settings = context.watch<Settings>();
    var card = GestureDetector(
      onTap: () {
        _handleTap(context);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expression.expression ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${t.type}: ${getTranslatedType(expression.type)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    if (expression.youtubeUrl != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          /*  Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => VideoScreen(
                                    videoUrl: expression.youtubeUrl!,
                                  ),
                            ),
                          ); */
                          visit(expression.youtubeUrl!);
                        },
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
              const SizedBox(width: 16),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Icon(Icons.chevron_right)],
              ),
            ],
          ),
        ),
      ),
    );

    if (showAds && !_settings.isProVersion) {
      return Column(
        children: [card, const SizedBox(height: 8), BannerAdWidget()],
      );
    } else {
      return card;
    }
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
