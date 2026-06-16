/// Step-by-step simplification of propositional logic expressions,
/// citing the algebraic law applied at every step.
///
/// Pure Dart (no Flutter imports) so it can be unit-tested in isolation.
///
/// Strategy: derived operators (⇒, ⇔, ⊻, ⊼, ↓, ￩, ⇏, ⇍, ⇎, ┲, ┹) are first
/// rewritten into the core {¬, ∧, ∨} citing their definition, negations are
/// pushed inward (De Morgan, double negation) and then reduction laws
/// (idempotence, identity, domination, complement, absorption,
/// factorization) are applied to a fixpoint. Commutativity and
/// associativity are applied implicitly when matching, as textbooks do.
/// Every rule either removes a derived operator, moves a negation inward
/// or shrinks the tree, so the process always terminates.
library;

enum SimplificationLaw {
  conditional,
  biconditional,
  converse,
  xorDefinition,
  nandDefinition,
  norDefinition,
  negatedConditional,
  negatedConverse,
  negatedBiconditional,
  tautologyOperator,
  contradictionOperator,
  doubleNegation,
  deMorgan,
  negationOfConstant,
  idempotence,
  identity,
  domination,
  complement,
  absorption,
  factorization,
}

// ── AST ───────────────────────────────────────────────────────────────────

sealed class LogicNode {
  const LogicNode();
}

class ConstNode extends LogicNode {
  final bool value;
  const ConstNode(this.value);
}

class VarNode extends LogicNode {
  final String name;
  const VarNode(this.name);
}

class NotNode extends LogicNode {
  final LogicNode child;
  const NotNode(this.child);
}

/// Flattened n-ary conjunction or disjunction.
class NaryNode extends LogicNode {
  final bool isAnd;
  final List<LogicNode> children;
  const NaryNode(this.isAnd, this.children);
}

/// Derived binary operator (⇒, ⇔, ⊻, …), eliminated early on.
class BinNode extends LogicNode {
  final String op; // canonical operator character
  final LogicNode left;
  final LogicNode right;
  const BinNode(this.op, this.left, this.right);
}

// ── Steps / result ────────────────────────────────────────────────────────

class SimplificationStep {
  final SimplificationLaw law;

  /// The rewritten subexpression and its replacement, e.g.
  /// `¬(A ∧ B)` → `¬A ∨ ¬B`.
  final String localBefore;
  final String localAfter;

  /// Full expression after applying this step.
  final String expression;

  const SimplificationStep({
    required this.law,
    required this.localBefore,
    required this.localAfter,
    required this.expression,
  });
}

class SimplificationResult {
  final String original;
  final List<SimplificationStep> steps;

  /// Final expression (`1` / `0` when it reduces to a constant).
  final String result;

  bool get alreadySimplified => steps.isEmpty;

  const SimplificationResult({
    required this.original,
    required this.steps,
    required this.result,
  });
}

// ── Engine ────────────────────────────────────────────────────────────────

class LogicSimplifier {
  LogicSimplifier._();

  static const int _maxSteps = 100;

  /// Same precedences as [TruthTable.priorities], so expressions parse
  /// identically to the rest of the app.
  static const Map<String, int> _priorities = {
    "~": 16,
    "!": 15,
    "¬": 15,
    "⊼": 14,
    "⊻": 13,
    "⊕": 12,
    "↓": 11,
    "&": 10,
    "∧": 10,
    "|": 9,
    "∨": 9,
    "⇍": 8,
    "￩": 7,
    "⇏": 6,
    "⇎": 5,
    "┲": 4,
    "┹": 3,
    "⇒": 2,
    "⇔": 1,
    "(": 0,
  };

  static const String _alphabet =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01";

  static const Set<String> _notOps = {'~', '!', '¬'};
  static const Set<String> _andOps = {'∧', '&'};
  static const Set<String> _orOps = {'∨', '|'};

  /// Canonical character for each derived operator.
  static const Map<String, String> _canonicalOp = {
    '⊕': '⊻',
    '⊻': '⊻',
    '⇒': '⇒',
    '⇔': '⇔',
    '￩': '￩',
    '⊼': '⊼',
    '↓': '↓',
    '⇍': '⇍',
    '⇏': '⇏',
    '⇎': '⇎',
    '┲': '┲',
    '┹': '┹',
  };

  /// Simplify an infix expression (app syntax).
  static SimplificationResult simplify(String infix) => _run(parse(infix));

  /// Simplify from an already-validated postfix string (single-character
  /// tokens, as produced by `TruthTable.infixToPostfix`).
  static SimplificationResult simplifyPostfix(String postfix) =>
      _run(parsePostfix(postfix));

  static SimplificationResult _run(LogicNode root) {
    var current = _normalize(root);
    final original = printNode(current);
    final steps = <SimplificationStep>[];

    while (steps.length < _maxSteps) {
      final rewrite = _rewriteOnce(current);
      if (rewrite == null) break;
      current = _normalize(rewrite.node);
      steps.add(
        SimplificationStep(
          law: rewrite.law,
          localBefore: rewrite.before,
          localAfter: rewrite.after,
          expression: printNode(current),
        ),
      );
    }

    return SimplificationResult(
      original: original,
      steps: steps,
      result: printNode(current),
    );
  }

  // ── Parsing ─────────────────────────────────────────────────────────────

  /// Parse an infix expression using the same shunting-yard rules as
  /// [TruthTable]. Throws [FormatException] on malformed input.
  static LogicNode parse(String infix) {
    infix = infix
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll(' ', '');

    final opStack = <String>[];
    final output = <String>[];

    for (final token in infix.split('')) {
      if (_alphabet.contains(token)) {
        output.add(token);
      } else if (token == '(') {
        opStack.add(token);
      } else if (token == ')') {
        while (true) {
          if (opStack.isEmpty) {
            throw const FormatException('Unbalanced parenthesis');
          }
          final top = opStack.removeLast();
          if (top == '(') break;
          output.add(top);
        }
      } else if (_priorities.containsKey(token)) {
        while (opStack.isNotEmpty &&
            _priorities[opStack.last]! > _priorities[token]!) {
          output.add(opStack.removeLast());
        }
        opStack.add(token);
      } else {
        throw FormatException('Invalid token: $token');
      }
    }
    while (opStack.isNotEmpty) {
      final top = opStack.removeLast();
      if (top == '(') throw const FormatException('Unbalanced parenthesis');
      output.add(top);
    }
    return parsePostfix(output.join());
  }

  /// Build an AST from a postfix string of single-character tokens.
  static LogicNode parsePostfix(String postfix) {
    final stack = <LogicNode>[];

    for (final token in postfix.split('')) {
      if (_alphabet.contains(token)) {
        if (token == '0') {
          stack.add(const ConstNode(false));
        } else if (token == '1') {
          stack.add(const ConstNode(true));
        } else {
          stack.add(VarNode(token));
        }
      } else if (_notOps.contains(token)) {
        if (stack.isEmpty) throw const FormatException('Malformed expression');
        stack.add(NotNode(stack.removeLast()));
      } else {
        if (stack.length < 2) {
          throw const FormatException('Malformed expression');
        }
        final right = stack.removeLast();
        final left = stack.removeLast();
        if (_andOps.contains(token)) {
          stack.add(NaryNode(true, [left, right]));
        } else if (_orOps.contains(token)) {
          stack.add(NaryNode(false, [left, right]));
        } else {
          final op = _canonicalOp[token];
          if (op == null) throw FormatException('Invalid operator: $token');
          stack.add(BinNode(op, left, right));
        }
      }
    }
    if (stack.length != 1) throw const FormatException('Malformed expression');
    return stack.single;
  }

  // ── Printing ────────────────────────────────────────────────────────────

  /// Render a node in app notation. Compound operands are always
  /// parenthesized for clarity, e.g. `(A ∧ B) ∨ ¬C`.
  static String printNode(LogicNode node) {
    switch (node) {
      case ConstNode(:final value):
        return value ? '1' : '0';
      case VarNode(:final name):
        return name;
      case NotNode(:final child):
        return '¬${_operand(child)}';
      case NaryNode(:final isAnd, :final children):
        final separator = isAnd ? ' ∧ ' : ' ∨ ';
        return children.map(_operand).join(separator);
      case BinNode(:final op, :final left, :final right):
        return '${_operand(left)} $op ${_operand(right)}';
    }
  }

  static String _operand(LogicNode node) =>
      node is NaryNode || node is BinNode
          ? '(${printNode(node)})'
          : printNode(node);

  // ── Evaluation (used for self-checks and tests) ─────────────────────────

  static bool evaluate(LogicNode node, Map<String, bool> assignment) {
    switch (node) {
      case ConstNode(:final value):
        return value;
      case VarNode(:final name):
        return assignment[name] ?? false;
      case NotNode(:final child):
        return !evaluate(child, assignment);
      case NaryNode(:final isAnd, :final children):
        return isAnd
            ? children.every((c) => evaluate(c, assignment))
            : children.any((c) => evaluate(c, assignment));
      case BinNode(:final op, :final left, :final right):
        final l = evaluate(left, assignment);
        final r = evaluate(right, assignment);
        switch (op) {
          case '⇒':
            return !l || r;
          case '⇔':
            return l == r;
          case '￩':
            return l || !r;
          case '⊻':
            return l != r;
          case '⊼':
            return !(l && r);
          case '↓':
            return !(l || r);
          case '⇏':
            return l && !r;
          case '⇍':
            return !l && r;
          case '⇎':
            return l != r;
          case '┲':
            return true;
          case '┹':
            return false;
        }
        throw StateError('Unknown operator: $op');
    }
  }

  static List<String> variablesOf(LogicNode node) {
    final names = <String>{};
    void visit(LogicNode n) {
      switch (n) {
        case VarNode(:final name):
          names.add(name);
        case NotNode(:final child):
          visit(child);
        case NaryNode(:final children):
          children.forEach(visit);
        case BinNode(:final left, :final right):
          visit(left);
          visit(right);
        case ConstNode():
          break;
      }
    }

    visit(node);
    return names.toList()..sort();
  }

  // ── Normalization ───────────────────────────────────────────────────────

  /// Flatten nested same-operator n-ary nodes and unwrap singletons.
  static LogicNode _normalize(LogicNode node) {
    switch (node) {
      case NaryNode(:final isAnd, :final children):
        final flat = <LogicNode>[];
        for (final child in children) {
          final c = _normalize(child);
          if (c is NaryNode && c.isAnd == isAnd) {
            flat.addAll(c.children);
          } else {
            flat.add(c);
          }
        }
        if (flat.isEmpty) return ConstNode(isAnd);
        if (flat.length == 1) return flat.single;
        return NaryNode(isAnd, flat);
      case NotNode(:final child):
        return NotNode(_normalize(child));
      case BinNode(:final op, :final left, :final right):
        return BinNode(op, _normalize(left), _normalize(right));
      default:
        return node;
    }
  }

  /// Canonical key: ignores child order, so matching is done modulo
  /// commutativity and associativity.
  static String _ckey(LogicNode node) {
    switch (node) {
      case ConstNode(:final value):
        return value ? '1' : '0';
      case VarNode(:final name):
        return name;
      case NotNode(:final child):
        return '¬(${_ckey(child)})';
      case NaryNode(:final isAnd, :final children):
        final keys = children.map(_ckey).toList()..sort();
        return '${isAnd ? '∧' : '∨'}(${keys.join(',')})';
      case BinNode(:final op, :final left, :final right):
        return '$op(${_ckey(left)},${_ckey(right)})';
    }
  }

  static bool _areComplements(LogicNode a, LogicNode b) {
    if (a is NotNode && _ckey(a.child) == _ckey(b)) return true;
    if (b is NotNode && _ckey(b.child) == _ckey(a)) return true;
    return false;
  }

  // ── Rewrite search ──────────────────────────────────────────────────────

  /// Find the first applicable rewrite (pre-order traversal) and apply it.
  static _Rewrite? _rewriteOnce(LogicNode node) {
    final local = _applyLocal(node);
    if (local != null) return local;

    switch (node) {
      case NotNode(:final child):
        final r = _rewriteOnce(child);
        if (r != null) return r.wrap(NotNode(r.node));
      case NaryNode(:final isAnd, :final children):
        for (int i = 0; i < children.length; i++) {
          final r = _rewriteOnce(children[i]);
          if (r != null) {
            final updated = [...children];
            updated[i] = r.node;
            return r.wrap(NaryNode(isAnd, updated));
          }
        }
      case BinNode(:final op, :final left, :final right):
        final l = _rewriteOnce(left);
        if (l != null) return l.wrap(BinNode(op, l.node, right));
        final r = _rewriteOnce(right);
        if (r != null) return r.wrap(BinNode(op, left, r.node));
      default:
        break;
    }
    return null;
  }

  static _Rewrite? _applyLocal(LogicNode node) {
    switch (node) {
      case BinNode():
        return _eliminateDerived(node);
      case NotNode():
        return _simplifyNot(node);
      case NaryNode():
        return _simplifyNary(node);
      default:
        return null;
    }
  }

  /// Rewrite derived operators into the {¬, ∧, ∨} core, citing their law.
  static _Rewrite? _eliminateDerived(BinNode node) {
    final l = node.left;
    final r = node.right;

    LogicNode replacement;
    SimplificationLaw law;

    switch (node.op) {
      case '⇒': // A ⇒ B ≡ ¬A ∨ B
        replacement = NaryNode(false, [NotNode(l), r]);
        law = SimplificationLaw.conditional;
      case '⇔': // A ⇔ B ≡ (A ∧ B) ∨ (¬A ∧ ¬B)
        replacement = NaryNode(false, [
          NaryNode(true, [l, r]),
          NaryNode(true, [NotNode(l), NotNode(r)]),
        ]);
        law = SimplificationLaw.biconditional;
      case '￩': // A ￩ B ≡ B ⇒ A ≡ A ∨ ¬B
        replacement = NaryNode(false, [l, NotNode(r)]);
        law = SimplificationLaw.converse;
      case '⊻': // A ⊻ B ≡ (A ∧ ¬B) ∨ (¬A ∧ B)
        replacement = NaryNode(false, [
          NaryNode(true, [l, NotNode(r)]),
          NaryNode(true, [NotNode(l), r]),
        ]);
        law = SimplificationLaw.xorDefinition;
      case '⊼': // A ⊼ B ≡ ¬(A ∧ B)
        replacement = NotNode(NaryNode(true, [l, r]));
        law = SimplificationLaw.nandDefinition;
      case '↓': // A ↓ B ≡ ¬(A ∨ B)
        replacement = NotNode(NaryNode(false, [l, r]));
        law = SimplificationLaw.norDefinition;
      case '⇏': // A ⇏ B ≡ A ∧ ¬B
        replacement = NaryNode(true, [l, NotNode(r)]);
        law = SimplificationLaw.negatedConditional;
      case '⇍': // A ⇍ B ≡ ¬A ∧ B
        replacement = NaryNode(true, [NotNode(l), r]);
        law = SimplificationLaw.negatedConverse;
      case '⇎': // A ⇎ B ≡ (A ∧ ¬B) ∨ (¬A ∧ B)
        replacement = NaryNode(false, [
          NaryNode(true, [l, NotNode(r)]),
          NaryNode(true, [NotNode(l), r]),
        ]);
        law = SimplificationLaw.negatedBiconditional;
      case '┲': // always true
        replacement = const ConstNode(true);
        law = SimplificationLaw.tautologyOperator;
      case '┹': // always false
        replacement = const ConstNode(false);
        law = SimplificationLaw.contradictionOperator;
      default:
        return null;
    }

    return _Rewrite(
      node: replacement,
      law: law,
      before: printNode(node),
      after: printNode(_normalize(replacement)),
    );
  }

  static _Rewrite? _simplifyNot(NotNode node) {
    final child = node.child;

    if (child is ConstNode) {
      final replacement = ConstNode(!child.value);
      return _Rewrite(
        node: replacement,
        law: SimplificationLaw.negationOfConstant,
        before: printNode(node),
        after: printNode(replacement),
      );
    }

    if (child is NotNode) {
      return _Rewrite(
        node: child.child,
        law: SimplificationLaw.doubleNegation,
        before: printNode(node),
        after: printNode(child.child),
      );
    }

    if (child is NaryNode) {
      final replacement = NaryNode(!child.isAnd, [
        for (final c in child.children) NotNode(c),
      ]);
      return _Rewrite(
        node: replacement,
        law: SimplificationLaw.deMorgan,
        before: printNode(node),
        after: printNode(replacement),
      );
    }

    return null;
  }

  static _Rewrite? _simplifyNary(NaryNode node) {
    return _dominationRule(node) ??
        _identityRule(node) ??
        _complementRule(node) ??
        _idempotenceRule(node) ??
        _absorptionRule(node) ??
        _negativeAbsorptionRule(node) ??
        _factorizationRule(node);
  }

  /// A ∨ 1 ≡ 1, A ∧ 0 ≡ 0.
  static _Rewrite? _dominationRule(NaryNode node) {
    for (final child in node.children) {
      if (child is ConstNode && child.value != node.isAnd) {
        final replacement = ConstNode(child.value);
        return _Rewrite(
          node: replacement,
          law: SimplificationLaw.domination,
          before: printNode(node),
          after: printNode(replacement),
        );
      }
    }
    return null;
  }

  /// A ∨ 0 ≡ A, A ∧ 1 ≡ A.
  static _Rewrite? _identityRule(NaryNode node) {
    final kept = [
      for (final child in node.children)
        if (!(child is ConstNode && child.value == node.isAnd)) child,
    ];
    if (kept.length == node.children.length) return null;

    final replacement =
        kept.isEmpty ? ConstNode(node.isAnd) : NaryNode(node.isAnd, kept);
    return _Rewrite(
      node: replacement,
      law: SimplificationLaw.identity,
      before: printNode(node),
      after: printNode(_normalize(replacement)),
    );
  }

  /// A ∨ ¬A ≡ 1, A ∧ ¬A ≡ 0 (the pair collapses to a constant).
  static _Rewrite? _complementRule(NaryNode node) {
    final children = node.children;
    for (int i = 0; i < children.length; i++) {
      for (int j = i + 1; j < children.length; j++) {
        if (_areComplements(children[i], children[j])) {
          final constant = ConstNode(!node.isAnd);
          final updated = <LogicNode>[
            for (int k = 0; k < children.length; k++)
              if (k != i && k != j) children[k],
          ]..insert(0, constant);
          final separator = node.isAnd ? ' ∧ ' : ' ∨ ';
          return _Rewrite(
            node: NaryNode(node.isAnd, updated),
            law: SimplificationLaw.complement,
            before:
                '${_operand(children[i])}$separator${_operand(children[j])}',
            after: printNode(constant),
          );
        }
      }
    }
    return null;
  }

  /// A ∨ A ≡ A, A ∧ A ≡ A (modulo commutativity inside operands).
  static _Rewrite? _idempotenceRule(NaryNode node) {
    final children = node.children;
    for (int i = 0; i < children.length; i++) {
      final key = _ckey(children[i]);
      for (int j = i + 1; j < children.length; j++) {
        if (_ckey(children[j]) == key) {
          final updated = <LogicNode>[
            for (int k = 0; k < children.length; k++)
              if (k != j) children[k],
          ];
          final separator = node.isAnd ? ' ∧ ' : ' ∨ ';
          return _Rewrite(
            node: NaryNode(node.isAnd, updated),
            law: SimplificationLaw.idempotence,
            before:
                '${_operand(children[i])}$separator${_operand(children[j])}',
            after: _operand(children[i]),
          );
        }
      }
    }
    return null;
  }

  /// Factors of a child, seen from a parent with operator [parentIsAnd]:
  /// the children of an opposite-operator n-ary node, or the node itself.
  static List<LogicNode> _factors(LogicNode child, bool parentIsAnd) =>
      child is NaryNode && child.isAnd != parentIsAnd
          ? child.children
          : [child];

  /// A ∨ (A ∧ B) ≡ A, A ∧ (A ∨ B) ≡ A — generalized to subset terms.
  static _Rewrite? _absorptionRule(NaryNode node) {
    final children = node.children;
    for (int i = 0; i < children.length; i++) {
      final small = _factors(children[i], node.isAnd).map(_ckey).toSet();
      for (int j = 0; j < children.length; j++) {
        if (i == j) continue;
        final big = _factors(children[j], node.isAnd).map(_ckey).toSet();
        if (big.length > small.length && big.containsAll(small)) {
          final updated = <LogicNode>[
            for (int k = 0; k < children.length; k++)
              if (k != j) children[k],
          ];
          final separator = node.isAnd ? ' ∧ ' : ' ∨ ';
          final pair =
              i < j
                  ? '${_operand(children[i])}$separator${_operand(children[j])}'
                  : '${_operand(children[j])}$separator${_operand(children[i])}';
          return _Rewrite(
            node: NaryNode(node.isAnd, updated),
            law: SimplificationLaw.absorption,
            before: pair,
            after: _operand(children[i]),
          );
        }
      }
    }
    return null;
  }

  /// A ∨ (¬A ∧ B) ≡ A ∨ B, A ∧ (¬A ∨ B) ≡ A ∧ B.
  static _Rewrite? _negativeAbsorptionRule(NaryNode node) {
    final children = node.children;
    for (int i = 0; i < children.length; i++) {
      final literal = children[i];
      for (int j = 0; j < children.length; j++) {
        if (i == j) continue;
        final compound = children[j];
        if (compound is! NaryNode || compound.isAnd == node.isAnd) continue;

        final factorIndex = compound.children.indexWhere(
          (factor) => _areComplements(factor, literal),
        );
        if (factorIndex == -1) continue;

        final reducedFactors = <LogicNode>[
          for (int k = 0; k < compound.children.length; k++)
            if (k != factorIndex) compound.children[k],
        ];
        final reduced =
            reducedFactors.length == 1
                ? reducedFactors.single
                : NaryNode(compound.isAnd, reducedFactors);
        final updated = [...children];
        updated[j] = reduced;

        final separator = node.isAnd ? ' ∧ ' : ' ∨ ';
        return _Rewrite(
          node: NaryNode(node.isAnd, updated),
          law: SimplificationLaw.absorption,
          before: '${_operand(literal)}$separator${_operand(compound)}',
          after: '${_operand(literal)}$separator${_operand(reduced)}',
        );
      }
    }
    return null;
  }

  /// (A ∧ B) ∨ (A ∧ C) ≡ A ∧ (B ∨ C) — distributivity used in reverse,
  /// which always shrinks the expression.
  static _Rewrite? _factorizationRule(NaryNode node) {
    final children = node.children;
    for (int i = 0; i < children.length; i++) {
      final first = children[i];
      if (first is! NaryNode || first.isAnd == node.isAnd) continue;
      final firstKeys = first.children.map(_ckey).toSet();

      for (int j = i + 1; j < children.length; j++) {
        final second = children[j];
        if (second is! NaryNode || second.isAnd != first.isAnd) continue;

        final common = [
          for (final factor in first.children)
            if (second.children.any((f) => _ckey(f) == _ckey(factor))) factor,
        ];
        if (common.isEmpty) continue;
        final commonKeys = common.map(_ckey).toSet();
        // Full overlap is idempotence/absorption territory, handled earlier.
        if (commonKeys.length == firstKeys.length ||
            commonKeys.length == second.children.length) {
          continue;
        }

        LogicNode rest(NaryNode term) {
          final remaining = [
            for (final factor in term.children)
              if (!commonKeys.contains(_ckey(factor))) factor,
          ];
          return remaining.length == 1
              ? remaining.single
              : NaryNode(term.isAnd, remaining);
        }

        final factored = NaryNode(first.isAnd, [
          ...common,
          NaryNode(node.isAnd, [rest(first), rest(second)]),
        ]);
        final updated = <LogicNode>[
          for (int k = 0; k < children.length; k++)
            if (k != j) k == i ? factored : children[k],
        ];

        final separator = node.isAnd ? ' ∧ ' : ' ∨ ';
        return _Rewrite(
          node: NaryNode(node.isAnd, updated),
          law: SimplificationLaw.factorization,
          before: '${_operand(first)}$separator${_operand(second)}',
          after: _operand(_normalize(factored)),
        );
      }
    }
    return null;
  }
}

class _Rewrite {
  final LogicNode node;
  final SimplificationLaw law;
  final String before;
  final String after;

  const _Rewrite({
    required this.node,
    required this.law,
    required this.before,
    required this.after,
  });

  /// Same rewrite info with the subtree replaced by its rebuilt parent.
  _Rewrite wrap(LogicNode parent) =>
      _Rewrite(node: parent, law: law, before: before, after: after);
}
