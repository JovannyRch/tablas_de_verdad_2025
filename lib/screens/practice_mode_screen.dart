import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/quiz_model.dart';
import 'package:tablas_de_verdad_2025/screens/quiz_screen.dart';

class PracticeModeScreen extends StatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  int _totalQuizzes = 0;
  int _bestStreak = 0;
  int _totalCorrect = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _totalQuizzes = prefs.getInt('quiz_total_quizzes') ?? 0;
        _bestStreak = prefs.getInt('quiz_best_streak') ?? 0;
        _totalCorrect = prefs.getInt('quiz_total_correct') ?? 0;
      });
    }
  }

  void _startQuiz(QuizDifficulty difficulty) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(difficulty: difficulty),
      ),
    );
    _loadStats(); // Refresh stats after returning
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.practiceMode),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats summary ──
            _StatsCard(
              totalQuizzes: _totalQuizzes,
              bestStreak: _bestStreak,
              totalCorrect: _totalCorrect,
              isDark: isDark,
              t: t,
            ),
            const SizedBox(height: 28),

            // ── Difficulty selection ──
            Text(
              t.chooseDifficulty,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _DifficultyCard(
              title: t.easy,
              subtitle: t.easyDesc,
              icon: Icons.sentiment_satisfied_rounded,
              color: const Color(0xFF4CAF50),
              isDark: isDark,
              onTap: () => _startQuiz(QuizDifficulty.easy),
            ),
            const SizedBox(height: 12),
            _DifficultyCard(
              title: t.medium,
              subtitle: t.mediumDesc,
              icon: Icons.psychology_rounded,
              color: kSeedColor,
              isDark: isDark,
              onTap: () => _startQuiz(QuizDifficulty.medium),
            ),
            const SizedBox(height: 12),
            _DifficultyCard(
              title: t.hard,
              subtitle: t.hardDesc,
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFE53935),
              isDark: isDark,
              onTap: () => _startQuiz(QuizDifficulty.hard),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats card ──────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final int totalQuizzes;
  final int bestStreak;
  final int totalCorrect;
  final bool isDark;
  final AppLocalizations t;

  const _StatsCard({
    required this.totalQuizzes,
    required this.bestStreak,
    required this.totalCorrect,
    required this.isDark,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.yourStats,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                icon: Icons.quiz_rounded,
                value: '$totalQuizzes',
                label: t.quizzesPlayed,
                color: kSeedColor,
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                value: '$bestStreak',
                label: t.bestStreak,
                color: const Color(0xFFE53935),
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.check_circle_rounded,
                value: '$totalCorrect',
                label: t.correctAnswers,
                color: const Color(0xFF4CAF50),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Difficulty card ─────────────────────────────────────────

class _DifficultyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? color.withOpacity(0.1)
                : color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.3 : 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
