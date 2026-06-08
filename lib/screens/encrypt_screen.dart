import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
        const SnackBar(content: Text('请输入密码'), backgroundColor: AppColors.warning),
      );
      return;
    }
    
    if (widget.mode == EncryptMode.encrypt) {
      if (_passwordController.text != _confirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('两次输入的密码不一致'), backgroundColor: AppColors.error),
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
          ? 'PDF加密成功！' 
          : 'PDF解密成功！';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
      Share.shareXFiles([XFile(result.path)], text: 'PDF Pro - 处理结果');
      _passwordController.clear();
      if (widget.mode == EncryptMode.encrypt) {
        _confirmController.clear();
      }
    } else if (mounted) {
      final message = widget.mode == EncryptMode.encrypt 
          ? '加密失败' 
          : '解密失败，请检查密码是否正确';
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
    final title = isEncryptMode ? '锁定PDF' : '解锁PDF';
    final buttonText = isEncryptMode ? '立即加密' : '立即解密';
    final passwordHint = isEncryptMode ? '设置密码' : '输入现有密码';
    
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
                label: Text(_selectedFile == null ? '选择PDF文件' : _selectedFile!.path.split('/').last),
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
                          hintText: '确认密码',
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
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text(buttonText),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEncryptMode 
                  ? '加密后，任何人打开此PDF都需要输入您设置的密码。请务必牢记密码。' 
                  : '解密将移除PDF的密码保护，生成一个新的无密码副本。',
                style: AppFonts.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
