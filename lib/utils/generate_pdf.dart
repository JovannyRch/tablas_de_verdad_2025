import 'dart:io';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tablas_de_verdad_2025/class/karnaugh_map.dart';
import 'package:tablas_de_verdad_2025/class/logic_simplifier.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/get_cell_value.dart';
import 'package:tablas_de_verdad_2025/utils/normal_form_converter.dart';

Future<Uint8List> loadFont() async {
  // Usar DejaVuSans que tiene mejor soporte para símbolos lógicos
  final data = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
  return data.buffer.asUint8List();
}

Future<Uint8List> loadDevanagariFont() async {
  // Usar NotoSans Devanagari específico que tiene soporte para hindi
  final data = await rootBundle.load(
    'assets/fonts/NotoSansDevanagari-Regular.ttf',
  );
  return data.buffer.asUint8List();
}

Future<Uint8List> loadHindiFont() async {
  // Usar NotoSans que tiene soporte completo para Devanagari (hindi)
  final data = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
  return data.buffer.asUint8List();
}

String getType(AppLocalizations t, TruthTableType type) {
  switch (type) {
    case TruthTableType.contingency:
      return t.contingency
          .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
          .trim();
    case TruthTableType.tautology:
      return t.tautology
          .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
          .trim();
    case TruthTableType.contradiction:
      return t.contradiction
          .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
          .trim();
  }
}

List<List<String>> getTable(TruthTable t, String language, TruthFormat format) {
  List<List<String>> table = [];

  for (int i = 0; i < t.finalTable.length; i++) {
    List<String> row = [];

    for (int j = 0; j < t.finalTable[i].length; j++) {
      String cellValue =
          i == 0
              ? t.finalTable[i][j]
              : getCellValue(language, format, t.finalTable[i][j]);
      row.add(cellValue);
    }
    table.add(row);
  }

  return table;
}

Future<PDFDocument> generatePdfWithTable(
  TruthTable t,
  AppLocalizations translations, {
  bool isPro = false,
  required TruthFormat format,
}) async {
  final pdf = pw.Document();
  final String language = t.language;
  final fontData = await loadFont();
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());

  final ByteData data = await rootBundle.load('assets/icon.png');
  final Uint8List logoBytes = data.buffer.asUint8List();

  final type = getType(translations, t.tipo);
  final finalTable = getTable(t, language, format);

  final now = DateTime.now();
  final dateFormatted =
      '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

  // Pro sections — computed once, used in build list
  NormalFormResult? normalForms;
  KarnaughResult? karnaughSop;
  SimplificationResult? simplification;

  if (isPro) {
    normalForms = NormalFormConverter.convert(t);

    final vars = t.variables;
    final hasConstantVars = vars.contains('0') || vars.contains('1');
    if (!hasConstantVars &&
        vars.length >= kMinKarnaughVariables &&
        vars.length <= kMaxKarnaughVariables) {
      final minterms = {
        for (final row in t.table)
          if (row.result == '1') row.index,
      };
      karnaughSop = KarnaughSolver.solve(
        variables: vars,
        minterms: minterms,
        form: KarnaughForm.sop,
      );
    }

    simplification = LogicSimplifier.simplifyPostfix(t.postfix);
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header:
          (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      translations.appName,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.Text(
                      translations.truthValues,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Image(pw.MemoryImage(logoBytes), width: 50, height: 50),
              ],
            ),
          ),
      footer:
          (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Column(
              children: [
                pw.Divider(thickness: 0.5, color: PdfColors.grey),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      dateFormatted,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 8,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 8,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.UrlLink(
                  child: pw.Text(
                    'https://play.google.com/store/apps/details?id=$APP_ID',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                      color: PdfColors.blue800,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  destination:
                      'https://play.google.com/store/apps/details?id=$APP_ID',
                ),
              ],
            ),
          ),
      build:
          (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                t.infix,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    translations.propositions,
                    t.variables.join(', '),
                    ttf,
                  ),
                  pw.SizedBox(height: 5),
                  _infoRow(
                    translations.numberOfPropositions,
                    t.variables.length.toString(),
                    ttf,
                  ),
                  pw.SizedBox(height: 5),
                  _infoRow(
                    translations.numberOfRows,
                    t.totalRows.toString(),
                    ttf,
                  ),
                  pw.SizedBox(height: 5),
                  _infoRow(translations.type, type, ttf, isResult: true),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            _buildRowCountNote(t, translations, ttf),
            pw.SizedBox(height: 20),
            _buildPdfTable(context, finalTable, ttf),

            // ── Pro sections ──────────────────────────────────────
            if (isPro && normalForms != null)
              ..._buildNormalFormsSection(normalForms, translations, ttf),

            if (isPro && karnaughSop != null)
              ..._buildKarnaughSection(karnaughSop, translations, ttf),

            if (isPro && simplification != null)
              ..._buildSimplificationSection(simplification, translations, ttf),
          ],
    ),
  );

  final output = await pdf.save();
  final filename =
      '${translations.pdfFilename}_${t.infix.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}';
  final String path = '${(await getTemporaryDirectory()).path}/$filename.pdf';
  final File file = File(path);
  await file.writeAsBytes(output);

  return PDFDocument.fromFile(file);
}

// ── Normal Forms section ─────────────────────────────────────────────────────

List<pw.Widget> _buildNormalFormsSection(
  NormalFormResult nf,
  AppLocalizations t,
  pw.Font ttf,
) {
  if (nf.tooManyVariables) return [];

  final mintermLabel =
      nf.mintermIndices.isEmpty ? '—' : 'Σm(${nf.mintermIndices.join(', ')})';
  final maxtermLabel =
      nf.maxtermIndices.isEmpty ? '—' : 'ΠM(${nf.maxtermIndices.join(', ')})';

  return [
    pw.SizedBox(height: 30),
    _sectionHeader(t.normalForms, ttf),
    pw.SizedBox(height: 10),
    pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _infoRow('${t.minterms}', mintermLabel, ttf),
          pw.SizedBox(height: 4),
          _infoRow('Maxterms', maxtermLabel, ttf),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 0.5, color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          _expressionBlock(
            t.dnfTitle,
            nf.dnf ?? t.dnfContradiction,
            ttf,
            nf.dnf == null,
          ),
          pw.SizedBox(height: 10),
          _expressionBlock(
            t.cnfTitle,
            nf.cnf ?? t.cnfTautology,
            ttf,
            nf.cnf == null,
          ),
        ],
      ),
    ),
  ];
}

// ── Karnaugh section ─────────────────────────────────────────────────────────

List<pw.Widget> _buildKarnaughSection(
  KarnaughResult karnaugh,
  AppLocalizations t,
  pw.Font ttf,
) {
  return [
    pw.SizedBox(height: 30),
    _sectionHeader(t.karnaughTitle, ttf),
    pw.SizedBox(height: 10),
    pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _expressionBlock(
            t.karnaughMinimizedExpression,
            karnaugh.expression,
            ttf,
            false,
          ),
        ],
      ),
    ),
  ];
}

// ── Simplification section ───────────────────────────────────────────────────

List<pw.Widget> _buildSimplificationSection(
  SimplificationResult result,
  AppLocalizations t,
  pw.Font ttf,
) {
  final widgets = <pw.Widget>[
    pw.SizedBox(height: 30),
    _sectionHeader(t.simplificationTitle, ttf),
    pw.SizedBox(height: 10),
  ];

  if (result.alreadySimplified) {
    widgets.add(
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.green50,
          border: pw.Border.all(color: PdfColors.green200),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              '✓  ',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 11,
                color: PdfColors.green800,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                '${t.simplificationResult}: ${t.simplificationAlreadySimple}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 11,
                  color: PdfColors.green800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return widgets;
  }

  widgets.add(
    pw.Text(
      t.simplificationStepCount(result.steps.length),
      style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey600),
    ),
  );
  widgets.add(pw.SizedBox(height: 8));

  for (int i = 0; i < result.steps.length; i++) {
    final step = result.steps[i];
    final lawName = _lawName(t, step.law);

    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey100,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    '${i + 1}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Text(
                  lawName,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '${step.localBefore}  ≡  ${step.localAfter}',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: const pw.BoxDecoration(color: PdfColors.grey50),
              child: pw.Text(
                step.expression,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Final result
  widgets.add(
    pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: _infoRow(
        t.simplificationResult,
        result.result,
        ttf,
        isResult: true,
      ),
    ),
  );

  return widgets;
}

// ── Shared helpers ───────────────────────────────────────────────────────────

/// Renders [n] as Unicode superscript digits (e.g. 12 → "¹²").
String _superscript(int n) {
  const sup = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
  return n.toString().split('').map((d) => sup[int.parse(d)]).join();
}

/// Explains the row count: with `n` propositions there are 2ⁿ combinations,
/// one per row. Mirrors the in‑app card on the "Full table" tab.
pw.Widget _buildRowCountNote(TruthTable t, AppLocalizations tr, pw.Font ttf) {
  final vars = t.variables.length;
  final rows = t.totalRows;
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      border: pw.Border.all(color: PdfColors.blue200),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          tr.rowCountTitle(rows),
          style: pw.TextStyle(
            font: ttf,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          tr.rowCountExplanation(vars),
          style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '2${_superscript(vars)} = $rows',
          style: pw.TextStyle(
            font: ttf,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _sectionHeader(String title, pw.Font ttf) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: const pw.BoxDecoration(
      color: PdfColors.blueGrey800,
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        font: ttf,
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
    ),
  );
}

pw.Widget _expressionBlock(
  String label,
  String expression,
  pw.Font ttf,
  bool isNull,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          font: ttf,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey700,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          color: isNull ? PdfColors.amber50 : PdfColors.grey50,
          border: pw.Border.all(
            color: isNull ? PdfColors.amber200 : PdfColors.grey200,
          ),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          expression,
          style: pw.TextStyle(
            font: ttf,
            fontSize: 11,
            color: isNull ? PdfColors.amber900 : PdfColors.black,
            fontStyle: isNull ? pw.FontStyle.italic : pw.FontStyle.normal,
          ),
        ),
      ),
    ],
  );
}

pw.Widget _infoRow(
  String label,
  String value,
  pw.Font font, {
  bool isResult = false,
}) {
  return pw.Row(
    children: [
      pw.Text(
        '$label: ',
        style: pw.TextStyle(
          font: font,
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey700,
        ),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(
          font: font,
          fontSize: 11,
          fontWeight: isResult ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isResult ? PdfColors.blue900 : PdfColors.black,
        ),
      ),
    ],
  );
}

/// Builds the PDF truth table with the last column (final result) highlighted.
pw.Widget _buildPdfTable(
  pw.Context context,
  List<List<String>> data,
  pw.Font ttf,
) {
  if (data.isEmpty) return pw.SizedBox();

  final headers = data[0];
  final lastCol = headers.length - 1;

  return pw.TableHelper.fromTextArray(
    context: context,
    data: data,
    headerStyle: pw.TextStyle(
      font: ttf,
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    ),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
    cellStyle: pw.TextStyle(font: ttf, fontSize: 9),
    cellHeight: 25.0,
    cellAlignment: pw.Alignment.center,
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    columnWidths: {
      for (int i = 0; i < headers.length; i++) i: const pw.FlexColumnWidth(),
    },
    cellDecoration: (index, data, rowNum) {
      // rowNum 0 is the header (handled by headerDecoration)
      if (rowNum == 0) return const pw.BoxDecoration();
      // Highlight the last column with a subtle tint
      if (index == lastCol) {
        return pw.BoxDecoration(
          color: rowNum.isOdd ? PdfColors.blue50 : PdfColors.blue100,
        );
      }
      // Keep odd-row striping for other columns
      return rowNum.isOdd
          ? const pw.BoxDecoration(color: PdfColors.grey50)
          : const pw.BoxDecoration();
    },
  );
}

String _lawName(AppLocalizations t, SimplificationLaw law) {
  switch (law) {
    case SimplificationLaw.conditional:
      return t.lawConditional;
    case SimplificationLaw.biconditional:
      return t.lawBiconditional;
    case SimplificationLaw.converse:
      return t.lawConverse;
    case SimplificationLaw.xorDefinition:
      return t.lawXorDefinition;
    case SimplificationLaw.nandDefinition:
      return t.lawNandDefinition;
    case SimplificationLaw.norDefinition:
      return t.lawNorDefinition;
    case SimplificationLaw.negatedConditional:
      return t.lawNegatedConditional;
    case SimplificationLaw.negatedConverse:
      return t.lawNegatedConverse;
    case SimplificationLaw.negatedBiconditional:
      return t.lawNegatedBiconditional;
    case SimplificationLaw.tautologyOperator:
      return t.lawTautologyOperator;
    case SimplificationLaw.contradictionOperator:
      return t.lawContradictionOperator;
    case SimplificationLaw.doubleNegation:
      return t.lawDoubleNegation;
    case SimplificationLaw.deMorgan:
      return t.lawDeMorgan;
    case SimplificationLaw.negationOfConstant:
      return t.lawNegationOfConstant;
    case SimplificationLaw.idempotence:
      return t.lawIdempotence;
    case SimplificationLaw.identity:
      return t.lawIdentity;
    case SimplificationLaw.domination:
      return t.lawDomination;
    case SimplificationLaw.complement:
      return t.lawComplement;
    case SimplificationLaw.absorption:
      return t.lawAbsorption;
    case SimplificationLaw.factorization:
      return t.lawFactorization;
  }
}
