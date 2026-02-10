import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/db/database.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/ad_mob_service.dart';
import 'package:tablas_de_verdad_2025/utils/ads.dart';
import 'package:tablas_de_verdad_2025/utils/go_to_solution.dart';
import 'package:tablas_de_verdad_2025/utils/show_pro_version_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/show_snackbar.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:tablas_de_verdad_2025/utils/rating_helper.dart';
import 'package:tablas_de_verdad_2025/utils/show_rating_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/analytics.dart';
import 'package:tablas_de_verdad_2025/widget/banner_ad_widget.dart';

import 'package:tablas_de_verdad_2025/widget/drawer.dart';
import 'package:tablas_de_verdad_2025/widget/keypad.dart';
import 'package:tablas_de_verdad_2025/widget/pro_icon.dart';
import 'package:tablas_de_verdad_2025/utils/rewarded_ad_helper.dart';

import 'package:tablas_de_verdad_2025/utils/ghost_text_controller.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class CalculatorScreen extends StatefulWidget {
  final String? initialExpression;
  const CalculatorScreen({super.key, this.initialExpression});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _controller = GhostTextEditingController(text: "");
  final _focusNode = FocusNode();
  Case _case = Case.lower;
  late AppLocalizations _localization;
  late Settings _settings;
  late Ads ads;
  late RewardedAdHelper rewardedAdHelper;

  @override
  void initState() {
    setRandomExpression();
    ads = Ads(AdmobService.getVideoId());
    rewardedAdHelper = RewardedAdHelper(); // Inicializar rewarded ads

    if (widget.initialExpression != null &&
        widget.initialExpression!.isNotEmpty) {
      setExpression(widget.initialExpression!);
    }

    super.initState();
  }

  @override
  void dispose() {
    rewardedAdHelper.dispose(); // Liberar recursos del rewarded ad
    ads.interstitialAd!.dispose();
    _controller.dispose();
    super.dispose();
  }

  void setRandomExpression() {
    final randomExpression = getRandomExpression();
    _controller.text = randomExpression;
    _controller.selection = TextSelection.collapsed(
      offset: randomExpression.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    _localization = AppLocalizations.of(context)!;
    _settings = context.watch<Settings>();
    final isDark = _settings.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.appName),
        actions: [
          IconButton(
            icon: Icon(
              _settings.keypadMode == KeypadMode.simple
                  ? Icons.keyboard
                  : Icons.grid_view,
            ),
            tooltip:
                _settings.keypadMode == KeypadMode.simple
                    ? _localization.advanced_mode
                    : _localization.simple_mode,
            onPressed: () {
              _settings.update(
                keypadMode:
                    _settings.keypadMode == KeypadMode.simple
                        ? KeypadMode.advanced
                        : KeypadMode.simple,
              );
            },
          ),
          if (!_settings.isProVersion)
            ProIconButton(
              onPressed: () {
                showProVersionDialog(context, _settings, _localization);
              },
            ),
        ],
      ),
      drawer: AppDrawer(
        isPro: _settings.isProVersion,
        onUpgrade: () async {
          await showProVersionDialog(context, _settings, _localization);
        },
        onLogout: () {},
        onExpressionSelected: (String expr) {
          _controller.text = expr;
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.none,
                showCursor: true,
                readOnly: true,
                autocorrect: false,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  border: InputBorder.none,
                  hintText: _localization.emptyExpression,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                ),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Courier', // Better for logical expressions
                ),
              ),
            ),
            // Keypad
            Expanded(
              child: TruthKeypad(
                onTap: _insert,
                onBackspace: _backspace,
                onClear: () => _controller.clear(),
                onToggleAa: _toggleCase,
                onEvaluate: _evaluate,
                calculatorCase: _case,
              ),
            ),
            _settings.isProVersion ? const SizedBox() : BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  void setExpression(String expression) {
    _controller.text = expression;
    _controller.selection = TextSelection.collapsed(offset: expression.length);
  }

  void _insert(String txt) {
    if (!_focusNode.hasFocus) _focusNode.requestFocus();

    final oldText = _controller.text;
    var sel = _controller.selection;

    if (!sel.isValid || sel.start < 0 || sel.end < 0) {
      sel = TextSelection.collapsed(offset: oldText.length);
    }

    final piece = _case == Case.lower ? txt.toLowerCase() : txt.toUpperCase();

    final newText = oldText.replaceRange(sel.start, sel.end, piece);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + piece.length),
    );
  }

  void _backspace() {
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
    if (_controller.text.isEmpty) return;

    final sel = _controller.selection;
    if (sel.end < 0 || sel.start < 0) {
      return;
    }
    if (sel.start == sel.end && sel.start > 0) {
      // sin selección
      final newStart = sel.start - 1;
      _controller.text = _controller.text.replaceRange(newStart, sel.start, '');
      _controller.selection = TextSelection.collapsed(offset: newStart);
    } else {
      // con selección
      _controller.text = _controller.text.replaceRange(sel.start, sel.end, '');
      _controller.selection = TextSelection.collapsed(offset: sel.start);
    }
  }

  Case switchCase() {
    _case = _case == Case.lower ? Case.upper : Case.lower;

    return _case;
  }

  void _toggleCase() {
    setState(() {
      Case newCase = switchCase();
      if (newCase == Case.lower) {
        _controller.text = _controller.text.toLowerCase();
      } else {
        _controller.text = _controller.text.toUpperCase();
      }
    });
  }

  void _evaluate() async {
    final expression = _controller.text;

    if (expression.isEmpty) {
      showSnackBarMessage(context, _localization.emptyExpression);
      return;
    }

    // Verificar operadores premium: 3 usos gratis/día, luego rewarded o Pro
    if (!_settings.isProVersion && _containsPremiumOperators(expression)) {
      if (_settings.hasFreePremmiumUsesRemaining()) {
        // Tiene usos gratuitos: consumir uno y continuar
        await _settings.consumeFreePremiumUse();
      } else {
        // Sin usos gratuitos: mostrar diálogo de rewarded/Pro
        final shouldContinue = await _showPremiumOperatorDialog();
        if (!shouldContinue) return;
      }
    }

    List<String> history = await getHistory();
    if (!history.contains(expression)) {
      await saveExpression(expression);
    }

    await _settings.incrementOperationsCount();

    // Analytics: track calculation
    Analytics.instance.logExpressionCalculated(expression);

    // Incrementar contador para el sistema de rating
    await RatingHelper.incrementCalculationCount();

    // Navegar a resultados y esperar a que el usuario regrese
    await goToResult(context, expression, _localization, _settings.truthFormat);

    // Mostrar ad intersticial al regresar (pausa natural, menos invasivo)
    if (_settings.shouldShowInterstitialAd()) {
      ads.showInterstitialAd();
      _settings.markFullscreenAdShown();
    }

    // Verificar si debemos mostrar el diálogo de calificación
    if (context.mounted) {
      final shouldShow = await RatingHelper.shouldShowRatingDialog();
      if (shouldShow && context.mounted) {
        showRatingDialog(context);
      }
    }
  }

  bool _containsPremiumOperators(String expression) {
    // Importar kPremiumOperators desde calculator.dart
    const premiumOps = ['⇏', '⊻', '￩', '⇎', '⊕', '⊼', '⇍', '↓', '┹', '┲'];
    return premiumOps.any((op) => expression.contains(op));
  }

  Future<bool> _showPremiumOperatorDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('🎯 ${_localization.premiumOperator}'),
                content: Text(_localization.premiumOperatorMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(_localization.cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context, false);

                      final success = await rewardedAdHelper.showRewardedAd();
                      if (success) {
                        _settings.markFullscreenAdShown();
                        if (mounted) {
                          // Re-ejecutar la evaluación tras ver el video
                          _evaluateAfterReward();
                        }
                      } else {
                        if (mounted) {
                          showSnackBarMessage(
                            context,
                            _localization.adNotAvailable,
                          );
                        }
                      }
                    },
                    child: Text(_localization.watchVideoFree),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                      showProVersionDialog(context, _settings, _localization);
                    },
                    child: Text(_localization.upgradePro),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Evalúa la expresión directamente (tras ver rewarded ad, sin pedir de nuevo)
  void _evaluateAfterReward() async {
    final expression = _controller.text;
    if (expression.isEmpty) return;

    List<String> history = await getHistory();
    if (!history.contains(expression)) {
      await saveExpression(expression);
    }

    await _settings.incrementOperationsCount();
    await RatingHelper.incrementCalculationCount();

    await goToResult(context, expression, _localization, _settings.truthFormat);

    // Intersticial al regresar, respetando cooldown
    if (_settings.shouldShowInterstitialAd()) {
      ads.showInterstitialAd();
      _settings.markFullscreenAdShown();
    }

    if (context.mounted) {
      final shouldShow = await RatingHelper.shouldShowRatingDialog();
      if (shouldShow && context.mounted) {
        showRatingDialog(context);
      }
    }
  }
}
