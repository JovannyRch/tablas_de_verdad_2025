import 'dart:io';
import 'dart:typed_data';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
/* import 'package:tablas_de_verdad/const/const.dart';
import 'package:tablas_de_verdad/shared/UserPreferences.dart'; */
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/const/translations.dart';

Future<Uint8List> loadFont() async {
  final data = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
  return data.buffer.asUint8List();
}

Future<PDFDocument> generatePdfWithTable(TruthTable t) async {
  final pdf = pw.Document();

  String type = "Contingencia";

  final fontData = await loadFont();
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());

  //logo
  final ByteData data = await rootBundle.load('assets/icon.png');
  final Uint8List bytes = data.buffer.asUint8List();

  final String language = t.language;

  /* UserPreferences prefs = UserPreferences(); */

  if ( /* !prefs.isShow01s */ true) {
    t.finalTable =
        t.finalTable.map((e) {
          return e.map((e) {
            if (language == 'es') {
              if (e == '1') {
                return 'V';
              } else if (e == '0') {
                return 'F';
              }
            } else {
              if (e == '1') {
                return 'T';
              } else if (e == '0') {
                return 'F';
              }
            }
            return e;
          }).toList();
        }).toList();
  }

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
              language == 'es'
                  ? 'Proposiciones: ${t.variables.join(', ')}'
                  : 'Propositions: ${t.variables.join(', ')}',
              style: pw.TextStyle(font: ttf),
            ),
            //Add space
            pw.SizedBox(height: 10),
            //Add Cantidad de proposiciones: 3
            pw.Text(
              language == 'es'
                  ? 'Cantidad de proposiciones: ${t.variables.length}'
                  : 'Number of propositions: ${t.variables.length}',
              style: pw.TextStyle(font: ttf),
            ),
            pw.SizedBox(height: 10),

            pw.Text(
              //Cantidad de filas: 8
              language == 'es'
                  ? 'Cantidad de filas: ${t.totalRows}'
                  : 'Number of rows: ${t.totalRows}',
              style: pw.TextStyle(font: ttf),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              language == 'es' ? 'Tipo: $type' : 'Type: $type',
              style: pw.TextStyle(font: ttf),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              data: t.finalTable,
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
                    (TITLE_APP ?? ' Tablas de Verdad') +
                        ' App', //TODO: Change to t.appName
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
  final filename =
      language == 'es'
          ? ('tabla_de_verdad_' + t.infix)
          : ('truth_table_' + t.infix);
  final String path = (await getTemporaryDirectory()).path + '/$filename.pdf';
  final File file = File(path);
  await file.writeAsBytes(output);

  PDFDocument doc = await PDFDocument.fromFile(file);
  return doc;
}
