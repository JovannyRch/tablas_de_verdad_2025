import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/dialogs/show_file_options_dialog.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/generate_pdf.dart';
import 'package:tablas_de_verdad_2025/widget/banner_ad_widget.dart';

class PdfViewerScreen extends StatefulWidget {
  final TruthTable truthTable;
  const PdfViewerScreen({super.key, required this.truthTable});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = false;
  bool _initialized = false;
  // Load from assets
  PDFDocument? doc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      init();
    }
  }

  init() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final t = AppLocalizations.of(context)!;
    doc = await generatePdfWithTable(widget.truthTable, t);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  _share() async {
    final t = AppLocalizations.of(context)!;
    showFileOptionsDialog(context, doc!.filePath!, t);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

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
                : Column(
                  children: [
                    // Banner ad para usuarios no Pro
                    settings.isProVersion
                        ? const SizedBox.shrink()
                        : BannerAdWidget(),
                    // PDF viewer
                    Expanded(child: PDFViewer(document: doc!)),
                  ],
                ),
      ),
    );
  }
}
