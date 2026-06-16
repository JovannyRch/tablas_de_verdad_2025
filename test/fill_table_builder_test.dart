import 'package:flutter_test/flutter_test.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/utils/fill_table_builder.dart';

void main() {
  FillTablePuzzle build(String expr) {
    // The engine expects space-free input (the calculator strips spaces before
    // evaluating); do the same here.
    final tt = TruthTable(expr.replaceAll(' ', ''), 'en');
    tt.makeAll();
    final puzzle = FillTableBuilder.fromTruthTable(tt);
    expect(puzzle, isNotNull, reason: 'puzzle should build for "$expr"');
    return puzzle!;
  }

  test('binary AND: 4 rows, single true row with both inputs 1', () {
    final p = build('A ∧ B');
    expect(p.variables, ['A', 'B']);
    expect(p.rowCount, 4);

    final trueRows = p.rows.where((r) => r.answer == '1').toList();
    expect(trueRows.length, 1);
    expect(trueRows.single.inputs, ['1', '1']);
    expect(p.rows.where((r) => r.answer == '0').length, 3);
  });

  test('every row carries one value per variable', () {
    final p = build('(A ∧ B) ∨ C');
    expect(p.variables, ['A', 'B', 'C']);
    expect(p.rowCount, 8);
    for (final row in p.rows) {
      expect(row.inputs.length, p.variables.length);
      expect(row.answer, anyOf('0', '1'));
    }
  });

  test('unary negation builds a 2-row puzzle', () {
    final p = build('¬A');
    expect(p.variables, ['A']);
    expect(p.rowCount, 2);
    // A=1 -> 0, A=0 -> 1
    final byInput = {for (final r in p.rows) r.inputs.single: r.answer};
    expect(byInput['1'], '0');
    expect(byInput['0'], '1');
  });

  test('tautology: all final values are 1', () {
    final p = build('A ∨ ¬A');
    expect(p.rows.every((r) => r.answer == '1'), true);
  });

  test('contradiction: all final values are 0', () {
    final p = build('A ∧ ¬A');
    expect(p.rows.every((r) => r.answer == '0'), true);
  });
}
