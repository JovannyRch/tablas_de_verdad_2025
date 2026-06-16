import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/quiz_model.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/analytics.dart';
import 'package:tablas_de_verdad_2025/utils/fill_table_builder.dart';
import 'package:tablas_de_verdad_2025/utils/get_cell_value.dart';

/// "Complete the table" practice mode: the student fills the final column of a
/// truth table cell by cell and gets immediate feedback. Reuses the [QuizBank]
/// expression pools, the [TruthTable] engine and the quiz's stats pattern.
class FillTableScreen extends StatefulWidget {
  final QuizDifficulty difficulty;

  const FillTableScreen({super.key, required this.difficulty});

  @override
  State<FillTableScreen> createState() => _FillTableScreenState();
}

/// A puzzle plus the original (spaced) expression text for the prompt card.
class _Puzzle {
  final FillTablePuzzle data;
  final String display;
  const _Puzzle(this.data, this.display);
}

class _FillTableScreenState extends State<FillTableScreen> {
  static const _sessionLength = 5;

  bool _ready = false;
  List<_Puzzle> _puzzles = [];
  int _index = 0;
  List<String?> _answers = [];
  bool _checked = false;

  // Session aggregates.
  int _correctCells = 0;
  int _totalCells = 0;
  bool _finished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    _buildPuzzles();
  }

  void _buildPuzzles() {
    final locale = AppLocalizations.of(context)!.localeName;
    final questions = QuizBank.getQuestions(
      widget.difficulty,
      count: _sessionLength,
    );

    final built = <_Puzzle>[];
    for (final q in questions) {
      try {
        final tt = TruthTable(q.expression.replaceAll(' ', ''), locale);
        tt.makeAll();
        final puzzle = FillTableBuilder.fromTruthTable(tt);
        if (puzzle != null) built.add(_Puzzle(puzzle, q.expression));
      } catch (_) {
        // Skip any expression the engine can't build.
      }
    }

    setState(() {
      _puzzles = built;
      _resetForCurrent();
    });
  }

  void _resetForCurrent() {
    _checked = false;
    _answers =
        _puzzles.isEmpty
            ? []
            : List<String?>.filled(_puzzles[_index].data.rowCount, null);
  }

  bool get _allFilled => _answers.every((a) => a != null);

  void _setCell(int row, String value) {
    if (_checked) return;
    HapticFeedback.selectionClick();
    setState(() => _answers[row] = value);
  }

  void _check() {
    final puzzle = _puzzles[_index].data;
    var correct = 0;
    for (int i = 0; i < puzzle.rows.length; i++) {
      if (_answers[i] == puzzle.rows[i].answer) correct++;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _checked = true;
      _correctCells += correct;
      _totalCells += puzzle.rows.length;
    });
  }

  void _next() {
    if (_index >= _puzzles.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _resetForCurrent();
    });
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'fill_tables_completed',
      (prefs.getInt('fill_tables_completed') ?? 0) + _puzzles.length,
    );
    await prefs.setInt(
      'fill_cells_correct',
      (prefs.getInt('fill_cells_correct') ?? 0) + _correctCells,
    );
    await prefs.setInt(
      'fill_cells_total',
      (prefs.getInt('fill_cells_total') ?? 0) + _totalCells,
    );
    Analytics.instance.logEvent('fill_table_completed');
    if (mounted) setState(() => _finished = true);
  }

  void _restart() {
    setState(() {
      _index = 0;
      _correctCells = 0;
      _totalCells = 0;
      _finished = false;
      _resetForCurrent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_ready || _puzzles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(t.practiceMode), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_finished) {
      return _ResultsView(
        correctCells: _correctCells,
        totalCells: _totalCells,
        tables: _puzzles.length,
        isDark: isDark,
        t: t,
        onRetry: _restart,
        onExit: () => Navigator.pop(context),
      );
    }

    final settings = context.watch<Settings>();
    final puzzle = _puzzles[_index];
    final correctSoFar =
        _checked
            ? List.generate(
              puzzle.data.rowCount,
              (i) => _answers[i] == puzzle.data.rows[i].answer,
            )
            : null;

    return Scaffold(
      appBar: AppBar(title: Text(t.practiceMode), centerTitle: true),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _puzzles.length,
            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(kSeedColor),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t.question} ${_index + 1}/${_puzzles.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Expression prompt
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Text(
                      puzzle.display,
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
                  const SizedBox(height: 16),
                  Text(
                    t.fillTableInstruction,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // The table
                  Center(
                    child: _PuzzleTable(
                      puzzle: puzzle.data,
                      answers: _answers,
                      checked: _checked,
                      correctness: correctSoFar,
                      isDark: isDark,
                      localeName: t.localeName,
                      format: settings.truthFormat,
                      onCellTap: _setCell,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_checked) ...[
                    _FeedbackBanner(
                      correct: correctSoFar!.where((c) => c).length,
                      total: puzzle.data.rowCount,
                      isDark: isDark,
                      t: t,
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          _checked ? _next : (_allFilled ? _check : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSeedColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            isDark ? Colors.white10 : Colors.grey[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _checked
                            ? (_index < _puzzles.length - 1
                                ? t.next
                                : t.seeResults)
                            : t.verifyAnswers,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Puzzle table ────────────────────────────────────────────

class _PuzzleTable extends StatelessWidget {
  final FillTablePuzzle puzzle;
  final List<String?> answers;
  final bool checked;
  final List<bool>? correctness;
  final bool isDark;
  final String localeName;
  final TruthFormat format;
  final void Function(int row, String value) onCellTap;

  const _PuzzleTable({
    required this.puzzle,
    required this.answers,
    required this.checked,
    required this.correctness,
    required this.isDark,
    required this.localeName,
    required this.format,
    required this.onCellTap,
  });

  static const _varWidth = 40.0;
  static const _finalWidth = 120.0;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08);
    final headerBg =
        isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            color: headerBg,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final v in puzzle.variables) _headerCell(v, _varWidth),
                _headerCell(puzzle.finalHeader, _finalWidth, highlight: true),
              ],
            ),
          ),
          // Rows
          for (int r = 0; r < puzzle.rows.length; r++)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final input in puzzle.rows[r].inputs)
                    _valueCell(
                      getCellValue(localeName, format, input),
                      _varWidth,
                    ),
                  _editableCell(r),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width, {bool highlight = false}) {
    return Container(
      width: width,
      height: 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color:
                highlight
                    ? kSeedColor
                    : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _valueCell(String text, double width) {
    final isTrue = text != getCellValue(localeName, format, '0');
    return Container(
      width: width,
      height: 44,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isTrue ? Colors.green[400] : Colors.red[400],
        ),
      ),
    );
  }

  Widget _editableCell(int row) {
    final trueLabel = getCellValue(localeName, format, '1');
    final falseLabel = getCellValue(localeName, format, '0');
    final selected = answers[row];

    Color? rowTint;
    if (checked && correctness != null) {
      rowTint = (correctness![row]
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE53935))
          .withValues(alpha: 0.12);
    }

    return Container(
      width: _finalWidth,
      height: 44,
      color: rowTint,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Row(
        children: [
          _option(row, '1', trueLabel, selected == '1'),
          const SizedBox(width: 6),
          _option(row, '0', falseLabel, selected == '0'),
        ],
      ),
    );
  }

  Widget _option(int row, String value, String label, bool isSelected) {
    final correctAnswer = puzzle.rows[row].answer;
    Color bg;
    Color fg;
    Border? border;

    if (checked) {
      if (value == correctAnswer) {
        bg = const Color(0xFF4CAF50).withValues(alpha: 0.25);
        fg = const Color(0xFF1B5E20);
        border = Border.all(color: const Color(0xFF4CAF50));
      } else if (isSelected) {
        bg = const Color(0xFFE53935).withValues(alpha: 0.2);
        fg = const Color(0xFFB71C1C);
        border = Border.all(color: const Color(0xFFE53935));
      } else {
        bg = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04);
        fg = isDark ? Colors.white38 : Colors.black38;
      }
    } else if (isSelected) {
      bg = kSeedColor;
      fg = Colors.white;
    } else {
      bg = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);
      fg = isDark ? Colors.white70 : Colors.black87;
    }

    return Expanded(
      child: GestureDetector(
        onTap: checked ? null : () => onCellTap(row, value),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: border,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Feedback banner ─────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  final int correct;
  final int total;
  final bool isDark;
  final AppLocalizations t;

  const _FeedbackBanner({
    required this.correct,
    required this.total,
    required this.isDark,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final allCorrect = correct == total;
    final color =
        allCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            allCorrect ? Icons.celebration_rounded : Icons.info_outline_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.cellsCorrectOfTotal(correct, total),
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

// ── Results view ────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final int correctCells;
  final int totalCells;
  final int tables;
  final bool isDark;
  final AppLocalizations t;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _ResultsView({
    required this.correctCells,
    required this.totalCells,
    required this.tables,
    required this.isDark,
    required this.t,
    required this.onRetry,
    required this.onExit,
  });

  String _emoji(double pct) {
    if (pct >= 0.9) return '🏆';
    if (pct >= 0.7) return '🎉';
    if (pct >= 0.5) return '👍';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = totalCells == 0 ? 0.0 : correctCells / totalCells;
    final pct = (ratio * 100).round();

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
              Text(_emoji(ratio), style: const TextStyle(fontSize: 64)),
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
                t.cellsCorrectOfTotal(correctCells, totalCells),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
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
