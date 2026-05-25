import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/premium/premium_guard.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

class CompressScreen extends ConsumerStatefulWidget {
  const CompressScreen({super.key});

  @override
  ConsumerState<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends ConsumerState<CompressScreen> {
  File? _selectedFile;
  int _compressionLevel = 1;
  bool _isProcessing = false;
  String? _originalSize;
  String? _resultSize;

  Future<void> _pickFile() async {
    final file = await PdfService.pickPdfFile();
    if (file != null) {
      final size = await PdfService.getFileSize(file);
      setState(() {
        _selectedFile = file;
        _originalSize = size;
        _resultSize = null;
      });
    }
  }

  Future<void> _compress() async {
    if (!await checkPremium(context, ref)) return;
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);
    final result = await PdfEditService.compressPdf(_selectedFile!, _compressionLevel);
    setState(() => _isProcessing = false);
    if (result != null && mounted) {
      final size = await PdfService.getFileSize(result);
      setState(() => _resultSize = size);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('压缩完成: $_originalSize → $size'), backgroundColor: AppColors.success),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compression failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAccess = ref.watch(premiumProvider).canAccess('pdf_compress');

    return Scaffold(
      appBar: AppBar(title: const Text('Compress PDF')),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Original Size: $_originalSize', style: AppFonts.h4),
                    if (_resultSize != null) ...[
                      const SizedBox(height: 8),
                      Text('Compressed: $_resultSize', style: AppFonts.h4.copyWith(color: AppColors.success)),
                    ],
                    const SizedBox(height: 16),
                    Text('Compression Level', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Low'), icon: Icon(Icons.speed)),
                        ButtonSegment(value: 1, label: Text('Medium'), icon: Icon(Icons.balance)),
                        ButtonSegment(value: 2, label: Text('High'), icon: Icon(Icons.compress)),
                      ],
                      selected: {_compressionLevel},
                      onSelectionChanged: canAccess ? (v) => setState(() => _compressionLevel = v.first) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _compress,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Compress'),
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
