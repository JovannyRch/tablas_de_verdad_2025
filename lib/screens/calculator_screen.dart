import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/db/database.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/ad_mob_service.dart';
import 'package:tablas_de_verdad_2025/utils/ads.dart';
import 'package:tablas_de_verdad_2025/utils/go_to_solution.dart';
import 'package:tablas_de_verdad_2025/utils/show_pro_version_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/show_snackbar.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:tablas_de_verdad_2025/widget/banner_ad_widget.dart';

import 'package:tablas_de_verdad_2025/widget/drawer.dart';
import 'package:tablas_de_verdad_2025/widget/keypad.dart';
import 'package:tablas_de_verdad_2025/widget/pro_icon.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class CalculatorScreen extends StatefulWidget {
  final String? initialExpression;
  const CalculatorScreen({super.key, this.initialExpression});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _controller = TextEditingController(text: "");
  final _focusNode = FocusNode();
  Case _case = Case.lower;
  late AppLocalizations _localization;
  late Settings _settings;
  late Ads ads;

  @override
  void initState() {
    setRandomExpression();
    ads = Ads(AdmobService.getVideoId());

    if (widget.initialExpression != null &&
        widget.initialExpression!.isNotEmpty) {
      setExpression(widget.initialExpression!);
    }

    super.initState();
  }

  @override
  void dispose() {
    ads.interstitialAd!.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.appName),
        actions: [
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.none,
                showCursor: true,
                readOnly: true,
                autocorrect: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor:
                      _settings.isDarkMode(context)
                          ? Colors.grey[800]
                          : Colors.white10,
                  filled: true,
                ),
                style: const TextStyle(fontSize: 20),
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
    List<String> history = await getHistory();

    if (!history.contains(expression)) {
      await saveExpression(expression);
    }

    _settings.incrementOperationsCount();

    //&& _settings.operationsCount % 2 == 0
    if (!_settings.isProVersion) {
      ads.showInterstitialAd();
    }

    goToResult(context, expression, _localization, _settings.truthFormat);
  }
}
