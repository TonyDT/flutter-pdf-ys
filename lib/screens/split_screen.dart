import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  File? _selectedFile;
  int _totalPages = 0;
  final _rangeController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final file = await PdfService.pickPdfFile();
    if (file != null) {
      final pages = await PdfEditService.getPageCount(file);
      setState(() {
        _selectedFile = file;
        _totalPages = pages;
        _rangeController.text = '1-$pages';
      });
    }
  }

  Future<void> _split() async {
    if (_selectedFile == null || _rangeController.text.isEmpty) return;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    setState(() => _isProcessing = true);
    final results = await PdfEditService.splitPdf(_selectedFile!, _rangeController.text);
    setState(() => _isProcessing = false);
    
    if (results.isNotEmpty && mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('PDF拆分成功！共生成 ${results.length} 个文件'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      // 分享第一个文件作为示例，或者可以引导用户到文件列表
      SharePlus.instance.share(ShareParams(
        files: [XFile(results.first.path)],
        text: 'PDF Pro - 拆分结果',
      ));
    } else if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('拆分失败，请检查页码范围'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拆分PDF', style: AppFonts.h3)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('总页数: $_totalPages', style: AppFonts.h4),
                    const SizedBox(height: 12),
                    Text('页码范围 (例如: 1-3, 5, 7-9)', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rangeController,
                      decoration: AppStyles.inputDecoration(hintText: '1-3, 5, 7-9'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _split,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('执行拆分'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
