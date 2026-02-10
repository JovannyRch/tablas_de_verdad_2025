import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/expression_validator.dart';
import 'package:tablas_de_verdad_2025/utils/ghost_text_controller.dart';
import 'package:tablas_de_verdad_2025/utils/ocr_expression_mapper.dart';

/// Screen that captures/picks an image, runs OCR, then lets the user confirm
/// or edit the detected logical expression before sending it back to the
/// calculator.
///
/// Returns the confirmed expression as a [String] via `Navigator.pop`.
class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  final _controller = GhostTextEditingController(text: '');
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer();

  bool _isProcessing = false;
  String? _rawText;
  ValidationResult _validation = const ValidationResult(ValidationStatus.empty);
  File? _imageFile;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // ─── Image capture / pick ──────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final t = AppLocalizations.of(context)!;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (picked == null) return;

      final imageToProcess = File(picked.path);

      if (!mounted) return;

      setState(() {
        _imageFile = imageToProcess;
        _isProcessing = true;
      });

      await _runOcr(imageToProcess);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.ocrError)));
      }
    }
  }

  // ─── OCR processing ────────────────────────────────────────────────

  Future<void> _runOcr(File image) async {
    final t = AppLocalizations.of(context)!;

    try {
      final inputImage = InputImage.fromFile(image);
      final recognised = await _textRecognizer.processImage(inputImage);

      final raw = recognised.text.trim();

      if (raw.isEmpty) {
        setState(() {
          _isProcessing = false;
          _rawText = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.ocrNoTextFound)));
        }
        return;
      }

      final mapped = OcrExpressionMapper.map(raw);

      setState(() {
        _rawText = raw;
        _isProcessing = false;
        _controller.text = mapped;
        _controller.selection = TextSelection.collapsed(offset: mapped.length);
      });
      _validateExpression();
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.ocrError)));
      }
    }
  }

  // ─── Validation ────────────────────────────────────────────────────

  void _validateExpression() {
    final t = AppLocalizations.of(context)!;
    final result = ExpressionValidator.validate(
      _controller.text,
      validationMsgUnmatched: t.validationUnmatched,
      validationMsgMissingOperand: t.validationMissingOperand,
      validationMsgMissingOperator: t.validationMissingOperator,
      validationMsgTrailingOp: t.validationTrailingOp,
      validationMsgValid: t.validationValid,
    );
    setState(() => _validation = result);
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settings = context.watch<Settings>();
    final isDark = settings.isDarkMode(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.ocrScanTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child:
              _isProcessing
                  ? _buildProcessing(t, cs)
                  : _rawText == null
                  ? _buildSourcePicker(t, isDark, cs)
                  : _buildConfirmation(t, isDark, cs),
        ),
      ),
    );
  }

  // ─── Phase 1: Choose source ────────────────────────────────────────

  Widget _buildSourcePicker(AppLocalizations t, bool isDark, ColorScheme cs) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.document_scanner_rounded, size: 80, color: cs.primary),
        const SizedBox(height: 24),
        Text(
          t.ocrScanTitle,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          t.ocrScanDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 40),
        _sourceButton(
          icon: Icons.camera_alt_rounded,
          label: t.ocrTakePhoto,
          onTap: () => _pickImage(ImageSource.camera),
          cs: cs,
        ),
        const SizedBox(height: 16),
        _sourceButton(
          icon: Icons.photo_library_rounded,
          label: t.ocrFromGallery,
          onTap: () => _pickImage(ImageSource.gallery),
          cs: cs,
          outlined: true,
        ),
      ],
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme cs,
    bool outlined = false,
  }) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.primary,
            side: BorderSide(color: cs.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ─── Phase 2: Processing ──────────────────────────────────────────

  Widget _buildProcessing(AppLocalizations t, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: 24),
          Text(
            t.ocrProcessing,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ─── Phase 3: Confirm / Edit ──────────────────────────────────────

  Widget _buildConfirmation(AppLocalizations t, bool isDark, ColorScheme cs) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview image (thumbnail)
          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_imageFile!, height: 140, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),

          // Raw text detected
          Text(
            t.ocrDetectedRaw,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _rawText ?? '',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Courier',
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Editable mapped expression
          Text(
            t.ocrMappedExpression,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autocorrect: false,
              textAlign: TextAlign.center,
              onChanged: (_) => _validateExpression(),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                border: InputBorder.none,
                hintText: t.emptyExpression,
              ),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier',
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Validation indicator
          if (!_validation.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    _validation.isValid
                        ? Icons.check_circle_rounded
                        : _validation.isIncomplete
                        ? Icons.info_outline_rounded
                        : Icons.error_outline_rounded,
                    size: 14,
                    color:
                        _validation.isValid
                            ? const Color(0xFF4CAF50)
                            : _validation.isIncomplete
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : const Color(0xFFE53935),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _validation.hint ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            _validation.isValid
                                ? const Color(0xFF4CAF50)
                                : _validation.isIncomplete
                                ? (isDark ? Colors.white38 : Colors.black38)
                                : const Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),

          // Use expression button
          FilledButton.icon(
            onPressed:
                _controller.text.isEmpty
                    ? null
                    : () => Navigator.pop(context, _controller.text),
            icon: const Icon(Icons.check_rounded),
            label: Text(t.ocrUseExpression),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Retry button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _rawText = null;
                _imageFile = null;
                _controller.clear();
                _validation = const ValidationResult(ValidationStatus.empty);
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(t.ocrRetry),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
