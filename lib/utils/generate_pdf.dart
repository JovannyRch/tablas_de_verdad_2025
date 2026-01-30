import 'dart:io';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
/* import 'package:tablas_de_verdad/const/const.dart';
import 'package:tablas_de_verdad/shared/UserPreferences.dart'; */
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

String getType(String locale, TruthTableType type) {
  switch (type) {
    case TruthTableType.contingency:
      if (locale == 'es') return 'Contingencia';
      if (locale == 'pt') return 'Contingência';
      if (locale == 'fr') return 'Contingence';
      if (locale == 'de') return 'Kontingenz';
      if (locale == 'hi') return 'आकस्मिकता';
      return 'Contingency';
    case TruthTableType.tautology:
      if (locale == 'es') return 'Tautología';
      if (locale == 'pt') return 'Tautologia';
      if (locale == 'fr') return 'Tautologie';
      if (locale == 'de') return 'Tautologie';
      if (locale == 'hi') return 'टॉटोलॉजी';
      return 'Tautology';
    case TruthTableType.contradiction:
      if (locale == 'es') return 'Contradicción';
      if (locale == 'pt') return 'Contradição';
      if (locale == 'fr') return 'Contradiction';
      if (locale == 'de') return 'Widerspruch';
      if (locale == 'hi') return 'विरोधाभास';
      return 'Contradiction';
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

  // Siempre usar DejaVuSans que tiene los mejores símbolos lógicos
  final fontData = await loadFont();
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());

  //logo
  final ByteData data = await rootBundle.load('assets/icon.png');
  final Uint8List bytes = data.buffer.asUint8List();

  final type = getType(language, t.tipo);

  final finalTable = getTable(t, language);

  pdf.addPage(
    pw.MultiPage(
      build:
          (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                t.infix,
                style: pw.TextStyle(font: ttf, fontSize: 20),
              ),
            ),
            //Add Proposiciones: A, B, C
            pw.Text(
              '${translations.propositions}: ${t.variables.join(', ')}',
              style: pw.TextStyle(font: ttf),
            ),
            //Add space
            pw.SizedBox(height: 10),
            //Add Cantidad de proposiciones: 3
            pw.Text(
              '${translations.numberOfPropositions}: ${t.variables.length}',
              style: pw.TextStyle(font: ttf),
            ),
            pw.SizedBox(height: 10),

            pw.Text(
              //Cantidad de filas: 8
              '${translations.numberOfRows}: ${t.totalRows}',
              style: pw.TextStyle(font: ttf),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${translations.type}: $type',
              style: pw.TextStyle(font: ttf),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              data: finalTable,
              headerStyle: pw.TextStyle(
                font: ttf,
                color: PdfColors.blueGrey800,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30.0,
              cellAlignment: pw.Alignment.center,
            ),
            //Space
            pw.SizedBox(height: 60),
            //Add logo image
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(pw.MemoryImage(bytes), width: 40, height: 40),
              ],
            ),
            pw.SizedBox(height: 10),

            pw.Footer(
              title: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    '${translations.appName} App',
                    style: pw.TextStyle(font: ttf, fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            //Add webpage
            pw.Footer(
              title: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.UrlLink(
                    child: pw.Text(
                      'https://play.google.com/store/apps/details?id=com.jovannyrch.tablasdeverdad',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    destination:
                        'https://play.google.com/store/apps/details?id=com.jovannyrch.tablasdeverdad',
                  ),
                ],
              ),
            ),
          ],
    ),
  );
  final output = await pdf.save();
  final filename = '${translations.pdfFilename}_${t.infix}';
  final String path = '${(await getTemporaryDirectory()).path}/$filename.pdf';
  final File file = File(path);
  await file.writeAsBytes(output);

  PDFDocument doc = await PDFDocument.fromFile(file);
  return doc;
}
