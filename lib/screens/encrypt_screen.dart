import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/premium/premium_guard.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

enum EncryptMode { encrypt, decrypt }

class EncryptScreen extends ConsumerStatefulWidget {
  final EncryptMode mode;

  const EncryptScreen({super.key, this.mode = EncryptMode.encrypt});

  @override
  ConsumerState<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends ConsumerState<EncryptScreen> {
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
    if (!await checkPremium(context, ref)) return;
    if (_selectedFile == null) return;
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password'), backgroundColor: AppColors.warning),
      );
      return;
    }

    if (widget.mode == EncryptMode.encrypt) {
      if (_passwordController.text != _confirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    File? result;
    if (widget.mode == EncryptMode.encrypt) {
      result = await PdfEditService.encryptPdf(_selectedFile!, _passwordController.text);
    } else {
      result = await PdfEditService.decryptPdf(_selectedFile!, _passwordController.text);
    }

    setState(() => _isProcessing = false);

    if (result != null && mounted) {
      final message = widget.mode == EncryptMode.encrypt
          ? 'PDF encrypted successfully!'
          : 'PDF decrypted successfully!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
      _passwordController.clear();
      if (widget.mode == EncryptMode.encrypt) {
        _confirmController.clear();
      }
    } else if (mounted) {
      final message = widget.mode == EncryptMode.encrypt
          ? 'Encryption failed'
          : 'Decryption failed. Please check the password.';
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
    final isEncryptMode = widget.mode == EncryptMode.encrypt;
    final canAccess = ref.watch(premiumProvider).canAccess('pdf_encrypt');

    return Scaffold(
      appBar: AppBar(title: Text(isEncryptMode ? 'Encrypt PDF' : 'Decrypt PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!canAccess) _buildPremiumBanner(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open),
                label: Text(_selectedFile == null ? 'Select PDF' : _selectedFile!.path.split('/').last),
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
                        hintText: isEncryptMode ? 'Password' : 'Enter Password',
                        prefixIcon: Icons.lock,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    if (isEncryptMode) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmController,
                        obscureText: _obscurePassword,
                        decoration: AppStyles.inputDecoration(
                          hintText: 'Confirm Password',
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
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPdf,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEncryptMode ? 'Encrypt' : 'Decrypt'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('Premium功能，升级后可用', style: AppFonts.bodySmall.copyWith(color: AppColors.warning))),
          TextButton(
            onPressed: () => checkPremium(context, ref),
            child: const Text('升级', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }
}
