import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
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
    setState(() => _isProcessing = true);
    final result = await PdfEditService.compressPdf(_selectedFile!, _compressionLevel);
    setState(() => _isProcessing = false);
    if (result != null && mounted) {
      final size = await PdfService.getFileSize(result);
      setState(() {
        _resultSize = size;
        _outputFile = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('压缩成功: $_originalSize -> $size'), backgroundColor: AppColors.success),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('压缩失败'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('压缩PDF', style: AppFonts.h3)),
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
                    Text('原始大小: $_originalSize', style: AppFonts.h4),
                    if (_resultSize != null) ...[
                      const SizedBox(height: 8),
                      Text('压缩后: $_resultSize', style: AppFonts.h4.copyWith(color: AppColors.success)),
                    ],
                    const SizedBox(height: 20),
                    Text('压缩强度', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('低'), icon: Icon(Icons.speed)),
                        ButtonSegment(value: 1, label: Text('中'), icon: Icon(Icons.balance)),
                        ButtonSegment(value: 2, label: Text('高'), icon: Icon(Icons.compress)),
                      ],
                      selected: {_compressionLevel},
                      onSelectionChanged: (v) => setState(() => _compressionLevel = v.first),
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
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('执行压缩'),
                ),
              ),
              if (_outputFile != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles([XFile(_outputFile!.path)], text: 'PDF Pro - 压缩结果'),
                    icon: const Icon(Icons.share),
                    label: const Text('分享压缩后的文件'),
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
