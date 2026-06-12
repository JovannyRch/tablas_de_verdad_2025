import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tablas_de_verdad_2025/class/karnaugh_map.dart';
import 'package:tablas_de_verdad_2025/widget/karnaugh_map_view.dart';

void main() {
  Future<void> pumpMap(WidgetTester tester, KarnaughResult result) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KarnaughMapView(result: result, isDark: false),
        ),
      ),
    );
  }

  testWidgets('renders headers, cell values and minterm indices', (
    tester,
  ) async {
    final result = KarnaughSolver.solve(
      variables: ['A', 'B'],
      minterms: {2, 3},
      form: KarnaughForm.sop,
    );
    await pumpMap(tester, result);

    expect(find.text('A\\B'), findsOneWidget);
    // '1' appears as: 2 cell values + 2 gray-code labels + 1 minterm index
    expect(find.text('1'), findsNWidgets(5));
    // '0' appears as: 2 cell values + 2 gray-code labels + 1 minterm index
    expect(find.text('0'), findsNWidgets(5));
  });

  testWidgets('renders 4x4 map with a wrap-around group without errors', (
    tester,
  ) async {
    // Four corners -> single group wrapping on both axes
    final result = KarnaughSolver.solve(
      variables: ['A', 'B', 'C', 'D'],
      minterms: {0, 2, 8, 10},
      form: KarnaughForm.sop,
    );
    await pumpMap(tester, result);

    expect(find.text('AB\\CD'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    // Gray-code headers on both axes ('11' and '10' also appear once each
    // as the minterm indices 11 and 10)
    expect(find.text('00'), findsNWidgets(2));
    expect(find.text('01'), findsNWidgets(2));
    expect(find.text('11'), findsNWidgets(3));
    expect(find.text('10'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders constant map (no groups) without errors', (
    tester,
  ) async {
    final result = KarnaughSolver.solve(
      variables: ['A', 'B', 'C'],
      minterms: {0, 1, 2, 3, 4, 5, 6, 7},
      form: KarnaughForm.sop,
    );
    await pumpMap(tester, result);
    expect(result.isConstant, true);
    expect(tester.takeException(), isNull);
  });
}
