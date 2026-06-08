import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});

  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  final List<File> _selectedFiles = [];
  bool _isProcessing = false;

  Future<void> _pickFiles() async {
    final files = await PdfService.pickMultiplePdfFiles();
    if (files != null && files.isNotEmpty) {
      setState(() => _selectedFiles.addAll(files));
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _selectedFiles.removeAt(oldIndex);
      _selectedFiles.insert(newIndex, item);
    });
  }

  Future<void> _merge() async {
    if (_selectedFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择2个PDF文件'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isProcessing = true);
    final result = await PdfEditService.mergePdfs(_selectedFiles);
    setState(() => _isProcessing = false);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PDF合并成功！', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('已保存至应用目录', style: const TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      Share.shareXFiles([XFile(result.path)], text: 'PDF Pro - 合并结果');
      setState(() => _selectedFiles.clear());
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('合并失败'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('合并PDF', style: AppFonts.h3)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add),
                label: const Text('添加PDF文件'),
                style: AppStyles.outlineButton,
              ),
            ),
          ),
          Expanded(
            child: _selectedFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.merge_type, size: 64, color: AppColors.textHint.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('添加要合并的文件', style: AppFonts.bodyMedium.copyWith(color: AppColors.textHint)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _selectedFiles.length,
                    onReorder: _reorder,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return Card(
                        key: ValueKey(file.path),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(file.path.split('/').last, style: AppFonts.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => _removeFile(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_selectedFiles.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _merge,
                    style: AppStyles.primaryButton,
                    child: _isProcessing
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : Text('合并 ${_selectedFiles.length} 个文件'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
