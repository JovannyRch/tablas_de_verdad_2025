import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/api/api.dart';
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/model/post_expression_response.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/screens/truth_table_pdf_viewer.dart';
import 'package:tablas_de_verdad_2025/screens/video_screen.dart';
import 'package:tablas_de_verdad_2025/utils/get_cell_value.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/widget/banner_ad_widget.dart';

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

class _TruthTableResultScreenState extends State<TruthTableResultScreen> {
  late AppLocalizations _localization;
  PostExpressionResponse? response;
  late Settings _settings;

  @override
  void initState() {
    try {
      Api.postExpression(widget.truthTable.infix, widget.truthTable.tipo).then((
        value,
      ) {
        print(value);
        setState(() {
          response = value;
        });
      });
    } finally {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _localization = AppLocalizations.of(context)!;
    _settings = context.watch<Settings>();

    return Scaffold(
      floatingActionButton:
          (response != null &&
                  response!.video_link != null &&
                  response!.video_link!.isNotEmpty)
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Navegar a otra pantalla o mostrar el video
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => VideoScreen(videoUrl: response!.video_link!),
                    ),
                  );
                },
                label: Text('Ver video'),
                icon: Icon(Icons.play_circle_fill),
                tooltip: _localization.videoFABTooltip,
                backgroundColor: Colors.orange,
              )
              : null,
      appBar: AppBar(
        title: Text(_localization.result),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PdfViewerScreen(truthTable: widget.truthTable),
                ),
              );
            },
            icon: Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          if (widget.expression != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _inputLabel(),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _FinalResultBanner(
              result: getType(widget.truthTable.tipo),
              onTap: () {
                String description = getDescription(widget.truthTable.tipo);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(getType(widget.truthTable.tipo)),
                      content: Text(description),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Ok'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          _settings.isProVersion ? SizedBox.shrink() : BannerAdWidget(),
          ...widget.steps.asMap().entries.map((entry) {
            int index = entry.key;
            var step = entry.value;
            return _StepTile(step: step, index: index + 1);
          }),
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
        return _localization.contingency_description;
      case TruthTableType.contingency:
        return _localization.contingency_description;
    }
  }

  Widget _inputLabel() {
    if (widget.expression == null) {
      return const SizedBox.shrink();
    }
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Add test button */
          Text(_localization.expression, textAlign: TextAlign.left),
          SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: ThemeData().primaryColor.withAlpha(30),
            ),
            child: Center(
              child: Text(
                widget.expression!,
                style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible tile that shows the title and the truth table of a single step.
class _StepTile extends StatelessWidget {
  final TruthTableStep step;
  final int index; // human‑friendly index starting at 1

  const _StepTile({required this.step, required this.index});

  Widget _title() {
    if (step.stepProcess.isSingleVariable) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            step.stepProcess.operator.value,
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w800,
              color: kSeedColor,
            ),
          ),
          Text(
            " ${step.stepProcess.variable1}",
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          " ${step.stepProcess.variable1} ",
          style: TextStyle(fontSize: 16.0),
        ),
        Text(
          "${step.stepProcess.operator.value}",
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w800,
            color: kSeedColor,
          ),
        ),
        Text(
          " ${step.stepProcess.variable2}",
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations _localization = AppLocalizations.of(context)!;
    final isEn = _localization.localeName == 'en';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          children: [
            Text(
              isEn
                  ? step.stepProcess.operator.enName
                  : step.stepProcess.operator.esName,
            ),
            _title(),
          ],
        ),
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text('$index', style: const TextStyle(fontSize: 12)),
        ),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _TruthTableWidget(headers: step.headers, rows: step.rows),
          ),
        ],
      ),
    );
  }
}

/// Basic widget that renders a matrix of strings as a stylised truth table.
class _TruthTableWidget extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;

  _TruthTableWidget({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<Settings>();
    AppLocalizations _localization = AppLocalizations.of(context)!;
    /*   final isDescOrder = settings.mintermOrder == MintermOrder.desc; */

    return DataTable(
      headingRowHeight: 40,
      dataRowHeight: 34,
      headingRowColor: MaterialStateProperty.all(
        theme.colorScheme.surfaceVariant,
      ),
      border: TableBorder.all(color: theme.dividerColor.withOpacity(.4)),
      columns: [
        for (final header in headers)
          DataColumn(
            label: Text(
              header,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
      rows: [
        for (final row in rows)
          DataRow(
            cells: [
              for (final cell in row)
                DataCell(
                  Text(
                    getCellValue(
                      _localization.localeName,
                      settings.truthFormat,
                      cell,
                    ),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Banner that highlights the overall result (tautology, contradiction, contingencia, etc.).
class _FinalResultBanner extends StatelessWidget {
  final String result;
  final Function? onTap;

  const _FinalResultBanner({required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            result,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        Positioned(
          right: 0.0,
          bottom: 0.0,
          child: IconButton(
            icon: Icon(Icons.help, color: scheme.onPrimaryContainer),
            onPressed: () {
              onTap?.call();
            },
          ),
        ),
      ],
    );
  }
}
