import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/l10n/app_localizations.dart';
import '../services/pdf_service.dart';
import '../services/convert_service.dart';
import 'package:share_plus/share_plus.dart';

class PdfToLongImageScreen extends StatefulWidget {
  const PdfToLongImageScreen({super.key});

  @override
  State<PdfToLongImageScreen> createState() => _PdfToLongImageScreenState();
}

class _PdfToLongImageScreenState extends State<PdfToLongImageScreen> {
  File? _selectedFile;
  File? _outputFile;
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final file = await PdfService.pickPdfFile();
    if (file != null) setState(() => _selectedFile = file);
  }

  Future<void> _convert() async {
    if (_selectedFile == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isProcessing = true);
    try {
      final images = await ConvertService.pdfToImages(_selectedFile!);
      if (images.isNotEmpty) {
        // 拼接所有图片为长图
        final outputFile = await ConvertService.concatenateImages(images);
        if (outputFile != null) {
          setState(() => _outputFile = outputFile);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(l10n.t('long_image_success')),
                  backgroundColor: AppColors.success),
            );
          }
        }
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _shareFile() {
    if (_outputFile != null) {
      SharePlus.instance.share(ShareParams(
        files: [XFile(_outputFile!.path)],
        text: 'PDF Pro',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar:
          AppBar(title: Text(l10n.t('pdf_to_long_image'), style: AppFonts.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(_selectedFile == null
                    ? l10n.t('choose_pdf_file')
                    : _selectedFile!.path.split('/').last),
                style: AppStyles.outlineButton,
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.t('instructions'), style: AppFonts.h4),
                    const SizedBox(height: 8),
                    Text(l10n.t('long_image_desc'),
                        style: AppFonts.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _convert,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(l10n.t('generate_long_image'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            if (_outputFile != null) ...[
              const SizedBox(height: 24),
              Text(l10n.t('output_file'), style: AppFonts.h4),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.image, color: AppColors.primary),
                  title: Text(_outputFile!.path.split('/').last,
                      style: AppFonts.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                      icon: const Icon(Icons.share), onPressed: _shareFile),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
