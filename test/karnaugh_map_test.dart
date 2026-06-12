import 'package:flutter_test/flutter_test.dart';
import 'package:tablas_de_verdad_2025/class/karnaugh_map.dart';

void main() {
  KarnaughResult solve(
    List<String> vars,
    Set<int> minterms, {
    KarnaughForm form = KarnaughForm.sop,
  }) =>
      KarnaughSolver.solve(variables: vars, minterms: minterms, form: form);

  Set<String> patterns(KarnaughResult r) =>
      r.groups.map((g) => g.pattern).toSet();

  group('layout', () {
    test('2 variables -> 2x2 map, rows=A cols=B', () {
      final r = solve(['A', 'B'], {3});
      expect(r.rowCount, 2);
      expect(r.colCount, 2);
      expect(r.rowVariables, 'A');
      expect(r.colVariables, 'B');
      expect(r.rowLabels, ['0', '1']);
      expect(r.colLabels, ['0', '1']);
      // minterm 3 = A=1,B=1 -> bottom-right cell
      expect(r.minterms[1][1], 3);
      expect(r.values[1][1], 1);
    });

    test('3 variables -> 2x4 map with gray-coded columns', () {
      final r = solve(['A', 'B', 'C'], {0});
      expect(r.rowCount, 2);
      expect(r.colCount, 4);
      expect(r.rowVariables, 'A');
      expect(r.colVariables, 'BC');
      expect(r.colLabels, ['00', '01', '11', '10']);
      // Column order is gray code: BC = 00,01,11,10 -> minterms 0,1,3,2 on row A=0
      expect(r.minterms[0], [0, 1, 3, 2]);
      expect(r.minterms[1], [4, 5, 7, 6]);
    });

    test('4 variables -> 4x4 map', () {
      final r = solve(['A', 'B', 'C', 'D'], {5});
      expect(r.rowCount, 4);
      expect(r.colCount, 4);
      expect(r.rowVariables, 'AB');
      expect(r.colVariables, 'CD');
      // Row AB=01 (gray position 1), col CD=01 (gray position 1) -> minterm 5
      expect(r.minterms[1][1], 5);
    });

    test('rejects unsupported variable counts', () {
      expect(() => solve(['A'], {1}), throwsArgumentError);
      expect(
        () => solve(['A', 'B', 'C', 'D', 'E'], {1}),
        throwsArgumentError,
      );
    });
  });

  group('constants', () {
    test('contradiction -> SOP 0 / POS 0 is constant', () {
      final r = solve(['A', 'B'], {});
      expect(r.isConstant, true);
      expect(r.expression, '0');
      expect(r.groups, isEmpty);
    });

    test('tautology -> SOP 1', () {
      final r = solve(['A', 'B'], {0, 1, 2, 3});
      expect(r.isConstant, true);
      expect(r.expression, '1');
    });

    test('tautology -> POS 1 (no zeros to group)', () {
      final r = solve(['A', 'B'], {0, 1, 2, 3}, form: KarnaughForm.pos);
      expect(r.isConstant, true);
      expect(r.expression, '1');
    });
  });

  group('SOP minimization', () {
    test('single variable elimination: AB + AB̄ = A', () {
      final r = solve(['A', 'B'], {2, 3});
      expect(patterns(r), {'1-'});
      expect(r.expression, 'A');
    });

    test('XNOR has two single-cell groups', () {
      final r = solve(['A', 'B'], {0, 3});
      expect(patterns(r), {'00', '11'});
      expect(r.groups.every((g) => g.cells.length == 1), true);
      expect(r.expression, contains('¬A ∧ ¬B'));
      expect(r.expression, contains('A ∧ B'));
    });

    test('3 vars: Σ(0,2,4,6) = ¬C', () {
      final r = solve(['A', 'B', 'C'], {0, 2, 4, 6});
      expect(patterns(r), {'--0'});
      expect(r.expression, '¬C');
      // Wrap-around group: columns BC=00 and BC=10 (positions 0 and 3)
      final cols = r.groups.first.cells.map((c) => c.col).toSet();
      expect(cols, {0, 3});
      expect(r.groups.first.cells.length, 4);
    });

    test('4 vars: four corners = ¬B ∧ ¬D', () {
      final r = solve(['A', 'B', 'C', 'D'], {0, 2, 8, 10});
      expect(patterns(r), {'-0-0'});
      expect(r.expression, '(¬B ∧ ¬D)');
      expect(r.groups.first.cells.toSet(), {
        const KarnaughCellRef(0, 0),
        const KarnaughCellRef(0, 3),
        const KarnaughCellRef(3, 0),
        const KarnaughCellRef(3, 3),
      });
    });

    test('classic textbook case: Σ(0,1,2,5,6,7) needs 3 groups', () {
      // Cyclic prime implicant structure; minimal cover has 3 terms of 2 cells.
      final r = solve(['A', 'B', 'C'], {0, 1, 2, 5, 6, 7});
      expect(r.groups.length, 3);
      expect(r.groups.every((g) => g.cells.length == 2), true);
    });

    test('essential implicants are preferred over redundant covers', () {
      // Σ(0,1,3,7): minimal = ¬A¬B + C... no: 0=000,1=001,3=011,7=111
      // pairs: (0,1)=00-, (1,3)=0-1, (3,7)=-11 -> minimal 2 terms
      final r = solve(['A', 'B', 'C'], {0, 1, 3, 7});
      expect(r.groups.length, 2);
      final totalLiterals = r.groups.fold<int>(
        0,
        (acc, g) => acc + g.pattern.replaceAll('-', '').length,
      );
      expect(totalLiterals, 4);
    });
  });

  group('POS minimization', () {
    test('groups the zeros: f = A + B -> POS keeps single zero cell', () {
      // f(A,B) = A ∨ B -> minterms {1,2,3}, single 0 at minterm 0
      final r = solve(['A', 'B'], {1, 2, 3}, form: KarnaughForm.pos);
      expect(patterns(r), {'00'});
      expect(r.expression, '(A ∨ B)');
    });

    test('4 vars POS eliminates variables across zeros', () {
      // Zeros at minterms 0..7 (A=0) -> POS = A
      final r = solve(
        ['A', 'B', 'C', 'D'],
        {8, 9, 10, 11, 12, 13, 14, 15},
        form: KarnaughForm.pos,
      );
      expect(patterns(r), {'0---'});
      expect(r.expression, 'A');
    });
  });

  group('group geometry', () {
    test('every group size is a power of two', () {
      // A few arbitrary functions
      final cases = [
        {0, 1, 2, 5, 6, 7},
        {1, 2, 4, 7},
        {0, 3, 5, 6, 9, 10, 12, 15},
      ];
      for (final minterms in cases) {
        final r = solve(['A', 'B', 'C', 'D'], minterms);
        for (final g in r.groups) {
          final size = g.cells.length;
          expect(size & (size - 1), 0, reason: 'group of $size cells');
        }
      }
    });

    test('groups cover all target cells', () {
      final minterms = {1, 3, 4, 6, 9, 11, 12, 14};
      final r = solve(['A', 'B', 'C', 'D'], minterms);
      final covered = <int>{};
      for (final g in r.groups) {
        for (final cell in g.cells) {
          covered.add(r.minterms[cell.row][cell.col]);
        }
      }
      expect(covered, minterms);
    });
  });
}
