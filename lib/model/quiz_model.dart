import 'dart:math';

/// A single quiz question: evaluate an expression and guess its type.
class QuizQuestion {
  final String expression;

  /// 0 = contradiction, 1 = tautology, 2 = contingency
  final int correctAnswerIndex;

  const QuizQuestion({
    required this.expression,
    required this.correctAnswerIndex,
  });
}

enum QuizDifficulty { easy, medium, hard }

/// Pre-built question pools per difficulty.
/// The actual "correct answer" is verified at runtime via TruthTable engine,
/// but we pre-tag them so the UI can build offline-first.
class QuizBank {
  static final _random = Random();

  // ── Easy: simple 1-2 variable expressions ─────────────────
  static const _easy = [
    // Tautologies
    QuizQuestion(expression: 'A ∨ ¬A', correctAnswerIndex: 1),
    QuizQuestion(expression: 'A ⇒ A', correctAnswerIndex: 1),
    QuizQuestion(expression: '¬(A ∧ ¬A)', correctAnswerIndex: 1),
    QuizQuestion(expression: '(A ⇒ B) ∨ (B ⇒ A)', correctAnswerIndex: 1),
    QuizQuestion(expression: 'A ∨ ¬A ∨ B', correctAnswerIndex: 1),
    // Contradictions
    QuizQuestion(expression: 'A ∧ ¬A', correctAnswerIndex: 0),
    QuizQuestion(expression: '¬(A ∨ ¬A)', correctAnswerIndex: 0),
    QuizQuestion(expression: '(A ∧ ¬A) ∧ B', correctAnswerIndex: 0),
    // Contingencies
    QuizQuestion(expression: 'A ∧ B', correctAnswerIndex: 2),
    QuizQuestion(expression: 'A ∨ B', correctAnswerIndex: 2),
    QuizQuestion(expression: 'A ⇒ B', correctAnswerIndex: 2),
    QuizQuestion(expression: '¬A', correctAnswerIndex: 2),
    QuizQuestion(expression: 'A ⇔ B', correctAnswerIndex: 2),
    QuizQuestion(expression: '¬A ∧ B', correctAnswerIndex: 2),
    QuizQuestion(expression: 'A ∨ ¬B', correctAnswerIndex: 2),
  ];

  // ── Medium: 2-3 variable compound expressions ─────────────
  static const _medium = [
    // Tautologies
    QuizQuestion(expression: '(A ⇒ B) ⇔ (¬B ⇒ ¬A)', correctAnswerIndex: 1),
    QuizQuestion(expression: '(A ∧ B) ⇒ A', correctAnswerIndex: 1),
    QuizQuestion(expression: 'A ⇒ (A ∨ B)', correctAnswerIndex: 1),
    QuizQuestion(
      expression: '(A ⇒ B) ⇔ (¬A ∨ B)',
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      expression: '((A ⇒ B) ∧ (B ⇒ C)) ⇒ (A ⇒ C)',
      correctAnswerIndex: 1,
    ),
    // Contradictions
    QuizQuestion(expression: '(A ∧ ¬A) ∧ (B ∨ C)', correctAnswerIndex: 0),
    QuizQuestion(
      expression: '(A ⇒ B) ∧ (A ∧ ¬B)',
      correctAnswerIndex: 0,
    ),
    QuizQuestion(expression: '¬(A ⇒ A)', correctAnswerIndex: 0),
    // Contingencies
    QuizQuestion(expression: '(A ∨ B) ∧ ¬C', correctAnswerIndex: 2),
    QuizQuestion(expression: '(A ⇒ B) ∧ C', correctAnswerIndex: 2),
    QuizQuestion(expression: '(A ⇔ B) ∧ C', correctAnswerIndex: 2),
    QuizQuestion(expression: '(A ∧ B) ∨ (B ∧ C)', correctAnswerIndex: 2),
    QuizQuestion(expression: '¬A ⇒ (B ∧ C)', correctAnswerIndex: 2),
    QuizQuestion(expression: '(A ∨ B) ⇒ C', correctAnswerIndex: 2),
    QuizQuestion(expression: 'A ⇔ (B ⇒ C)', correctAnswerIndex: 2),
  ];

  // ── Hard: 3-4 variable, nested, using ⊕ XOR etc. ─────────
  static const _hard = [
    // Tautologies
    QuizQuestion(
      expression: '((A ⇒ B) ∧ (B ⇒ C)) ⇒ (A ⇒ C)',
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      expression: '(A ∧ (A ⇒ B)) ⇒ B',
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      expression: '(¬A ⇒ B) ⇔ (¬B ⇒ A)',
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      expression: '((A ∨ B) ∧ ¬A) ⇒ B',
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      expression: '(A ⇒ (B ⇒ C)) ⇔ ((A ∧ B) ⇒ C)',
      correctAnswerIndex: 1,
    ),
    // Contradictions
    QuizQuestion(
      expression: '(A ⇔ ¬A)',
      correctAnswerIndex: 0,
    ),
    QuizQuestion(
      expression: '(A ∧ B) ∧ (¬A ∧ ¬B)',
      correctAnswerIndex: 0,
    ),
    QuizQuestion(
      expression: '(A ⇒ B) ∧ (B ⇒ A) ∧ (A ⇔ ¬B)',
      correctAnswerIndex: 0,
    ),
    // Contingencies
    QuizQuestion(
      expression: '(A ⇒ B) ∧ (C ⇒ D)',
      correctAnswerIndex: 2,
    ),
    QuizQuestion(
      expression: '(A ∧ B) ⇔ (C ∨ D)',
      correctAnswerIndex: 2,
    ),
    QuizQuestion(
      expression: '(A ⇒ (B ∧ C)) ∨ (D ⇒ A)',
      correctAnswerIndex: 2,
    ),
    QuizQuestion(
      expression: '¬(A ⇔ B) ∧ (C ⇒ A)',
      correctAnswerIndex: 2,
    ),
    QuizQuestion(
      expression: '(A ∧ ¬B) ⇒ (C ∨ D)',
      correctAnswerIndex: 2,
    ),
    QuizQuestion(
      expression: '((A ∨ B) ∧ (C ∨ D)) ⇒ (A ∧ D)',
      correctAnswerIndex: 2,
    ),
  ];

  /// Returns a shuffled list of [count] questions for the given difficulty.
  static List<QuizQuestion> getQuestions(QuizDifficulty difficulty,
      {int count = 10}) {
    final pool = switch (difficulty) {
      QuizDifficulty.easy => List<QuizQuestion>.from(_easy),
      QuizDifficulty.medium => List<QuizQuestion>.from(_medium),
      QuizDifficulty.hard => List<QuizQuestion>.from(_hard),
    };
    pool.shuffle(_random);
    return pool.take(count.clamp(1, pool.length)).toList();
  }
}
