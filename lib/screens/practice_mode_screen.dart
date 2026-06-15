import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/quiz_model.dart';
import 'package:tablas_de_verdad_2025/screens/fill_table_screen.dart';
import 'package:tablas_de_verdad_2025/screens/quiz_screen.dart';

/// The two practice modes: classify an expression, or complete its table.
enum PracticeType { classify, fillTable }

class PracticeModeScreen extends StatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  PracticeType _type = PracticeType.classify;

  // Classify (quiz) stats.
  int _totalQuizzes = 0;
  int _bestStreak = 0;
  int _totalCorrect = 0;

  // Fill-the-table stats.
  int _fillTables = 0;
  int _fillCorrect = 0;
  int _fillTotal = 0;

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
        _fillTables = prefs.getInt('fill_tables_completed') ?? 0;
        _fillCorrect = prefs.getInt('fill_cells_correct') ?? 0;
        _fillTotal = prefs.getInt('fill_cells_total') ?? 0;
      });
    }
  }

  void _start(QuizDifficulty difficulty) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                _type == PracticeType.classify
                    ? QuizScreen(difficulty: difficulty)
                    : FillTableScreen(difficulty: difficulty),
      ),
    );
    _loadStats(); // Refresh stats after returning
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(t.practiceMode), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mode selector ──
            Text(
              t.practiceType,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<PracticeType>(
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.transparent,
                selectedBackgroundColor: kSeedColor.withValues(alpha: 0.12),
                selectedForegroundColor: kSeedColor,
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              segments: [
                ButtonSegment(
                  value: PracticeType.classify,
                  label: Text(t.classifyMode),
                  icon: const Icon(Icons.category_outlined),
                ),
                ButtonSegment(
                  value: PracticeType.fillTable,
                  label: Text(t.fillTableMode),
                  icon: const Icon(Icons.grid_on_outlined),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 24),

            // ── Stats summary (mode-aware) ──
            _StatsCard(items: _statsItems(t), isDark: isDark, t: t),
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
              onTap: () => _start(QuizDifficulty.easy),
            ),
            const SizedBox(height: 12),
            _DifficultyCard(
              title: t.medium,
              subtitle: t.mediumDesc,
              icon: Icons.psychology_rounded,
              color: kSeedColor,
              isDark: isDark,
              onTap: () => _start(QuizDifficulty.medium),
            ),
            const SizedBox(height: 12),
            _DifficultyCard(
              title: t.hard,
              subtitle: t.hardDesc,
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFE53935),
              isDark: isDark,
              onTap: () => _start(QuizDifficulty.hard),
            ),
          ],
        ),
      ),
    );
  }

  List<_StatData> _statsItems(AppLocalizations t) {
    if (_type == PracticeType.classify) {
      return [
        _StatData(
          icon: Icons.quiz_rounded,
          value: '$_totalQuizzes',
          label: t.quizzesPlayed,
          color: kSeedColor,
        ),
        _StatData(
          icon: Icons.local_fire_department_rounded,
          value: '$_bestStreak',
          label: t.bestStreak,
          color: const Color(0xFFE53935),
        ),
        _StatData(
          icon: Icons.check_circle_rounded,
          value: '$_totalCorrect',
          label: t.correctAnswers,
          color: const Color(0xFF4CAF50),
        ),
      ];
    }
    final accuracy =
        _fillTotal == 0 ? 0 : ((_fillCorrect / _fillTotal) * 100).round();
    return [
      _StatData(
        icon: Icons.grid_on_rounded,
        value: '$_fillTables',
        label: t.tablesCompleted,
        color: kSeedColor,
      ),
      _StatData(
        icon: Icons.percent_rounded,
        value: '$accuracy%',
        label: t.accuracy,
        color: const Color(0xFF4CAF50),
      ),
      _StatData(
        icon: Icons.check_circle_rounded,
        value: '$_fillCorrect',
        label: t.correctAnswers,
        color: const Color(0xFF2196F3),
      ),
    ];
  }
}

/// One metric shown in the stats card.
class _StatData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

// ── Stats card ──────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final List<_StatData> items;
  final bool isDark;
  final AppLocalizations t;

  const _StatsCard({
    required this.items,
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
          colors:
              isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
              for (final item in items)
                _StatItem(
                  icon: item.icon,
                  value: item.value,
                  label: item.label,
                  color: item.color,
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
            color:
                isDark
                    ? color.withValues(alpha: 0.1)
                    : color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
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
