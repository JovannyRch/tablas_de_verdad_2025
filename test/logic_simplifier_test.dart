import 'package:flutter_test/flutter_test.dart';
import 'package:tablas_de_verdad_2025/class/logic_simplifier.dart';

/// Brute-force check that two expressions have identical truth tables.
bool equivalent(String a, String b) {
  final nodeA = LogicSimplifier.parse(a);
  final nodeB = LogicSimplifier.parse(b);
  final vars =
      {
        ...LogicSimplifier.variablesOf(nodeA),
        ...LogicSimplifier.variablesOf(nodeB),
      }.toList();

  for (int mask = 0; mask < (1 << vars.length); mask++) {
    final assignment = {
      for (int i = 0; i < vars.length; i++) vars[i]: (mask >> i) & 1 == 1,
    };
    if (LogicSimplifier.evaluate(nodeA, assignment) !=
        LogicSimplifier.evaluate(nodeB, assignment)) {
      return false;
    }
  }
  return true;
}

void main() {
  group('parser and printer', () {
    test('respects precedence: ¬ > ∧ > ∨', () {
      final r = LogicSimplifier.simplify('¬A∧B∨C');
      expect(r.original, '(¬A ∧ B) ∨ C');
    });

    test('parses derived operators and constants', () {
      expect(LogicSimplifier.simplify('A⊼1').original, 'A ⊼ 1');
      expect(LogicSimplifier.simplify('(A⇒B)⇔C').original, '(A ⇒ B) ⇔ C');
    });

    test('throws on malformed input', () {
      expect(() => LogicSimplifier.parse('(A∧B'), throwsFormatException);
      expect(() => LogicSimplifier.parse('A∧'), throwsFormatException);
    });
  });

  group('individual laws', () {
    test('double negation: ¬¬A = A', () {
      final r = LogicSimplifier.simplify('¬¬A');
      expect(r.result, 'A');
      expect(r.steps.single.law, SimplificationLaw.doubleNegation);
    });

    test('De Morgan: ¬(A∧B) = ¬A ∨ ¬B', () {
      final r = LogicSimplifier.simplify('¬(A∧B)');
      expect(r.result, '¬A ∨ ¬B');
      expect(r.steps.single.law, SimplificationLaw.deMorgan);
    });

    test('idempotence: A∨A = A', () {
      final r = LogicSimplifier.simplify('A∨A');
      expect(r.result, 'A');
      expect(r.steps.single.law, SimplificationLaw.idempotence);
    });

    test('identity: A∧1 = A', () {
      final r = LogicSimplifier.simplify('A∧1');
      expect(r.result, 'A');
      expect(r.steps.single.law, SimplificationLaw.identity);
    });

    test('domination: A∧0 = 0', () {
      final r = LogicSimplifier.simplify('A∧0');
      expect(r.result, '0');
      expect(r.steps.single.law, SimplificationLaw.domination);
    });

    test('complement: A∧¬A = 0', () {
      final r = LogicSimplifier.simplify('A∧¬A');
      expect(r.result, '0');
      expect(r.steps.single.law, SimplificationLaw.complement);
    });

    test('absorption: A∨(A∧B) = A', () {
      final r = LogicSimplifier.simplify('A∨(A∧B)');
      expect(r.result, 'A');
      expect(r.steps.single.law, SimplificationLaw.absorption);
    });

    test('negative absorption: A∨(¬A∧B) = A ∨ B', () {
      final r = LogicSimplifier.simplify('A∨(¬A∧B)');
      expect(r.result, 'A ∨ B');
      expect(r.steps.single.law, SimplificationLaw.absorption);
    });

    test('factorization: (A∧B)∨(A∧C) = A ∧ (B ∨ C)', () {
      final r = LogicSimplifier.simplify('(A∧B)∨(A∧C)');
      expect(r.result, 'A ∧ (B ∨ C)');
      expect(r.steps.single.law, SimplificationLaw.factorization);
    });

    test('conditional: A⇒B = ¬A ∨ B', () {
      final r = LogicSimplifier.simplify('A⇒B');
      expect(r.result, '¬A ∨ B');
      expect(r.steps.single.law, SimplificationLaw.conditional);
    });

    test('negation of constant: ¬1 = 0', () {
      final r = LogicSimplifier.simplify('¬1');
      expect(r.result, '0');
      expect(r.steps.single.law, SimplificationLaw.negationOfConstant);
    });
  });

  group('multi-step chains', () {
    test('¬(A∧B)∨A reduces to 1 via De Morgan + complement + domination', () {
      final r = LogicSimplifier.simplify('¬(A∧B)∨A');
      expect(r.result, '1');
      expect(
        r.steps.map((s) => s.law),
        containsAllInOrder([
          SimplificationLaw.deMorgan,
          SimplificationLaw.complement,
          SimplificationLaw.domination,
        ]),
      );
    });

    test('(A⇒B)∨(B⇒A) is reduced to 1', () {
      final r = LogicSimplifier.simplify('(A⇒B)∨(B⇒A)');
      expect(r.result, '1');
    });

    test('A⇔A reduces to 1', () {
      final r = LogicSimplifier.simplify('A⇔A');
      expect(r.result, '1');
    });

    test('NAND chain: A⊼B becomes ¬A ∨ ¬B', () {
      final r = LogicSimplifier.simplify('A⊼B');
      expect(r.result, '¬A ∨ ¬B');
      expect(r.steps.first.law, SimplificationLaw.nandDefinition);
      expect(r.steps.last.law, SimplificationLaw.deMorgan);
    });

    test('(A∧B)∨(A∧¬B) reduces to A', () {
      final r = LogicSimplifier.simplify('(A∧B)∨(A∧¬B)');
      expect(r.result, 'A');
      expect(
        r.steps.map((s) => s.law),
        contains(SimplificationLaw.factorization),
      );
      expect(r.steps.map((s) => s.law), contains(SimplificationLaw.complement));
    });

    test('special operators collapse to constants', () {
      expect(LogicSimplifier.simplify('A┲B').result, '1');
      expect(LogicSimplifier.simplify('A┹B').result, '0');
    });
  });

  group('already simplified', () {
    test('atomic and minimal expressions produce no steps', () {
      expect(LogicSimplifier.simplify('A').alreadySimplified, true);
      expect(LogicSimplifier.simplify('A∧B').alreadySimplified, true);
      expect(LogicSimplifier.simplify('¬A∨B').alreadySimplified, true);
    });
  });

  group('soundness', () {
    const expressions = [
      '¬(A∧B)∨A',
      '(A⇒B)∧(B⇒C)',
      'A⇔(B∨¬C)',
      '(A⊻B)∨(A∧B)',
      'A↓(B⊼C)',
      '¬(¬A∨¬(B∧C))',
      '(A∧B∧C)∨(A∧B∧¬C)∨(¬A∧B)',
      '(p⇒q)⇔(¬q⇒¬p)',
      'A⇏(B￩C)',
      'A⇎B',
      '(A∨B)∧(A∨¬B)∧(¬A∨C)',
    ];

    test('every step preserves logical equivalence', () {
      for (final expression in expressions) {
        final r = LogicSimplifier.simplify(expression);
        String previous = r.original;
        for (final step in r.steps) {
          expect(
            equivalent(previous, step.expression),
            true,
            reason:
                '"$expression": step "${step.law.name}" broke equivalence: '
                '"$previous" -> "${step.expression}"',
          );
          previous = step.expression;
        }
        expect(
          equivalent(expression, r.result),
          true,
          reason: '"$expression" is not equivalent to result "${r.result}"',
        );
      }
    });

    test('terminates within the step budget', () {
      for (final expression in expressions) {
        final r = LogicSimplifier.simplify(expression);
        expect(r.steps.length, lessThan(100), reason: expression);
      }
    });

    test('contrapositive tautology reduces to 1', () {
      final r = LogicSimplifier.simplify('(p⇒q)⇔(¬q⇒¬p)');
      expect(equivalent(r.result, '1'), true);
    });
  });
}
