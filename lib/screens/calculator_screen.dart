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
import 'package:tablas_de_verdad_2025/utils/expression_validator.dart';
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
  ValidationResult _validation = const ValidationResult(ValidationStatus.empty);
  bool _localizationReady = false;

  @override
  void initState() {
    setRandomExpression();
    ads = Ads(AdmobService.getVideoId());
    rewardedAdHelper = RewardedAdHelper();

    if (widget.initialExpression != null &&
        widget.initialExpression!.isNotEmpty) {
      setExpression(widget.initialExpression!);
    }

    _controller.addListener(_onExpressionChanged);

    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_onExpressionChanged);
    rewardedAdHelper.dispose();
    ads.interstitialAd!.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onExpressionChanged() {
    if (!_localizationReady) return;
    final t = _localization;
    final result = ExpressionValidator.validate(
      _controller.text,
      validationMsgUnmatched: t.validationUnmatched,
      validationMsgMissingOperand: t.validationMissingOperand,
      validationMsgMissingOperator: t.validationMissingOperator,
      validationMsgTrailingOp: t.validationTrailingOp,
      validationMsgValid: t.validationValid,
    );
    if (result.status != _validation.status ||
        result.hint != _validation.hint) {
      setState(() => _validation = result);
    }
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

    // First build: enable validation and run initial check
    if (!_localizationReady) {
      _localizationReady = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onExpressionChanged();
      });
    }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
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
                      fontFamily: 'Courier',
                    ),
                  ),
                  // Real-time validation indicator
                  if (!_validation.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _validation.isValid
                                ? Icons.check_circle_rounded
                                : _validation.isIncomplete
                                ? Icons.info_outline_rounded
                                : Icons.error_outline_rounded,
                            size: 14,
                            color:
                                _validation.isValid
                                    ? const Color(0xFF4CAF50)
                                    : _validation.isIncomplete
                                    ? (isDark ? Colors.white38 : Colors.black38)
                                    : const Color(0xFFE53935),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _validation.hint ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    _validation.isValid
                                        ? const Color(0xFF4CAF50)
                                        : _validation.isIncomplete
                                        ? (isDark
                                            ? Colors.white38
                                            : Colors.black38)
                                        : const Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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
    final isDark = _settings.isDarkMode(context);
    final remaining = _settings.remainingFreePremiumUses;

    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => Dialog(
                backgroundColor:
                    isDark ? const Color(0xFF1E1E2E) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                insetPadding: const EdgeInsets.symmetric(horizontal: 28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4A00E0).withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF4A00E0),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        _localization.premiumOperator,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        _localization.premiumOperatorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Remaining uses indicator
                      if (remaining > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _localization.expressionsRemaining(remaining),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Watch video button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx, false);
                            final success =
                                await rewardedAdHelper.showRewardedAd();
                            if (success) {
                              _settings.markFullscreenAdShown();
                              if (mounted) _evaluateAfterReward();
                            } else {
                              if (mounted) {
                                showSnackBarMessage(
                                  context,
                                  _localization.adNotAvailable,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          label: Text(_localization.watchVideoFree),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white70 : Colors.black87,
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Upgrade Pro button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx, false);
                              showProVersionDialog(
                                context,
                                _settings,
                                _localization,
                              );
                            },
                            icon: const Icon(Icons.diamond_rounded, size: 18),
                            label: Text(
                              _settings.proPrice != null
                                  ? '${_localization.upgradePro} · ${_settings.proPrice}'
                                  : _localization.upgradePro,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Cancel
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white38 : Colors.black26,
                        ),
                        child: Text(_localization.cancel),
                      ),
                    ],
                  ),
                ),
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
