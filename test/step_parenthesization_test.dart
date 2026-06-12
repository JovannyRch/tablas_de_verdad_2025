import 'package:flutter_test/flutter_test.dart';
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';

TruthTable build(String expression) {
  final tt = TruthTable(expression, 'en', TruthFormat.vf);
  tt.makeAll();
  return tt;
}

void main() {
  group('StepProcess.wrapOperand', () {
    test('leaves atomic operands unchanged', () {
      expect(StepProcess.wrapOperand('p'), 'p');
      expect(StepProcess.wrapOperand('¬p'), '¬p');
      expect(StepProcess.wrapOperand('¬(p∧q)'), '¬(p∧q)');
      expect(StepProcess.wrapOperand('(p⇒q)'), '(p⇒q)');
    });

    test('wraps compound operands', () {
      expect(StepProcess.wrapOperand('p⇒q'), '(p⇒q)');
      expect(StepProcess.wrapOperand('p∧q'), '(p∧q)');
      expect(StepProcess.wrapOperand('(p⇒q)∧(q⇒p)'), '((p⇒q)∧(q⇒p))');
      expect(StepProcess.wrapOperand('¬p∨q'), '(¬p∨q)');
    });
  });

  group('final table headers keep parentheses', () {
    test('(p⇒q)∧(q⇒p) composes its operands with parentheses', () {
      final tt = build('(p⇒q)∧(q⇒p)');
      expect(
        tt.finalTable[0],
        ['p', 'q', 'p ⇒ q', 'q ⇒ p', '(p ⇒ q) ∧ (q ⇒ p)'],
      );
    });

    test('negation of a compound is shown as ¬(p ∧ q)', () {
      final tt = build('¬(p∧q)');
      expect(tt.finalTable[0].last, '¬(p ∧ q)');
    });

    test('negation of a variable stays unwrapped', () {
      final tt = build('¬p∧q');
      expect(tt.finalTable[0], ['p', 'q', '¬p', '¬p ∧ q']);
    });

    test('nested composition wraps every compound level', () {
      final tt = build('((p⇒q)∧(q⇒p))∨r');
      expect(tt.finalTable[0].last, '((p ⇒ q) ∧ (q ⇒ p)) ∨ r');
    });
  });

  group('evaluation is unaffected', () {
    test('(p⇒q)∧(q⇒p) is a contingency with 2 true rows', () {
      final tt = build('(p⇒q)∧(q⇒p)');
      expect(tt.tipo, TruthTableType.contingency);
      expect(tt.counter1s, 2);
      expect(tt.totalRows, 4);
    });

    test('¬(p∧q)∨p is a tautology', () {
      final tt = build('¬(p∧q)∨p');
      expect(tt.tipo, TruthTableType.tautology);
    });

    test('step columns stay consistent with their keys', () {
      final tt = build('(p⇒q)∧(q⇒p)');
      // Every step's column must exist and be fully populated.
      for (final step in tt.steps) {
        expect(tt.columns[step.toString()], isNotNull, reason: '$step');
        expect(tt.columns[step.toString()]!.length, tt.totalRows);
      }
    });
  });
}
