import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/l10n/app_localizations.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  File? _selectedFile;
  int _compressionLevel = 1;
  bool _isProcessing = false;
  String? _originalSize;
  String? _resultSize;
  File? _outputFile;

  Future<void> _pickFile() async {
    final file = await PdfService.pickPdfFile();
    if (file != null) {
      final size = await PdfService.getFileSize(file);
      setState(() {
        _selectedFile = file;
        _originalSize = size;
        _resultSize = null;
        _outputFile = null;
      });
    }
  }

  Future<void> _compress() async {
    if (_selectedFile == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isProcessing = true);
    final result =
        await PdfEditService.compressPdf(_selectedFile!, _compressionLevel);
    setState(() => _isProcessing = false);
    if (result != null && mounted) {
      final size = await PdfService.getFileSize(result);
      if (!mounted) return;
      setState(() {
        _resultSize = size;
        _outputFile = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${l10n.t('compress_success')}: $_originalSize -> $size'),
            backgroundColor: AppColors.success),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.t('compress_failed')),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('compress_pdf'), style: AppFonts.h3)),
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
                icon: const Icon(Icons.folder_open),
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
                    Text('${l10n.t('original_size')}: $_originalSize',
                        style: AppFonts.h4),
                    if (_resultSize != null) ...[
                      const SizedBox(height: 8),
                      Text('${l10n.t('compressed_size')}: $_resultSize',
                          style:
                              AppFonts.h4.copyWith(color: AppColors.success)),
                    ],
                    const SizedBox(height: 20),
                    Text(l10n.t('compression_strength'),
                        style: AppFonts.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment(
                            value: 0,
                            label: Text(l10n.t('low')),
                            icon: const Icon(Icons.speed)),
                        ButtonSegment(
                            value: 1,
                            label: Text(l10n.t('medium')),
                            icon: const Icon(Icons.balance)),
                        ButtonSegment(
                            value: 2,
                            label: Text(l10n.t('high')),
                            icon: const Icon(Icons.compress)),
                      ],
                      selected: {_compressionLevel},
                      onSelectionChanged: (v) =>
                          setState(() => _compressionLevel = v.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _compress,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : Text(l10n.t('run_compression')),
                ),
              ),
              if (_outputFile != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => SharePlus.instance.share(ShareParams(
                        files: [XFile(_outputFile!.path)],
                        text: 'PDF Pro')),
                    icon: const Icon(Icons.share),
                    label: Text(l10n.t('share_compressed_file')),
                    style: AppStyles.outlineButton,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
