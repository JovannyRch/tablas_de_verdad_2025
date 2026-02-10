import 'package:tablas_de_verdad_2025/class/row_table.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';

/// Maximum number of variables supported for FND / FNC conversion.
/// Beyond this limit the output expressions become unwieldy and computation
/// grows exponentially.
const int kMaxNormalFormVariables = 5;

/// Result of converting a truth‑table to Disjunctive / Conjunctive Normal Form.
class NormalFormResult {
  /// The Disjunctive Normal Form expression string, or `null` when the
  /// expression is a contradiction (all rows are 0 → no minterms exist).
  final String? dnf;

  /// The Conjunctive Normal Form expression string, or `null` when the
  /// expression is a tautology (all rows are 1 → no maxterms exist).
  final String? cnf;

  /// Minterm row indices (rows where result == 1).
  final List<int> mintermIndices;

  /// Maxterm row indices (rows where result == 0).
  final List<int> maxtermIndices;

  /// The sorted list of variables used.
  final List<String> variables;

  /// Whether the variable count exceeds kMaxNormalFormVariables.
  final bool tooManyVariables;

  const NormalFormResult({
    required this.dnf,
    required this.cnf,
    required this.mintermIndices,
    required this.maxtermIndices,
    required this.variables,
    this.tooManyVariables = false,
  });
}

/// Converts a [TruthTable] (already evaluated via `makeAll()`) into its
/// Disjunctive Normal Form (FND) and Conjunctive Normal Form (FNC).
///
/// **FND**: OR of the minterms (one AND‑term per row where result = 1).
/// **FNC**: AND of the maxterms (one OR‑term per row where result = 0).
class NormalFormConverter {
  NormalFormConverter._();

  /// Convert a fully evaluated [TruthTable] to normal forms.
  static NormalFormResult convert(TruthTable tt) {
    final vars = tt.variables; // already sorted

    if (vars.length > kMaxNormalFormVariables) {
      return NormalFormResult(
        dnf: null,
        cnf: null,
        mintermIndices: const [],
        maxtermIndices: const [],
        variables: vars,
        tooManyVariables: true,
      );
    }

    final minterms = <int>[]; // indices where result == 1
    final maxterms = <int>[]; // indices where result == 0

    for (final row in tt.table) {
      if (row.result == '1') {
        minterms.add(row.index);
      } else {
        maxterms.add(row.index);
      }
    }

    // Sort for consistent presentation
    minterms.sort();
    maxterms.sort();

    // Build DNF from minterms
    final dnf = _buildDNF(minterms, vars, tt.table);

    // Build CNF from maxterms
    final cnf = _buildCNF(maxterms, vars, tt.table);

    return NormalFormResult(
      dnf: dnf,
      cnf: cnf,
      mintermIndices: minterms,
      maxtermIndices: maxterms,
      variables: vars,
    );
  }

  /// Build Disjunctive Normal Form (OR of AND‑terms) from minterm rows.
  ///
  /// For each minterm row:
  ///   - if variable value is 1 → use the variable as‑is
  ///   - if variable value is 0 → negate it (¬variable)
  /// Join variables with ∧, join terms with ∨.
  static String? _buildDNF(
    List<int> mintermIndices,
    List<String> vars,
    List<RowTable> table,
  ) {
    if (mintermIndices.isEmpty) return null; // contradiction

    final terms = <String>[];
    for (final idx in mintermIndices) {
      final row = table.firstWhere((r) => r.index == idx);
      final literals = <String>[];
      for (int v = 0; v < vars.length; v++) {
        if (row.combination[v] == '1') {
          literals.add(vars[v]);
        } else {
          literals.add('¬${vars[v]}');
        }
      }
      if (literals.length == 1) {
        terms.add(literals.first);
      } else {
        terms.add('(${literals.join(' ∧ ')})');
      }
    }
    return terms.join(' ∨ ');
  }

  /// Build Conjunctive Normal Form (AND of OR‑terms) from maxterm rows.
  ///
  /// For each maxterm row:
  ///   - if variable value is 0 → use the variable as‑is
  ///   - if variable value is 1 → negate it (¬variable)
  /// Join variables with ∨, join terms with ∧.
  static String? _buildCNF(
    List<int> maxtermIndices,
    List<String> vars,
    List<RowTable> table,
  ) {
    if (maxtermIndices.isEmpty) return null; // tautology

    final terms = <String>[];
    for (final idx in maxtermIndices) {
      final row = table.firstWhere((r) => r.index == idx);
      final literals = <String>[];
      for (int v = 0; v < vars.length; v++) {
        if (row.combination[v] == '0') {
          literals.add(vars[v]);
        } else {
          literals.add('¬${vars[v]}');
        }
      }
      if (literals.length == 1) {
        terms.add(literals.first);
      } else {
        terms.add('(${literals.join(' ∨ ')})');
      }
    }
    return terms.join(' ∧ ');
  }
}
