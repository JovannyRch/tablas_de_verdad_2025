import 'package:tablas_de_verdad_2025/class/truth_table.dart';

/// One row of a fill-the-table puzzle: the given variable values and the
/// correct truth value of the whole expression for that combination.
///
/// All values are the engine's raw form (`'0'` / `'1'`); the UI formats them
/// for display (V/F, T/F, 1/0) via `getCellValue`.
class FillTableRow {
  /// Variable values for this row, one per [FillTablePuzzle.variables].
  final List<String> inputs;

  /// Correct value of the final (whole-expression) column.
  final String answer;

  const FillTableRow({required this.inputs, required this.answer});
}

/// A "complete the table" exercise: the student fills the final column.
class FillTablePuzzle {
  /// The expression as typed by the user (used for the prompt card).
  final String expression;

  /// Variable names, in the engine's sorted order.
  final List<String> variables;

  /// Display header of the final column (the rendered whole expression).
  final String finalHeader;

  final List<FillTableRow> rows;

  const FillTablePuzzle({
    required this.expression,
    required this.variables,
    required this.finalHeader,
    required this.rows,
  });

  int get rowCount => rows.length;
}

class FillTableBuilder {
  FillTableBuilder._();

  /// Builds a final-column puzzle from a solved [TruthTable] (after
  /// `makeAll()`).
  ///
  /// Returns null for degenerate tables — no data rows, or an expression with
  /// no operator column to solve (e.g. a bare variable) — so callers can skip
  /// it rather than render an unanswerable puzzle.
  static FillTablePuzzle? fromTruthTable(TruthTable tt) {
    final ft = tt.finalTable;
    if (ft.length < 2) return null; // need header row + at least one data row

    final headers = ft[0];
    final varCount = tt.variables.length;
    if (varCount == 0 || headers.length <= varCount) return null;

    final finalIdx = headers.length - 1;
    final rows = <FillTableRow>[];
    for (int i = 1; i < ft.length; i++) {
      final row = ft[i];
      if (row.length <= finalIdx) return null; // malformed
      rows.add(
        FillTableRow(inputs: row.sublist(0, varCount), answer: row[finalIdx]),
      );
    }

    return FillTablePuzzle(
      expression: tt.infix,
      variables: List<String>.from(tt.variables),
      finalHeader: headers[finalIdx],
      rows: rows,
    );
  }
}
