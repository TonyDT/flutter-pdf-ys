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

class AddTextScreen extends StatefulWidget {
  const AddTextScreen({super.key});

  @override
  State<AddTextScreen> createState() => _AddTextScreenState();
}

class _AddTextScreenState extends State<AddTextScreen> {
  File? _selectedFile;
  int _totalPages = 0;
  bool _isProcessing = false;
  final _textController = TextEditingController();
  final _pageController = TextEditingController(text: '1');
  double _fontSize = 16;
  Color _textColor = Colors.black;
  double _xPosition = 50;
  double _yPosition = 50;

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

  Future<void> _addText() async {
    if (_selectedFile == null || _textController.text.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _selectedFile!.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      final pageNum = int.tryParse(_pageController.text) ?? 1;
      if (pageNum >= 1 && pageNum <= doc.pages.count) {
        final page = doc.pages[pageNum - 1];
        final font = PdfStandardFont(PdfFontFamily.helvetica, _fontSize);
        page.graphics.drawString(
          _textController.text,
          font,
          brush: PdfSolidBrush(PdfColor(
            (_textColor.r * 255).toInt(),
            (_textColor.g * 255).toInt(),
            (_textColor.b * 255).toInt(),
          )),
          bounds: Rect.fromLTWH(_xPosition, _yPosition, 400.0, _fontSize * 2),
        );
      }
      final newBytes = doc.saveSync();
      doc.dispose();

      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File(p.join(outputDir.path, 'added_text_$timestamp.pdf'));
      await file.writeAsBytes(newBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文字添加成功！'), backgroundColor: AppColors.success),
        );
        SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)],
          text: 'PDF Pro - 添加文字',
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加文字失败: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加文字', style: AppFonts.h3)),
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
                      decoration: AppStyles.inputDecoration(hintText: '添加文字的页码', prefixIcon: Icons.filter_1),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      decoration: AppStyles.inputDecoration(hintText: '输入要添加的文字', prefixIcon: Icons.text_fields),
                    ),
                    const SizedBox(height: 16),
                    Text('字体大小: ${_fontSize.toInt()}', style: AppFonts.bodyMedium),
                    Slider(
                      value: _fontSize,
                      min: 8,
                      max: 72,
                      divisions: 64,
                      label: _fontSize.toInt().toString(),
                      onChanged: (v) => setState(() => _fontSize = v),
                    ),
                    const SizedBox(height: 8),
                    Text('X 位置', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    Slider(
                      value: _xPosition,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      onChanged: (v) => setState(() => _xPosition = v),
                    ),
                    Text('Y 位置', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    Slider(
                      value: _yPosition,
                      min: 0,
                      max: 700,
                      divisions: 70,
                      onChanged: (v) => setState(() => _yPosition = v),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('文字颜色', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () async {
                            final color = await showDialog<Color>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('选择颜色'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(color: _textColor, onColorChanged: (c) => Navigator.pop(ctx, c)),
                                ),
                              ),
                            );
                            if (color != null) setState(() => _textColor = color);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _textColor,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _addText,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('添加文字'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({super.key, required this.color, required this.onColorChanged});

  static const _colors = [
    Colors.black, Colors.white, Colors.red, Colors.pink, Colors.purple,
    Colors.deepPurple, Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow,
    Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown, Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colors.map((c) => GestureDetector(
        onTap: () => onColorChanged(c),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c,
            border: Border.all(color: c == color ? AppColors.primary : AppColors.border, width: c == color ? 3 : 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      )).toList(),
    );
  }
}
