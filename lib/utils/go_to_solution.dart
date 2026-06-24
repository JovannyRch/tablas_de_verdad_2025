import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/api/supabase_expressions.dart';
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/screens/truth_table_result_screen.dart';
import 'package:tablas_de_verdad_2025/utils/show_snackbar.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';

Future<void> goToResult(
  BuildContext context,
  String expression,
  AppLocalizations t,
) async {
  final truthTable = TruthTable(expression, t.localeName);

  // makeAll() runs the full pipeline (parse → validate → build) and enforces
  // the variable cap, so this path can't freeze on pathological input.
  if (!truthTable.makeAll()) {
    showSnackBarMessage(context, truthTable.errorMessage);
    return;
  }

  // Registra la expresión válida en la librería de Supabase (contador +
  // tipo). Fire-and-forget: si Supabase no responde, no afecta el flujo.
  SupabaseExpressions.register(truthTable.initialInfix, truthTable.tipo);

  List<TruthTableStep> steps =
      truthTable.steps.map((step) {
        final columnKeys = getColumnsKeys(step);
        final rows = getRows(truthTable, columnKeys, step);
        return TruthTableStep(
          title:
              step.isSingleVariable
                  ? "${step.operator.value}${StepProcess.displayOperand(step.variable1)}"
                  : " ${StepProcess.displayOperand(step.variable1)} ${step.operator.value} ${StepProcess.displayOperand(step.variable2)}",
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
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}
