import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/premium/premium_provider.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';
import 'pdf_viewer_screen.dart';

class EditPdfTextScreen extends ConsumerStatefulWidget {
  const EditPdfTextScreen({super.key});

  @override
  ConsumerState<EditPdfTextScreen> createState() => _EditPdfTextScreenState();
}

class _EditPdfTextScreenState extends ConsumerState<EditPdfTextScreen> {
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

  /// 在查看器中打开PDF（查看器支持注释等高级功能）
  Future<void> _openInViewer() async {
    if (_selectedFile == null) return;
    final page = int.tryParse(_pageController.text) ?? 1;
    if (page < 1 || page > _totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('页码超出范围'), backgroundColor: AppColors.warning),
      );
      return;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          pdfFile: _selectedFile!,
          initialPage: page,
        ),
      ),
    );
  }

  /// 提取指定页面文本（预览功能）
  Future<void> _extractAndPreviewText() async {
    if (_selectedFile == null) return;
    final page = int.tryParse(_pageController.text) ?? 1;
    if (page < 1 || page > _totalPages) return;

    setState(() => _isProcessing = true);
    try {
      final text = await PdfEditService.extractText(_selectedFile!, page);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('第 $page 页文本预览', style: AppFonts.h4),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: SelectableText(
                text.isEmpty ? '（该页面无文本内容）' : text,
                style: AppFonts.bodyMedium,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提取文本失败: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAccess = ref.watch(premiumProvider).canAccess('pdf_annotate');

    return Scaffold(
      appBar: AppBar(title: const Text('编辑PDF文本'), backgroundColor: AppColors.surface, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium 提示
            if (!canAccess)
              Container(
                width: double.infinity,
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
                  ],
                ),
              ),
            if (!canAccess) const SizedBox(height: 16),
            // 选择文件按钮
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
              const SizedBox(height: 16),
              // 在查看器中打开（支持注释/高亮）
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: canAccess ? _openInViewer : null,
                  icon: const Icon(Icons.edit_document),
                  label: const Text('在查看器中编辑'),
                  style: AppStyles.primaryButton,
                ),
              ),
              const SizedBox(height: 12),
              // 提取文本预览
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: canAccess ? _extractAndPreviewText : null,
                  icon: _isProcessing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.text_snippet),
                  label: const Text('提取页面文本'),
                  style: AppStyles.outlineButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
