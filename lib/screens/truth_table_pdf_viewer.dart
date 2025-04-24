import 'package:flutter/material.dart';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/dialogs/show_file_options_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/generate_pdf.dart';

class PdfViewerScreen extends StatefulWidget {
  final TruthTable truthTable;
  PdfViewerScreen({required this.truthTable});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = false;
  // Load from assets
  PDFDocument? doc;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      _isLoading = true;
    });
    doc = await generatePdfWithTable(widget.truthTable);

    setState(() {
      _isLoading = false;
    });
  }

  _share() async {
    showFileOptionsDialog(context, doc!.filePath!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* backgroundColor: kMainColor, */
        title: Text('PDF'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _share();
            },
          ),
        ],
      ),
      body: Center(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      /*  MyBannerAdWidget(), */
                      Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: PDFViewer(document: doc!),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
