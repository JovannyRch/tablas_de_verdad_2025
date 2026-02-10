import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';

/// Result of comparing two logical expressions for equivalence.
class EquivalenceResult {
  /// Whether both expressions are logically equivalent.
  final bool isEquivalent;

  /// The truth table for expression A.
  final TruthTable tableA;

  /// The truth table for expression B.
  final TruthTable tableB;

  /// Rows where the results differ (0-indexed into the table list).
  /// Empty when [isEquivalent] is true.
  final List<int> differingRows;

  /// Error message if one of the expressions failed to parse.
  final String? error;

  const EquivalenceResult._({
    required this.isEquivalent,
    required this.tableA,
    required this.tableB,
    this.differingRows = const [],
    this.error,
  });

  bool get hasError => error != null;

  /// Percentage of rows that match (0.0 – 1.0).
  double get matchPercentage {
    if (tableA.totalRows == 0) return 0;
    return (tableA.totalRows - differingRows.length) / tableA.totalRows;
  }

  /// Number of matching rows.
  int get matchingRows => tableA.totalRows - differingRows.length;
}

/// Compares two logical expressions and determines if they are logically
/// equivalent, i.e. they produce the same result column for every possible
/// combination of their shared variables.
///
/// Both expressions must use the **same set of variables**; otherwise, the
/// checker normalises them by padding extra variables so the truth tables
/// have the same number of rows and the same variable ordering.
class EquivalenceChecker {
  EquivalenceChecker._();

  /// Run the equivalence check.
  ///
  /// Returns an [EquivalenceResult] that contains the two truth tables, the
  /// equivalence verdict, and any differing rows.
  static EquivalenceResult check(
    String exprA,
    String exprB,
    String language,
    TruthFormat format,
  ) {
    // Build two truth tables
    final ttA = TruthTable(exprA, language, format);
    final ttB = TruthTable(exprB, language, format);

    // Run full pipeline on both
    ttA.makeAll();
    ttB.makeAll();

    // Check for parse errors
    if (ttA.errorMessage.isNotEmpty) {
      return EquivalenceResult._(
        isEquivalent: false,
        tableA: ttA,
        tableB: ttB,
        error: 'A: ${ttA.errorMessage}',
      );
    }
    if (ttB.errorMessage.isNotEmpty) {
      return EquivalenceResult._(
        isEquivalent: false,
        tableA: ttA,
        tableB: ttB,
        error: 'B: ${ttB.errorMessage}',
      );
    }

    // Gather the union of variables from both expressions
    final allVars = <String>{...ttA.variables, ...ttB.variables};
    final sortedVars = allVars.toList()..sort();

    // If both expressions have the same variables, we can compare directly.
    // If not, we need to rebuild the tables with all variables so that each
    // row index maps to the same combination.
    TruthTable finalA = ttA;
    TruthTable finalB = ttB;

    if (!_sameVariables(ttA.variables, ttB.variables)) {
      // Rebuild with padded expressions that force TruthTable to include
      // all variables. We add (X ∨ ¬X) terms for missing vars (always true,
      // so it doesn't change the result column).
      final paddedA = _padExpression(exprA, ttA.variables, sortedVars);
      final paddedB = _padExpression(exprB, ttB.variables, sortedVars);

      finalA = TruthTable(paddedA, language, format);
      finalB = TruthTable(paddedB, language, format);
      finalA.makeAll();
      finalB.makeAll();

      if (finalA.errorMessage.isNotEmpty || finalB.errorMessage.isNotEmpty) {
        return EquivalenceResult._(
          isEquivalent: false,
          tableA: finalA,
          tableB: finalB,
          error:
              finalA.errorMessage.isNotEmpty
                  ? 'A: ${finalA.errorMessage}'
                  : 'B: ${finalB.errorMessage}',
        );
      }
    }

    // Now both truth tables have the same rows and variable ordering.
    // Compare result columns row by row.
    final differingRows = <int>[];
    for (int i = 0; i < finalA.table.length; i++) {
      if (finalA.table[i].result != finalB.table[i].result) {
        differingRows.add(i);
      }
    }

    return EquivalenceResult._(
      isEquivalent: differingRows.isEmpty,
      tableA: finalA,
      tableB: finalB,
      differingRows: differingRows,
    );
  }

  /// Returns true if both variable lists contain the same set.
  static bool _sameVariables(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final setA = a.toSet();
    final setB = b.toSet();
    return setA.difference(setB).isEmpty && setB.difference(setA).isEmpty;
  }

  /// Pad [expr] with identity terms for each missing variable so TruthTable
  /// includes them. The padding `(expr)∧(X∨¬X)` is logically equivalent.
  /// Actually we use a tautology term that doesn't affect the result:
  /// `(expr) ∧ ((X∨¬X)∧(Y∨¬Y)...)` which is always true.
  static String _padExpression(
    String expr,
    List<String> existingVars,
    List<String> allVars,
  ) {
    final missing = allVars.where((v) => !existingVars.contains(v)).toList();
    if (missing.isEmpty) return expr;

    final buffer = StringBuffer('($expr)');
    for (final v in missing) {
      // (V ∨ ¬V) is always 1, so ANDing it doesn't change the result
      buffer.write('∧($v∨¬$v)');
    }
    return buffer.toString();
  }
}
