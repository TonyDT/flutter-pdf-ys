import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/convert_service.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';

class PdfToImagesScreen extends StatefulWidget {
  const PdfToImagesScreen({super.key});

  @override
  State<PdfToImagesScreen> createState() => _PdfToImagesScreenState();
}

class _PdfToImagesScreenState extends State<PdfToImagesScreen> {
  File? _selectedPdf;
  List<File>? _outputImages;
  bool _isProcessing = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPdf = File(result.files.first.path!);
        _outputImages = null;
      });
    }
  }

  Future<void> _convertToImages() async {
    if (_selectedPdf == null) return;
    setState(() => _isProcessing = true);

    try {
      // 使用已有的 ConvertService.pdfToImages 方法
      final images = await ConvertService.pdfToImages(_selectedPdf!);
      
      setState(() {
        _outputImages = images;
        _isProcessing = false;
      });
      
      if (mounted && images.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('转换成功！'), backgroundColor: AppColors.success),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('转换失败：未能生成图片'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('转换失败: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _shareImages() async {
    if (_outputImages == null || _outputImages!.isEmpty) return;
    
    try {
      final xFiles = _outputImages!.map((f) => XFile(f.path)).toList();
      await SharePlus.instance.share(ShareParams(
        files: xFiles,
        text: 'PDF Pro - PDF转图片',
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF转图片', style: AppFonts.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 选择PDF文件按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(_selectedPdf == null ? '选择PDF文件' : '重新选择'),
                style: AppStyles.outlineButton,
              ),
            ),
            
            // 显示已选择的文件
            if (_selectedPdf != null) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description, color: AppColors.primary),
                  title: Text(
                    _selectedPdf!.path.split('/').last,
                    style: AppFonts.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            
            // 转换按钮
            if (_selectedPdf != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _convertToImages,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('正在转换...'),
                          ],
                        )
                      : const Text('转换为图片'),
                ),
              ),
            ],
            
            // 显示转换后的图片列表
            if (_outputImages != null && _outputImages!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('已生成 ${_outputImages!.length} 张图片', style: AppFonts.h4),
                  ElevatedButton.icon(
                    onPressed: _shareImages,
                    icon: const Icon(Icons.share),
                    label: const Text('分享全部'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _outputImages!.length,
                itemBuilder: (context, index) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Image.file(
                                _outputImages![index],
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey[100],
                              child: Text(
                                '第 ${index + 1} 页',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.share, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                            ),
                            onPressed: () async {
                              await SharePlus.instance.share(ShareParams(
                                files: [XFile(_outputImages![index].path)],
                                text: 'PDF Pro - 第${index + 1}页',
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
