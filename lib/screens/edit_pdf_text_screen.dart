import 'dart:io';
import 'package:flutter/material.dart';
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
  final _pageController = TextEditingController(text: '1');

  Future<void> _pickFile() async {
    final file = await PdfService.pickPdfFile();
    if (file != null) {
      final pages = await PdfEditService.getPageCount(file);
      setState(() {
        _selectedFile = file;
        _totalPages = pages;
        _pageController.text = '1';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
                    Text('选择要编辑的页码', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: AppStyles.inputDecoration(hintText: '页码'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF文本编辑功能已打开，请在查看器中编辑'), backgroundColor: AppColors.info),
                    );
                  },
                  style: AppStyles.primaryButton,
                  child: const Text('开始编辑'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
