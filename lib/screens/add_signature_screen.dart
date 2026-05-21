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

class AddSignatureScreen extends StatefulWidget {
  const AddSignatureScreen({super.key});

  @override
  State<AddSignatureScreen> createState() => _AddSignatureScreenState();
}

class _AddSignatureScreenState extends State<AddSignatureScreen> {
  File? _selectedFile;
  int _totalPages = 0;
  bool _isProcessing = false;
  final _pageController = TextEditingController(text: '1');
  final List<Offset?> _signaturePoints = [];
  double _signatureX = 350;
  double _signatureY = 650;
  Color _signatureColor = Colors.black;
  double _strokeWidth = 2.0;

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

  void _clearSignature() {
    setState(() => _signaturePoints.clear());
  }

  Future<void> _addSignature() async {
    if (_selectedFile == null || _signaturePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择PDF并绘制签名'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final bytes = await _selectedFile!.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      final pageNum = int.tryParse(_pageController.text) ?? 1;

      if (pageNum >= 1 && pageNum <= doc.pages.count) {
        final page = doc.pages[pageNum - 1];

        // 使用 PdfPen 在页面上绘制签名路径
        final pen = PdfPen(
          PdfColor(_signatureColor.red.toInt(), _signatureColor.green.toInt(), _signatureColor.blue.toInt()),
          width: _strokeWidth,
        );

        // 将签名点绘制到PDF页面上
        for (int i = 0; i < _signaturePoints.length - 1; i++) {
          final current = _signaturePoints[i];
          final next = _signaturePoints[i + 1];
          if (current != null && next != null) {
            page.graphics.drawLine(
              pen,
              Offset(current.dx * 0.5 + _signatureX, current.dy * 0.3 + _signatureY),
              Offset(next.dx * 0.5 + _signatureX, next.dy * 0.3 + _signatureY),
            );
          }
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
      final file = File(p.join(outputDir.path, 'signed_${timestamp}.pdf'));
      await file.writeAsBytes(newBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('签名添加成功！'), backgroundColor: AppColors.success),
        );
        Share.shareXFiles([XFile(file.path)], text: 'PDF Pro - 签名PDF');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加签名失败: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
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
      appBar: AppBar(title: const Text('添加签名', style: AppFonts.h3)),
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
                      decoration: AppStyles.inputDecoration(hintText: '添加签名的页码', prefixIcon: Icons.filter_1),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('签名位置 X', style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                        Expanded(
                          child: Slider(
                            value: _signatureX,
                            min: 0,
                            max: 500,
                            divisions: 50,
                            onChanged: (v) => setState(() => _signatureX = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('签名位置 Y', style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                        Expanded(
                          child: Slider(
                            value: _signatureY,
                            min: 0,
                            max: 700,
                            divisions: 70,
                            onChanged: (v) => setState(() => _signatureY = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('在下方区域绘制签名', style: AppFonts.h4),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _signaturePoints.add(details.localPosition);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _signaturePoints.add(details.localPosition);
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _signaturePoints.add(null);
                    });
                  },
                  child: CustomPaint(
                    painter: SignaturePainter(
                      points: _signaturePoints,
                      color: _signatureColor,
                      strokeWidth: _strokeWidth,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('笔宽: '),
                      SizedBox(
                        width: 120,
                        child: Slider(
                          value: _strokeWidth,
                          min: 1,
                          max: 6,
                          divisions: 5,
                          onChanged: (v) => setState(() => _strokeWidth = v),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.clear),
                    label: const Text('清除'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _addSignature,
                  style: AppStyles.primaryButton,
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('添加签名'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  SignaturePainter({required this.points, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
