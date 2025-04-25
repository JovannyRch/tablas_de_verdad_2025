import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/db/database.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/truth_table_result_screen.dart';
import 'package:tablas_de_verdad_2025/utils/show_pro_version_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/show_snackbar.dart';

import 'package:tablas_de_verdad_2025/widget/drawer.dart';
import 'package:tablas_de_verdad_2025/widget/keypad.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/widget/pro_icon.dart';
import 'package:provider/provider.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _controller = TextEditingController(text: "~(p∧q)⇒r");
  final _focusNode = FocusNode();
  Case _case = Case.lower;
  late AppLocalizations _localization;
  late Settings _settings;

  @override
  Widget build(BuildContext context) {
    _localization = AppLocalizations.of(context)!;
    _settings = context.watch<Settings>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.appName),
        actions: [
          if (!IS_PRO_VERSION)
            ProIconButton(
              onPressed: () {
                showProVersionDialog(context);
              },
            ),
        ],
      ),
      drawer: AppDrawer(
        isPro: IS_PRO_VERSION,
        onUpgrade: () async {
          await showProVersionDialog(context);
        },
        onLogout: () {},
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
          ],
        ),
      ),
    );
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
    final sel = _controller.selection;
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
      return;
    }
    List<String> history = await getHistory();

    if (!history.contains(expression)) {
      await saveExpression(expression);
    }

    TruthTable truthTable = TruthTable(
      expression,
      _localization.localeName,
      _settings.truthFormat,
    );

    bool isValid = truthTable.convertInfixToPostix();

    if (!isValid) {
      showSnackBarMessage(context, _localization.appName);
      return;
    }

    isValid = truthTable.checkIfIsCorrectlyFormed();

    if (!isValid) {
      showSnackBarMessage(context, _localization.appName);
      return;
    }

    truthTable.calculate();

    List<TruthTableStep> steps =
        truthTable.steps.map((step) {
          final columnKeys = getColumnsKeys(step);
          final rows = getRows(truthTable, columnKeys, step);
          return TruthTableStep(
            title:
                step.isSingleVariable
                    ? "${step.variable1} ${step.variable1}"
                    : " ${step.variable1} ${step.operator.value} ${step.variable2}",
            headers: [...columnKeys, _localization.result],
            rows: rows,
            stepProcess: step,
          );
        }).toList();

    final screen = TruthTableResultScreen(
      steps: steps,
      expression: truthTable.initialInfix,
      truthTable: truthTable,
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  List<String> getColumnsKeys(StepProcess step) {
    if (step.isSingleVariable) {
      return [step.variable1];
    }
    return [step.variable1, step.variable2];
  }

  List<List<String>> getRows(
    TruthTable table,
    List<String> columsKeys,
    StepProcess step,
  ) {
    List<List<String>> rows = [];
    for (int i = 0; i < table.totalRows; i++) {
      String combination = "";
      for (int j = 0; j < columsKeys.length; j++) {
        combination += table.columns[columsKeys[j]]![i];
      }
      String result = table.columns[step.toString()]![i];
      rows.add([...combination.split(""), result]);
    }
    return rows;
  }
}
