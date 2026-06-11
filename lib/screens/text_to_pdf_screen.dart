import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';

class TextToPdfScreen extends StatefulWidget {
  const TextToPdfScreen({super.key});

  @override
  State<TextToPdfScreen> createState() => _TextToPdfScreenState();
}

class _TextToPdfScreenState extends State<TextToPdfScreen> {
  final _textController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isProcessing = false;
  File? _outputFile;

  Future<void> _convert() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入文本内容'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final doc = PdfDocument();
      
      final title = _titleController.text.trim().isEmpty ? '文档' : _titleController.text.trim();
      final content = _textController.text;
      final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final pageWidth = 500.0;
      final pageHeight = 700.0;
      final margin = 40.0;
      
      // 分页处理长文本
      double yPosition = margin;
      
      // 添加第一页
      final firstPage = doc.pages.add();
      PdfPage currentPage = firstPage;
      
      // 绘制标题
      currentPage.graphics.drawString(
        title,
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(margin, yPosition, pageWidth - margin * 2, 30),
      );
      yPosition += 40;
      
      // 按行分割文本
      final lines = content.split('\n');
      
      for (final line in lines) {
        // 如果当前页空间不足，添加新页
        if (yPosition > pageHeight - margin) {
          currentPage = doc.pages.add();
          yPosition = margin;
        }
        
        // 绘制文本行
        final textSize = font.measureString(line);
        final lineHeight = textSize.height + 5;
        
        // 如果单行太高，需要换行
        if (yPosition + lineHeight > pageHeight - margin) {
          currentPage = doc.pages.add();
          yPosition = margin;
        }
        
        currentPage.graphics.drawString(
          line,
          font,
          brush: PdfSolidBrush(PdfColor(0, 0, 0)),
          bounds: Rect.fromLTWH(margin, yPosition, pageWidth - margin * 2, lineHeight),
        );
        
        yPosition += lineHeight;
      }

      final bytes = doc.saveSync();
      doc.dispose();

      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File(p.join(outputDir.path, 'text_$timestamp.pdf'));
      await file.writeAsBytes(bytes);

      setState(() => _outputFile = file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF生成成功！保存至: ${file.path}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _shareFile() {
    if (_outputFile != null) {
      SharePlus.instance.share(ShareParams(
        files: [XFile(_outputFile!.path)],
        text: 'PDF Pro - 文本转PDF',
      ));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文本转PDF', style: AppFonts.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: AppStyles.inputDecoration(hintText: '文档标题', prefixIcon: Icons.title),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(minHeight: 200),
              child: TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: AppStyles.inputDecoration(hintText: '输入要转换为PDF的文本内容...'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _convert,
                style: AppStyles.primaryButton,
                child: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('生成PDF'),
              ),
            ),
            if (_outputFile != null) ...[
              const SizedBox(height: 24),
              Text('输出文件', style: AppFonts.h4),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                  title: Text(_outputFile!.path.split('/').last, style: AppFonts.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(icon: const Icon(Icons.share), onPressed: _shareFile),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
