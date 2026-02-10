import 'dart:io';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
/* import 'package:tablas_de_verdad/const/const.dart';
import 'package:tablas_de_verdad/shared/UserPreferences.dart'; */
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/utils/get_cell_value.dart';

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

List<List<String>> getTable(TruthTable t, String language) {
  List<List<String>> table = [];

  for (int i = 0; i < t.finalTable.length; i++) {
    List<String> row = [];

    for (int j = 0; j < t.finalTable[i].length; j++) {
      String cellValue =
          i == 0
              ? t.finalTable[i][j]
              : getCellValue(language, t.format, t.finalTable[i][j]);
      row.add(cellValue);
    }
    table.add(row);
  }

  return table;
}

Future<PDFDocument> generatePdfWithTable(
  TruthTable t,
  AppLocalizations translations,
) async {
  final pdf = pw.Document();
  final String language = t.language;
  final fontData = await loadFont();
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());

  final ByteData data = await rootBundle.load('assets/icon.png');
  final Uint8List logoBytes = data.buffer.asUint8List();

  final type = getType(translations, t.tipo);
  final finalTable = getTable(t, language);

  final now = DateTime.now();
  final dateFormatted =
      '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

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
            pw.SizedBox(height: 25),
            pw.TableHelper.fromTextArray(
              context: context,
              data: finalTable,
              headerStyle: pw.TextStyle(
                font: ttf,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey900,
              ),
              cellStyle: pw.TextStyle(font: ttf, fontSize: 9),
              cellHeight: 25.0,
              cellAlignment: pw.Alignment.center,
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            ),
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
