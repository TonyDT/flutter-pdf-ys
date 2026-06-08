import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../services/convert_service.dart';
import 'package:share_plus/share_plus.dart';

class ImagesToPdfScreen extends StatefulWidget {
  const ImagesToPdfScreen({super.key});

  @override
  State<ImagesToPdfScreen> createState() => _ImagesToPdfScreenState();
}

class _ImagesToPdfScreenState extends State<ImagesToPdfScreen> {
  final List<File> _selectedImages = [];
  bool _isProcessing = false;
  File? _outputFile;

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(result.files.map((f) => File(f.path!)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _convertToPdf() async {
    if (_selectedImages.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      debugPrint('开始生成PDF，图片数量: ${_selectedImages.length}');
      final file = await ConvertService.imagesToPdf(_selectedImages);
      if (file != null) {
        setState(() => _outputFile = file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF生成成功！'), backgroundColor: AppColors.success),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF生成失败，请重试'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('PDF生成失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF生成失败: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _shareFile() {
    if (_outputFile != null) {
      Share.shareXFiles([XFile(_outputFile!.path)], text: 'PDF Pro - 图片转PDF');
    }
  }

  Future<void> _saveToGallery() async {
    if (_outputFile == null) return;
    
    // 使用分享功能让用户保存文件
    try {
      await Share.shareXFiles(
        [XFile(_outputFile!.path)],
        text: 'PDF Pro - 图片转PDF',
        subject: _outputFile!.path.split('/').last,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片转PDF', style: AppFonts.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('选择图片'),
                style: AppStyles.outlineButton,
              ),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('已选择 ${_selectedImages.length} 张图片', style: AppFonts.h4),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _convertToPdf,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('生成PDF'),
                ),
              ),
            ],
            if (_outputFile != null) ...[
              const SizedBox(height: 24),
              Text('输出文件', style: AppFonts.h4),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                  title: Text(_outputFile!.path.split('/').last, style: AppFonts.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.save_alt),
                        tooltip: '保存到相册',
                        onPressed: _saveToGallery,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: '分享',
                        onPressed: _shareFile,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
