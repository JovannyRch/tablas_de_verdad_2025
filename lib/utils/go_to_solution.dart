import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/truth_table_result_screen.dart';
import 'package:tablas_de_verdad_2025/utils/show_snackbar.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void goToResult(
  BuildContext context,
  String expression,
  AppLocalizations t,
  TruthFormat format,
) {
  TruthTable truthTable = TruthTable(expression, t.localeName, format);

  bool isValid = truthTable.convertInfixToPostix();

  if (!isValid) {
    showSnackBarMessage(context, truthTable.errorMessage);
    return;
  }

  isValid = truthTable.checkIfIsCorrectlyFormed();

  if (!isValid) {
    showSnackBarMessage(context, truthTable.errorMessage);
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
          headers: [...columnKeys, t.result],
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
