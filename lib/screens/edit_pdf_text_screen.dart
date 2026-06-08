import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
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
    if (_selectedFile == null || _oldTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入要查找的文本'), backgroundColor: AppColors.warning),
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
        const SnackBar(content: Text('文本替换成功！'), backgroundColor: AppColors.success),
      );
      Share.shareXFiles([XFile(result.path)], text: 'PDF Pro - 编辑文本');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('文本替换失败，可能未找到匹配项'), backgroundColor: AppColors.error),
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
    return Scaffold(
      appBar: AppBar(title: const Text('编辑PDF文本', style: AppFonts.h3)),
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
                    const SizedBox(height: 16),
                    Text('查找并替换', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _oldTextController,
                      decoration: AppStyles.inputDecoration(
                        hintText: '查找文本',
                        prefixIcon: Icons.search,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newTextController,
                      decoration: AppStyles.inputDecoration(
                        hintText: '替换为',
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
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('执行替换'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '注意：此功能会查找文档中所有匹配的文本并用新文本覆盖。仅适用于可编辑文本的PDF。',
                style: AppFonts.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
