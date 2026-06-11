import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/l10n/app_localizations.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

enum EncryptMode { encrypt, decrypt }

class EncryptScreen extends StatefulWidget {
  final EncryptMode mode;

  const EncryptScreen({super.key, this.mode = EncryptMode.encrypt});

  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  File? _selectedFile;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final file = await PdfService.pickPdfFile();
    if (file != null) setState(() => _selectedFile = file);
  }

  Future<void> _processPdf() async {
    if (_selectedFile == null) return;
    final l10n = AppLocalizations.of(context);
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.t('enter_password')),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    if (widget.mode == EncryptMode.encrypt) {
      if (_passwordController.text != _confirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.t('password_mismatch')),
              backgroundColor: AppColors.error),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    File? result;
    if (widget.mode == EncryptMode.encrypt) {
      result = await PdfEditService.encryptPdf(
          _selectedFile!, _passwordController.text);
    } else {
      result = await PdfEditService.decryptPdf(
          _selectedFile!, _passwordController.text);
    }

    setState(() => _isProcessing = false);

    if (result != null && mounted) {
      final message = widget.mode == EncryptMode.encrypt
          ? l10n.t('pdf_encrypt_success')
          : l10n.t('pdf_decrypt_success');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
      SharePlus.instance.share(ShareParams(
        files: [XFile(result.path)],
        text: 'PDF Pro',
      ));
      _passwordController.clear();
      if (widget.mode == EncryptMode.encrypt) {
        _confirmController.clear();
      }
    } else if (mounted) {
      final message = widget.mode == EncryptMode.encrypt
          ? l10n.t('encrypt_failed')
          : l10n.t('decrypt_failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEncryptMode = widget.mode == EncryptMode.encrypt;
    final title = isEncryptMode ? l10n.t('lock_pdf') : l10n.t('unlock_pdf');
    final buttonText =
        isEncryptMode ? l10n.t('encrypt_now') : l10n.t('decrypt_now');
    final passwordHint =
        isEncryptMode ? l10n.t('set_password') : l10n.t('existing_password');

    return Scaffold(
      appBar: AppBar(title: Text(title, style: AppFonts.h3)),
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
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: AppStyles.inputDecoration(
                        hintText: passwordHint,
                        prefixIcon: Icons.lock,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    if (isEncryptMode) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmController,
                        obscureText: _obscurePassword,
                        decoration: AppStyles.inputDecoration(
                          hintText: l10n.t('confirm_password'),
                          prefixIcon: Icons.lock_outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPdf,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : Text(buttonText),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEncryptMode ? l10n.t('encrypt_help') : l10n.t('decrypt_help'),
                style: AppFonts.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
