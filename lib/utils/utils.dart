import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';

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
