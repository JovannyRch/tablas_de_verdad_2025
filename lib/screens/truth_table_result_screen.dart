import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/db/database.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/truth_table_pdf_viewer.dart';
import 'package:tablas_de_verdad_2025/utils/analytics.dart';
import 'package:tablas_de_verdad_2025/utils/get_cell_value.dart';
import 'package:tablas_de_verdad_2025/model/operator_theory.dart';
import 'package:tablas_de_verdad_2025/widget/theory_card.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/utils/utils.dart';

/// Model that represents a single step in the truth‑table resolution
/// (e.g. conjunction, negation, implication, etc.).
class TruthTableStep {
  final String title; // e.g. "Paso 1 · Conjunción"
  final StepProcess stepProcess;
  final List<String>
  headers; // column headers, usually the atomic propositions and the current expression
  final List<List<String>>
  rows; // each inner list must have the same length as [headers]

  const TruthTableStep({
    required this.title,
    required this.headers,
    required this.rows,
    required this.stepProcess,
  });
}

/// Screen that renders the step‑by‑step resolution of a truth table.
///
/// It receives the [steps] computed by your algorithm and displays each one
/// inside an [ExpansionTile], so the user can expand or collapse any step at will.
class TruthTableResultScreen extends StatefulWidget {
  final TruthTable truthTable;
  final List<TruthTableStep> steps;

  final VoidCallback?
  onRestart; // optional: to let the user calculate a new expression

  final String? expression;

  const TruthTableResultScreen({
    super.key,
    required this.steps,
    required this.truthTable,
    this.expression,
    this.onRestart,
  });

  @override
  State<TruthTableResultScreen> createState() => _TruthTableResultScreenState();
}

class _TruthTableResultScreenState extends State<TruthTableResultScreen>
    with SingleTickerProviderStateMixin {
  late AppLocalizations _localization;
  late Settings _settings;
  late TabController _tabController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final expr = widget.expression ?? widget.truthTable.infix;
    final fav = await isFavorite(expr);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final expr = widget.expression ?? widget.truthTable.infix;
    if (_isFavorite) {
      await deleteFavorite(expr);
    } else {
      await saveFavorite(expr);
      Analytics.instance.logFavoriteAdded(expr);
    }
    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? _localization.addedToFavorites
                : _localization.removedFromFavorites,
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _localization = AppLocalizations.of(context)!;
    _settings = context.watch<Settings>();
    final isDark = _settings.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : null,
            ),
            tooltip: _localization.favorites,
          ),
          IconButton(
            onPressed: () {
              final expr = widget.expression ?? widget.truthTable.infix;
              final type = getType(widget.truthTable.tipo);
              SharePlus.instance.share(ShareParams(text: '$expr\n$type'));
              Analytics.instance.logExpressionShared();
            },
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: () {
              visit(YOUTUBE_URL);
            },
            icon: const FaIcon(FontAwesomeIcons.youtube, color: Colors.red),
            tooltip: 'YouTube',
          ),
          IconButton(
            onPressed: () {
              Analytics.instance.logPdfExported();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PdfViewerScreen(truthTable: widget.truthTable),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top area: expression label + result banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                if (widget.expression != null) ...[
                  _inputLabel(isDark),
                  const SizedBox(height: 16),
                ],
                _FinalResultBanner(
                  type: widget.truthTable.tipo,
                  label: getType(widget.truthTable.tipo),
                  onTap: () {
                    _showTypeExplanationSheet(context, widget.truthTable.tipo);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: kSeedColor,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
            indicatorColor: kSeedColor,
            tabs: [
              Tab(text: _localization.steps),
              Tab(text: _localization.fullTable),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Steps
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    ...widget.steps.asMap().entries.map((entry) {
                      int index = entry.key;
                      var step = entry.value;
                      return _StepTile(step: step, index: index + 1);
                    }),
                  ],
                ),
                // Tab 2: Final Table
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: _FinalTableWidget(truthTable: widget.truthTable),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getType(TruthTableType type) {
    switch (type) {
      case TruthTableType.tautology:
        return _localization.tautology;
      case TruthTableType.contradiction:
        return _localization.contradiction;
      case TruthTableType.contingency:
        return _localization.contingency;
    }
  }

  String getDescription(TruthTableType type) {
    switch (type) {
      case TruthTableType.tautology:
        return _localization.tautology_description;
      case TruthTableType.contradiction:
        return _localization.contradiction_description;
      case TruthTableType.contingency:
        return _localization.contingency_description;
    }
  }

  void _showTypeExplanationSheet(BuildContext context, TruthTableType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = getType(type);
    final description = getDescription(type);

    Color baseColor;
    IconData icon;
    switch (type) {
      case TruthTableType.tautology:
        baseColor = Colors.green;
        icon = Icons.check_circle_rounded;
        break;
      case TruthTableType.contradiction:
        baseColor = Colors.red;
        icon = Icons.cancel_rounded;
        break;
      case TruthTableType.contingency:
        baseColor = Colors.amber;
        icon = Icons.help_rounded;
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: baseColor, size: 36),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Expression
                Text(
                  widget.expression ?? widget.truthTable.infix,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Courier',
                    color: baseColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statChip(
                        _localization.propositions,
                        '${widget.truthTable.variables.length}',
                        isDark,
                      ),
                      _statChip(
                        _localization.numberOfRows,
                        '${widget.truthTable.totalRows}',
                        isDark,
                      ),
                      _statChip(
                        _localization.steps,
                        '${widget.steps.length}',
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _statChip(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kSeedColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _inputLabel(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localization.expression.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.expression!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final TruthTableStep step;
  final int index;

  const _StepTile({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: kSeedColor.withOpacity(0.1),
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kSeedColor,
            ),
          ),
        ),
        title: Text(
          step.stepProcess.operator.getLocalizedName(localization.localeName),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: _buildSubTitle(),
        children: [
          // Theory explanation card
          Builder(
            builder: (ctx) {
              final locale = AppLocalizations.of(ctx)!.localeName;
              final theory = OperatorTheory.forOperator(
                step.stepProcess.operator,
                locale,
              );
              if (theory == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TheoryCard(
                  theory: theory,
                  operatorName: step.stepProcess.operator.getLocalizedName(
                    locale,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _TruthTableDataTable(headers: step.headers, rows: step.rows),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTitle() {
    final op = step.stepProcess.operator.value;
    final v1 = step.stepProcess.variable1;
    final v2 = step.stepProcess.variable2;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          if (step.stepProcess.isSingleVariable) ...[
            Text(
              op,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kSeedColor,
              ),
            ),
            Text(
              " $v1",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ] else ...[
            Text(
              "$v1 ",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              op,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kSeedColor,
              ),
            ),
            Text(
              " $v2",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared DataTable builder used by both step tables and the final table.
/// When [highlightLastColumn] is true, the last column header is styled in
/// [kSeedColor] and its cell text is bolder — used by the "Full table" tab.
class _TruthTableDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final bool highlightLastColumn;

  const _TruthTableDataTable({
    required this.headers,
    required this.rows,
    this.highlightLastColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<Settings>();
    final localization = AppLocalizations.of(context)!;
    final lastCol = headers.length - 1;

    return DataTable(
      headingRowHeight: 44,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 40,
      horizontalMargin: 12,
      columnSpacing: 24,
      headingRowColor: WidgetStateProperty.all(
        isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
      ),
      border: TableBorder.all(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      columns: [
        for (int i = 0; i < headers.length; i++)
          DataColumn(
            label: Expanded(
              child: Text(
                headers[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color:
                      (highlightLastColumn && i == lastCol) ? kSeedColor : null,
                ),
              ),
            ),
          ),
      ],
      rows: [
        for (final row in rows)
          DataRow(
            cells: [
              for (int i = 0; i < row.length; i++)
                DataCell(
                  Center(
                    child: Text(
                      getCellValue(
                        localization.localeName,
                        settings.truthFormat,
                        row[i],
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            (highlightLastColumn && i == lastCol)
                                ? FontWeight.w700
                                : FontWeight.w500,
                        color: _getCellColor(row[i], isDark),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  static Color? _getCellColor(String cell, bool isDark) {
    if (cell.toUpperCase() == 'V' || cell == '1') {
      return Colors.green[400];
    }
    if (cell.toUpperCase() == 'F' || cell == '0') {
      return Colors.red[400];
    }
    return null;
  }
}

class _FinalResultBanner extends StatelessWidget {
  final TruthTableType type;
  final String label;
  final VoidCallback onTap;

  const _FinalResultBanner({
    required this.type,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context)!;

    Color baseColor;
    IconData icon;

    switch (type) {
      case TruthTableType.tautology:
        baseColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case TruthTableType.contradiction:
        baseColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case TruthTableType.contingency:
        baseColor = Colors.amber;
        icon = Icons.help_outline;
        break;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: baseColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark
                                  ? (baseColor as MaterialColor)[300]
                                  : (baseColor as MaterialColor)[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            localization.more_info,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full truth‑table (all variables + all step columns).
class _FinalTableWidget extends StatelessWidget {
  final TruthTable truthTable;

  const _FinalTableWidget({required this.truthTable});

  @override
  Widget build(BuildContext context) {
    final ft = truthTable.finalTable;
    if (ft.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headers = ft[0];
    final dataRows = ft.sublist(1);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
        ),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _TruthTableDataTable(
          headers: headers,
          rows: dataRows,
          highlightLastColumn: true,
        ),
      ),
    );
  }
}
