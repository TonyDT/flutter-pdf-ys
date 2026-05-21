import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
    
    // 保存 context 引用，避免 async gap 问题
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    setState(() => _isProcessing = true);
    final results = await PdfEditService.splitPdf(_selectedFile!, _rangeController.text);
    setState(() => _isProcessing = false);
    
    if (results.isNotEmpty && mounted) {
      // 获取输出目录
      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PDF拆分成功！共 ${results.length} 个文件', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('保存至: ${outputDir.path}', style: const TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '确定',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } else if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Split failed'), backgroundColor: AppColors.error),
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
      appBar: AppBar(title: const Text('Split PDF', style: AppFonts.h3)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pages: $_totalPages', style: AppFonts.h4),
                    const SizedBox(height: 12),
                    Text('Page Ranges (e.g. 1-3, 5, 7-9)', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _split,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Split'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
