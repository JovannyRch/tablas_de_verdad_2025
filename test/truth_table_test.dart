import 'package:flutter_test/flutter_test.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/equivalence_checker.dart';
import 'package:tablas_de_verdad_2025/utils/expression_validator.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

TruthTable build(String expr) {
  final tt = TruthTable(expr, 'en', TruthFormat.vf);
  tt.makeAll();
  return tt;
}

ValidationResult validateExpr(String expr) => ExpressionValidator.validate(
      expr,
      validationMsgUnmatched: 'unmatched',
      validationMsgMissingOperand: 'operand',
      validationMsgMissingOperator: 'operator',
      validationMsgTrailingOp: 'trailing',
      validationMsgValid: 'ok',
    );

// ──────────────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Classification ──────────────────────────────────────────────────────

  group('TruthTable classification', () {
    test('p∨¬p is a tautology', () {
      final tt = build('p∨¬p');
      expect(tt.tipo, TruthTableType.tautology);
      expect(tt.counter1s, tt.totalRows);
      expect(tt.counters0s, 0);
    });

    test('p∧¬p is a contradiction', () {
      final tt = build('p∧¬p');
      expect(tt.tipo, TruthTableType.contradiction);
      expect(tt.counters0s, tt.totalRows);
      expect(tt.counter1s, 0);
    });

    test('p∧q is a contingency', () {
      final tt = build('p∧q');
      expect(tt.tipo, TruthTableType.contingency);
      expect(tt.counter1s, greaterThan(0));
      expect(tt.counters0s, greaterThan(0));
    });

    test('p (single atom) is a contingency', () {
      final tt = build('p');
      expect(tt.tipo, TruthTableType.contingency);
      expect(tt.counter1s, 1);
      expect(tt.counters0s, 1);
    });
  });

  // ── 2. Variables and row count ─────────────────────────────────────────────

  group('TruthTable variables and rows', () {
    test('1 variable → 2 rows', () {
      final tt = build('p');
      expect(tt.variables, ['p']);
      expect(tt.totalRows, 2);
    });

    test('2 variables → 4 rows', () {
      final tt = build('p∧q');
      expect(tt.variables, ['p', 'q']);
      expect(tt.totalRows, 4);
    });

    test('3 variables → 8 rows', () {
      final tt = build('p∧q∧r');
      expect(tt.variables, ['p', 'q', 'r']);
      expect(tt.totalRows, 8);
    });

    test('4 variables → 16 rows', () {
      final tt = build('A∧B∧C∧D');
      expect(tt.variables, ['A', 'B', 'C', 'D']);
      expect(tt.totalRows, 16);
    });

    test('variables are sorted alphabetically', () {
      final tt = build('b∧a');
      expect(tt.variables, ['a', 'b']);
    });

    test('uppercase and lowercase are distinct variables', () {
      final tt = build('A∧a');
      expect(tt.variables, ['A', 'a']);
      expect(tt.totalRows, 4);
    });

    test('duplicate variables count once', () {
      final tt = build('p∧p');
      expect(tt.variables, ['p']);
      expect(tt.totalRows, 2);
    });
  });

  // ── 3. NOT operator aliases ────────────────────────────────────────────────

  group('NOT operator aliases (¬ ~ !)', () {
    for (final op in ['¬', '~', '!']) {
      test('${op}p has 1 true row', () {
        final tt = build('${op}p');
        expect(tt.totalRows, 2, reason: '${op}p should have 2 rows');
        expect(tt.counter1s, 1, reason: '${op}p true when p=false');
      });
    }
  });

  // ── 4. All binary operators ────────────────────────────────────────────────
  //
  // For 2 variables, row order (i from 3→0): (p=1,q=1), (p=1,q=0), (p=0,q=1), (p=0,q=0).
  // counter1s = number of rows with result=1.

  group('binary operators – truth tables', () {
    final cases = [
      // (expression, counter1s)
      ('p∧q',  1), // AND:                1,0,0,0
      ('p&q',  1), // AND alias:          same
      ('p∨q',  3), // OR:                 1,1,1,0
      ('p|q',  3), // OR alias:           same
      ('p⊕q',  2), // XOR:                0,1,1,0
      ('p⊻q',  2), // XOR alias:          same
      ('p↓q',  1), // NOR = ¬(p∨q):       0,0,0,1
      ('p⊼q',  3), // NAND = ¬(p∧q):      0,1,1,1
      ('p⇒q',  3), // conditional:        1,0,1,1  (false iff p=1,q=0)
      ('p⇔q',  2), // biconditional:      1,0,0,1  (true iff p=q)
      ('p￩q',  3), // anticonditional:    1,1,0,1  (false iff p=0,q=1)
      ('p⇏q',  1), // ¬(p⇒q):             0,1,0,0
      ('p⇍q',  1), // ¬(p￩q):             0,0,1,0
      ('p⇎q',  2), // ¬(p⇔q) = XOR:       0,1,1,0
    ];

    for (final (expr, ones) in cases) {
      test('$expr → $ones/4 true rows', () {
        final tt = build(expr);
        expect(tt.totalRows, 4, reason: '$expr should have 4 rows');
        expect(tt.counter1s, ones, reason: '$expr');
      });
    }

    test('p┲q (tautology operator) gives all 1s', () {
      final tt = build('p┲q');
      expect(tt.tipo, TruthTableType.tautology);
      expect(tt.counter1s, 4);
    });

    test('p┹q (contradiction operator) gives all 0s', () {
      final tt = build('p┹q');
      expect(tt.tipo, TruthTableType.contradiction);
      expect(tt.counters0s, 4);
    });
  });

  // ── 5. Constants 0 / 1 ────────────────────────────────────────────────────

  group('constants 0 and 1 in expression', () {
    test('p∧0 is a contradiction', () {
      final tt = build('p∧0');
      expect(tt.tipo, TruthTableType.contradiction);
    });

    test('p∨1 is a tautology', () {
      final tt = build('p∨1');
      expect(tt.tipo, TruthTableType.tautology);
    });

    test('0∨1 is always true', () {
      final tt = build('0∨1');
      expect(tt.tipo, TruthTableType.tautology);
    });
  });

  // ── 6. Syntax errors ──────────────────────────────────────────────────────

  group('TruthTable syntax errors', () {
    test('unclosed parenthesis → errorMessage nonempty', () {
      final tt = TruthTable('(p∧q', 'en', TruthFormat.vf);
      tt.makeAll();
      expect(tt.errorMessage, isNotEmpty);
    });

    test('extra close parenthesis → errorMessage nonempty', () {
      final tt = TruthTable('p∧q)', 'en', TruthFormat.vf);
      tt.makeAll();
      expect(tt.errorMessage, isNotEmpty);
    });

    test('trailing operator → errorMessage nonempty', () {
      final tt = TruthTable('p∧', 'en', TruthFormat.vf);
      tt.makeAll();
      expect(tt.errorMessage, isNotEmpty);
    });

    test('two variables without operator → errorMessage nonempty', () {
      final tt = TruthTable('pq', 'en', TruthFormat.vf);
      tt.makeAll();
      expect(tt.errorMessage, isNotEmpty);
    });

    test('valid expression → errorMessage empty', () {
      final tt = build('p∧q');
      expect(tt.errorMessage, isEmpty);
    });

    test('error expressions do not call calculate() → finalTable is empty', () {
      final tt = TruthTable('p∧', 'en', TruthFormat.vf);
      tt.makeAll();
      expect(tt.finalTable, isEmpty);
    });
  });

  // ── 7. Column consistency ─────────────────────────────────────────────────

  group('TruthTable column consistency', () {
    test('every step column is fully populated', () {
      final tt = build('(p⇒q)∧(q⇒r)⇒(p⇒r)');
      expect(tt.steps, isNotEmpty);
      for (final step in tt.steps) {
        final col = tt.columns[step.toString()];
        expect(col, isNotNull, reason: 'column missing for ${step.toString()}');
        expect(col!.length, tt.totalRows,
            reason: '${step.toString()} column has wrong length');
        expect(col.every((v) => v == '0' || v == '1'), isTrue,
            reason: '${step.toString()} contains non-binary value');
      }
    });

    test('hypothetical syllogism (p⇒q)∧(q⇒r)⇒(p⇒r) is a tautology', () {
      final tt = build('(p⇒q)∧(q⇒r)⇒(p⇒r)');
      expect(tt.tipo, TruthTableType.tautology);
    });

    test('finalTable row count = totalRows + 1 (header)', () {
      final tt = build('p⇒q');
      expect(tt.finalTable.length, tt.totalRows + 1);
    });

    test('finalTable header width matches data row width', () {
      final tt = build('(p∧q)∨¬r');
      final headerLen = tt.finalTable.first.length;
      for (int i = 1; i < tt.finalTable.length; i++) {
        expect(tt.finalTable[i].length, headerLen,
            reason: 'row $i has wrong width');
      }
    });
  });

  // ── 8. Operator precedence ────────────────────────────────────────────────

  group('operator precedence', () {
    test('¬ binds tighter than ∧: ¬p∧q = (¬p)∧q', () {
      // If ¬ were lower priority, ¬(p∧q) would give: ¬(T∧T)=F for p=1,q=1
      // (¬p)∧q for (p=1,q=1): (¬1)∧1 = 0∧1 = 0
      // ¬(p∧q) for (p=1,q=1): ¬(1∧1) = ¬1 = 0 — same here
      // Use p=0,q=1 to distinguish:
      // (¬0)∧1 = 1∧1 = 1
      // ¬(0∧1) = ¬0 = 1 — still same!
      // Use p=1,q=0:
      // (¬1)∧0 = 0∧0 = 0
      // ¬(1∧0) = ¬0 = 1 ← different!
      final tt = build('¬p∧q');
      // counter1s should be 1 (only p=0,q=1 gives 1 for (¬p)∧q)
      expect(tt.counter1s, 1,
          reason: '¬p∧q should mean (¬p)∧q, not ¬(p∧q)');
    });

    test('∧ binds tighter than ∨: p∨q∧r = p∨(q∧r)', () {
      // p∨(q∧r): only row where result=0 is p=0,q=0,r=* or p=0,q=1,r=0
      // p=0,q=0,r=1: 0∨(0∧1)=0∨0=0
      // p=0,q=0,r=0: 0∨0=0
      // p=0,q=1,r=0: 0∨(1∧0)=0∨0=0
      // p=0,q=1,r=1: 0∨(1∧1)=0∨1=1
      // p=1,*,*: 1∨(...)=1 → 4 rows
      // Total 1s = 4 + 1 = 5
      final ttAnd = build('p∨q∧r');
      final ttGrouped = build('p∨(q∧r)');
      expect(ttAnd.counter1s, ttGrouped.counter1s);
    });
  });

  // ── 9. EquivalenceChecker ─────────────────────────────────────────────────

  group('EquivalenceChecker', () {
    test('p∧q ≡ q∧p (commutativity)', () {
      final r = EquivalenceChecker.check('p∧q', 'q∧p', 'en', TruthFormat.vf);
      expect(r.hasError, isFalse);
      expect(r.isEquivalent, isTrue);
      expect(r.differingRows, isEmpty);
      expect(r.matchPercentage, 1.0);
    });

    test('p⇒q ≡ ¬p∨q (conditional definition)', () {
      final r =
          EquivalenceChecker.check('p⇒q', '¬p∨q', 'en', TruthFormat.vf);
      expect(r.isEquivalent, isTrue);
    });

    test('¬(p∧q) ≡ ¬p∨¬q (De Morgan)', () {
      final r =
          EquivalenceChecker.check('¬(p∧q)', '¬p∨¬q', 'en', TruthFormat.vf);
      expect(r.isEquivalent, isTrue);
    });

    test('p∧q is NOT equivalent to p∨q', () {
      final r = EquivalenceChecker.check('p∧q', 'p∨q', 'en', TruthFormat.vf);
      expect(r.isEquivalent, isFalse);
      expect(r.differingRows.length, 2);
    });

    test('matchPercentage = 0.5 when 2 of 4 rows differ', () {
      final r = EquivalenceChecker.check('p∧q', 'p∨q', 'en', TruthFormat.vf);
      expect(r.matchPercentage, 0.5);
      expect(r.matchingRows, 2);
    });

    test('cross-variable: p ≡ p∧(q∨¬q) (padding)', () {
      final r =
          EquivalenceChecker.check('p', 'p∧(q∨¬q)', 'en', TruthFormat.vf);
      expect(r.isEquivalent, isTrue);
    });

    test('parse error is reported in result', () {
      final r =
          EquivalenceChecker.check('p∧', 'p∧q', 'en', TruthFormat.vf);
      expect(r.hasError, isTrue);
      expect(r.isEquivalent, isFalse);
    });
  });

  // ── 10. Argument validity (via combined expression) ───────────────────────

  group('argument validity logic', () {
    // The screen builds: ((P1)∧(P2)∧…)⇒(C) and checks for tautology.
    // We test the same pattern directly on TruthTable.

    test('modus ponens is a valid argument', () {
      // ((p)∧(p⇒q))⇒(q) — classic modus ponens
      final tt = build('((p)∧(p⇒q))⇒(q)');
      expect(tt.tipo, TruthTableType.tautology);
    });

    test('modus tollens is a valid argument', () {
      // ((p⇒q)∧(¬q))⇒(¬p)
      final tt = build('((p⇒q)∧(¬q))⇒(¬p)');
      expect(tt.tipo, TruthTableType.tautology);
    });

    test('invalid argument: p∨q premise does not force p conclusion', () {
      // ((p∨q))⇒(p): false when p=0,q=1
      final tt = build('((p∨q))⇒(p)');
      expect(tt.tipo, TruthTableType.contingency);
    });
  });

  // ── 11. ExpressionValidator ───────────────────────────────────────────────

  group('ExpressionValidator', () {
    test('empty string → empty', () {
      expect(validateExpr('').isEmpty, isTrue);
    });

    test('whitespace-only → empty', () {
      expect(validateExpr('   ').isEmpty, isTrue);
    });

    test('p∧q → valid', () {
      final r = validateExpr('p∧q');
      expect(r.isValid, isTrue);
      expect(r.hint, 'ok');
    });

    test('¬p∧q → valid', () {
      expect(validateExpr('¬p∧q').isValid, isTrue);
    });

    test('(p∧q)∨r → valid', () {
      expect(validateExpr('(p∧q)∨r').isValid, isTrue);
    });

    test('(p⇒q)∧(q⇒p) → valid', () {
      expect(validateExpr('(p⇒q)∧(q⇒p)').isValid, isTrue);
    });

    test('(p∧q → incomplete (unclosed bracket)', () {
      final r = validateExpr('(p∧q');
      expect(r.isIncomplete, isTrue);
    });

    test('p∧ → incomplete (trailing binary operator)', () {
      final r = validateExpr('p∧');
      expect(r.isIncomplete, isTrue);
    });

    test('p∧¬ → incomplete (trailing NOT awaits operand)', () {
      final r = validateExpr('p∧¬');
      expect(r.isIncomplete, isTrue);
    });

    test('p∧q) → error (unmatched close bracket)', () {
      expect(validateExpr('p∧q)').hasError, isTrue);
    });

    test('pq → error (missing operator between variables)', () {
      expect(validateExpr('pq').hasError, isTrue);
    });

    test('∧p → error (leading binary operator)', () {
      expect(validateExpr('∧p').hasError, isTrue);
    });

    test('p¬q → error (NOT after operand = missing binary operator)', () {
      expect(validateExpr('p¬q').hasError, isTrue);
    });
  });
}
