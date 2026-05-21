import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
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
    final title = isEncryptMode ? 'Encrypt PDF' : 'Decrypt PDF';
    final buttonText = isEncryptMode ? 'Encrypt' : 'Decrypt';
    final passwordHint = isEncryptMode ? 'Password' : 'Enter Password';
    
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
                        hintText: passwordHint,
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
                      : Text(buttonText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
