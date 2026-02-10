import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/quiz_model.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/analytics.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  final QuizDifficulty difficulty;

  const QuizScreen({super.key, required this.difficulty});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _quizFinished = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _questions = QuizBank.getQuestions(widget.difficulty);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Verify answer using the real TruthTable engine
  int _getCorrectAnswer(QuizQuestion question) {
    final settings = context.read<Settings>();
    final t = AppLocalizations.of(context)!;
    try {
      final tt = TruthTable(
        question.expression,
        t.localeName,
        settings.truthFormat,
      );
      tt.makeAll();
      if (tt.tipo == TruthTableType.tautology) return 1;
      if (tt.tipo == TruthTableType.contradiction) return 0;
      return 2; // contingency
    } catch (_) {
      // Fallback to pre-tagged answer
      return question.correctAnswerIndex;
    }
  }

  void _onAnswer(int answerIndex) {
    if (_answered) return;

    final correct = _getCorrectAnswer(_questions[_currentIndex]);
    final isCorrect = answerIndex == correct;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedAnswer = answerIndex;
      _answered = true;
      if (isCorrect) {
        _score++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _streak = 0;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      _finishQuiz();
      return;
    }

    _animController.reset();
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
    _animController.forward();
  }

  Future<void> _finishQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final totalQuizzes = (prefs.getInt('quiz_total_quizzes') ?? 0) + 1;
    final storedBest = prefs.getInt('quiz_best_streak') ?? 0;
    final totalCorrect = (prefs.getInt('quiz_total_correct') ?? 0) + _score;

    await prefs.setInt('quiz_total_quizzes', totalQuizzes);
    await prefs.setInt('quiz_total_correct', totalCorrect);
    if (_bestStreak > storedBest) {
      await prefs.setInt('quiz_best_streak', _bestStreak);
    }

    Analytics.instance.logEvent('quiz_completed');

    if (mounted) {
      setState(() => _quizFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_quizFinished) {
      return _ResultsView(
        score: _score,
        total: _questions.length,
        bestStreak: _bestStreak,
        isDark: isDark,
        t: t,
        onRetry: () {
          _animController.reset();
          setState(() {
            _questions = QuizBank.getQuestions(widget.difficulty);
            _currentIndex = 0;
            _score = 0;
            _streak = 0;
            _bestStreak = 0;
            _selectedAnswer = null;
            _answered = false;
            _quizFinished = false;
          });
          _animController.forward();
        },
        onExit: () => Navigator.pop(context),
      );
    }

    final question = _questions[_currentIndex];
    final correct = _answered ? _getCorrectAnswer(question) : -1;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.practiceMode),
        centerTitle: true,
        actions: [
          // Streak indicator
          if (_streak > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(kSeedColor),
            minHeight: 4,
          ),

          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question counter
                    Text(
                      '${t.question} ${_currentIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Score
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: const Color(0xFF4CAF50).withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_score/${_currentIndex + (_answered ? 1 : 0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Question prompt
                    Text(
                      t.whatTypeIsThis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expression card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.white12
                                  : Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: Text(
                        question.expression,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Courier',
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Answer buttons
                    _AnswerButton(
                      label: t.tautology,
                      icon: Icons.check_circle_outline_rounded,
                      index: 1,
                      selectedAnswer: _selectedAnswer,
                      correctAnswer: correct,
                      answered: _answered,
                      isDark: isDark,
                      onTap: () => _onAnswer(1),
                    ),
                    const SizedBox(height: 10),
                    _AnswerButton(
                      label: t.contradiction,
                      icon: Icons.cancel_outlined,
                      index: 0,
                      selectedAnswer: _selectedAnswer,
                      correctAnswer: correct,
                      answered: _answered,
                      isDark: isDark,
                      onTap: () => _onAnswer(0),
                    ),
                    const SizedBox(height: 10),
                    _AnswerButton(
                      label: t.contingency,
                      icon: Icons.warning_amber_rounded,
                      index: 2,
                      selectedAnswer: _selectedAnswer,
                      correctAnswer: correct,
                      answered: _answered,
                      isDark: isDark,
                      onTap: () => _onAnswer(2),
                    ),

                    // Feedback + Next
                    if (_answered) ...[
                      const SizedBox(height: 24),
                      _FeedbackBanner(
                        isCorrect: _selectedAnswer == correct,
                        isDark: isDark,
                        t: t,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSeedColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _currentIndex < _questions.length - 1
                                ? t.next
                                : t.seeResults,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Answer button ───────────────────────────────────────────

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final int? selectedAnswer;
  final int correctAnswer;
  final bool answered;
  final bool isDark;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.index,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.answered,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (!answered) {
      bgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50]!;
      borderColor = isDark ? Colors.white12 : Colors.black.withOpacity(0.08);
      textColor = isDark ? Colors.white : Colors.black87;
    } else if (index == correctAnswer) {
      bgColor = const Color(0xFF4CAF50).withOpacity(0.12);
      borderColor = const Color(0xFF4CAF50).withOpacity(0.4);
      textColor = const Color(0xFF2E7D32);
    } else if (index == selectedAnswer) {
      bgColor = const Color(0xFFE53935).withOpacity(0.12);
      borderColor = const Color(0xFFE53935).withOpacity(0.4);
      textColor = const Color(0xFFC62828);
    } else {
      bgColor = isDark ? Colors.white.withOpacity(0.03) : Colors.grey[100]!;
      borderColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.04);
      textColor = isDark ? Colors.white38 : Colors.black26;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: answered ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (answered && index == correctAnswer)
                const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF4CAF50),
                  size: 22,
                ),
              if (answered && index == selectedAnswer && index != correctAnswer)
                const Icon(
                  Icons.close_rounded,
                  color: Color(0xFFE53935),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feedback banner ─────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final bool isDark;
  final AppLocalizations t;

  const _FeedbackBanner({
    required this.isCorrect,
    required this.isDark,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.celebration_rounded : Icons.info_outline_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCorrect ? t.correctAnswer : t.wrongAnswer,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz results view ───────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final int score;
  final int total;
  final int bestStreak;
  final bool isDark;
  final AppLocalizations t;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _ResultsView({
    required this.score,
    required this.total,
    required this.bestStreak,
    required this.isDark,
    required this.t,
    required this.onRetry,
    required this.onExit,
  });

  String _getEmoji() {
    final pct = score / total;
    if (pct >= 0.9) return '🏆';
    if (pct >= 0.7) return '🎉';
    if (pct >= 0.5) return '👍';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final pct = ((score / total) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.quizResults),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_getEmoji(), style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score/$total ${t.correctAnswers.toLowerCase()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 12),
              if (bestStreak > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFE53935),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${t.bestStreak}: $bestStreak',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(
                    t.playAgain,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSeedColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onExit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : Colors.black54,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    t.close,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
