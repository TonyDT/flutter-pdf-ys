import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/l10n/app_localizations.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

class EditPdfTextScreen extends StatefulWidget {
  const EditPdfTextScreen({super.key});

  @override
  State<EditPdfTextScreen> createState() => _EditPdfTextScreenState();
}

class _EditPdfTextScreenState extends State<EditPdfTextScreen> {
  File? _selectedFile;
  int _totalPages = 0;
  bool _isProcessing = false;
  final _oldTextController = TextEditingController();
  final _newTextController = TextEditingController();

  Future<void> _pickFile() async {
    final file = await PdfService.pickPdfFile();
    if (file != null) {
      final pages = await PdfEditService.getPageCount(file);
      setState(() {
        _selectedFile = file;
        _totalPages = pages;
      });
    }
  }

  Future<void> _processEdit() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedFile == null || _oldTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.t('enter_find_text')),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final result = await PdfEditService.replaceText(
      _selectedFile!,
      _oldTextController.text,
      _newTextController.text,
    );
    setState(() => _isProcessing = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.t('text_replace_success')),
            backgroundColor: AppColors.success),
      );
      SharePlus.instance.share(ShareParams(
        files: [XFile(result.path)],
        text: 'PDF Pro',
      ));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.t('text_replace_failed')),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _oldTextController.dispose();
    _newTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('edit_pdf_text'), style: AppFonts.h3)),
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
                    Text('${l10n.t('total_pages')}: $_totalPages',
                        style: AppFonts.h4),
                    const SizedBox(height: 16),
                    Text(l10n.t('find_replace'),
                        style: AppFonts.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _oldTextController,
                      decoration: AppStyles.inputDecoration(
                        hintText: l10n.t('find_text'),
                        prefixIcon: Icons.search,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newTextController,
                      decoration: AppStyles.inputDecoration(
                        hintText: l10n.t('replace_with'),
                        prefixIcon: Icons.repeat,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processEdit,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(l10n.t('run_replace')),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.t('edit_text_note'),
                style: AppFonts.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
