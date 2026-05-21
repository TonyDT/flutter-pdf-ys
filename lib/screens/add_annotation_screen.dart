import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../services/pdf_service.dart';
import '../services/pdf_edit_service.dart';

class AddAnnotationScreen extends StatefulWidget {
  const AddAnnotationScreen({super.key});

  @override
  State<AddAnnotationScreen> createState() => _AddAnnotationScreenState();
}

class _AddAnnotationScreenState extends State<AddAnnotationScreen> {
  File? _selectedFile;
  int _totalPages = 0;
  bool _isProcessing = false;
  final _pageController = TextEditingController(text: '1');
  final _annotationController = TextEditingController();
  String _annotationType = 'highlight';
  Color _annotationColor = Colors.yellow;

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

  Future<void> _addAnnotation() async {
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _selectedFile!.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      final pageNum = int.tryParse(_pageController.text) ?? 1;

      if (pageNum >= 1 && pageNum <= doc.pages.count) {
        final page = doc.pages[pageNum - 1];
        final pdfColor = PdfColor(
          (_annotationColor.r * 255).toInt(),
          (_annotationColor.g * 255).toInt(),
          (_annotationColor.b * 255).toInt(),
        );

        if (_annotationType == 'highlight') {
          final annotation = PdfTextMarkupAnnotation(
            Rect.fromLTWH(50.0, 100.0, 300.0, 20.0),
            '高亮注释',
            pdfColor,
          );
          annotation.textMarkupAnnotationType = PdfTextMarkupAnnotationType.highlight;
          page.annotations.add(annotation);
        } else if (_annotationType == 'underline') {
          final annotation = PdfTextMarkupAnnotation(
            Rect.fromLTWH(50.0, 100.0, 300.0, 20.0),
            '下划线注释',
            pdfColor,
          );
          annotation.textMarkupAnnotationType = PdfTextMarkupAnnotationType.underline;
          page.annotations.add(annotation);
        } else if (_annotationType == 'strikethrough') {
          final annotation = PdfTextMarkupAnnotation(
            Rect.fromLTWH(50.0, 100.0, 300.0, 20.0),
            '删除线注释',
            pdfColor,
          );
          annotation.textMarkupAnnotationType = PdfTextMarkupAnnotationType.strikethrough;
          page.annotations.add(annotation);
        } else if (_annotationType == 'note') {
          final annotation = PdfPopupAnnotation(
            Rect.fromLTWH(50.0, 100.0, 20.0, 20.0),
            _annotationController.text.isEmpty ? '便签注释' : _annotationController.text,
          );
          annotation.color = pdfColor;
          page.annotations.add(annotation);
        }
      }

      final newBytes = doc.saveSync();
      doc.dispose();

      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File(p.join(outputDir.path, 'annotated_$timestamp.pdf'));
      await file.writeAsBytes(newBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注释添加成功！'), backgroundColor: AppColors.success),
        );
        Share.shareXFiles([XFile(file.path)], text: 'PDF Pro - 添加注释');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加注释失败: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _annotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加注释', style: AppFonts.h3)),
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
                    TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: AppStyles.inputDecoration(hintText: '添加注释的页码', prefixIcon: Icons.filter_1),
                    ),
                    const SizedBox(height: 16),
                    Text('注释类型', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'highlight', label: Text('高亮'), icon: Icon(Icons.highlight)),
                        ButtonSegment(value: 'underline', label: Text('下划线'), icon: Icon(Icons.format_underline)),
                        ButtonSegment(value: 'strikethrough', label: Text('删除线'), icon: Icon(Icons.strikethrough_s)),
                        ButtonSegment(value: 'note', label: Text('便签'), icon: Icon(Icons.sticky_note_2)),
                      ],
                      selected: {_annotationType},
                      onSelectionChanged: (v) => setState(() => _annotationType = v.first),
                    ),
                    if (_annotationType == 'note') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _annotationController,
                        maxLines: 3,
                        decoration: AppStyles.inputDecoration(hintText: '输入便签内容'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text('注释颜色', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [Colors.yellow, Colors.green, Colors.blue, Colors.red, Colors.purple, Colors.orange]
                          .map((c) => GestureDetector(
                                onTap: () => setState(() => _annotationColor = c),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: c,
                                    border: Border.all(color: c == _annotationColor ? AppColors.primary : AppColors.border, width: c == _annotationColor ? 3 : 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _addAnnotation,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('添加注释'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
