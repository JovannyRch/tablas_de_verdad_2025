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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final typeData = _getTypeData(expression.type, isDark);

    var card = GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type indicator bar
                Container(width: 6, color: typeData.color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeData.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                typeData.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: typeData.color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          expression.expression ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Courier',
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (expression.youtubeUrl != null) ...[
                          const SizedBox(height: 16),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => visit(expression.youtubeUrl!),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? Colors.white10
                                            : Colors.black.withOpacity(0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_circle_outline,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      t.videoFABLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (showAds && !_settings.isProVersion) {
      return Column(
        children: [card, const SizedBox(height: 16), BannerAdWidget()],
      );
    } else {
      return card;
    }
  }

  _TypeData _getTypeData(String? type, bool isDark) {
    switch (type) {
      case "TAUTOLOGY":
        return _TypeData(t.tautology, Colors.green);
      case "CONTRADICTION":
        return _TypeData(t.contradiction, Colors.red);
      case "CONTINGENCY":
      default:
        return _TypeData(t.contingency, Colors.amber);
    }
  }
}

class _TypeData {
  final String label;
  final Color color;
  _TypeData(this.label, this.color);
}
