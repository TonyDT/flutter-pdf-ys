import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../services/pdf_service.dart';
import '../services/convert_service.dart';
import 'package:share_plus/share_plus.dart';

class ConvertScreen extends StatefulWidget {
  final String mode;
  const ConvertScreen({super.key, this.mode = 'pdf_to_image'});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  File? _selectedFile;
  List<File> _outputFiles = [];
  bool _isProcessing = false;
  List<File> _selectedImages = [];

  bool get isPdfToImage => widget.mode == 'pdf_to_image';

  Future<void> _pickFile() async {
    if (isPdfToImage) {
      final file = await PdfService.pickPdfFile();
      if (file != null) setState(() => _selectedFile = file);
    } else {
      final files = await PdfService.pickImageFiles();
      if (files != null && files.isNotEmpty) {
        setState(() => _selectedImages = files);
      }
    }
  }

  Future<void> _convert() async {
    setState(() => _isProcessing = true);
    try {
      if (isPdfToImage && _selectedFile != null) {
        final results = await ConvertService.pdfToImages(_selectedFile!);
        setState(() => _outputFiles = results);
      } else if (!isPdfToImage && _selectedImages.isNotEmpty) {
        final result = await ConvertService.imagesToPdf(_selectedImages);
        if (result != null) setState(() => _outputFiles = [result]);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
    if (_outputFiles.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Converted ${_outputFiles.length} file(s)'), backgroundColor: AppColors.success),
      );
    }
  }

  void _shareFile(File file) {
    Share.shareXFiles([XFile(file.path)], text: 'PDF Pro - Converted file');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isPdfToImage ? 'PDF to Image' : 'Image to PDF', style: AppFonts.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: Icon(isPdfToImage ? Icons.picture_as_pdf : Icons.photo_library),
                label: Text(isPdfToImage
                    ? (_selectedFile == null ? 'Select PDF' : _selectedFile!.path.split('/').last)
                    : (_selectedImages.isEmpty ? 'Select Images' : '${_selectedImages.length} image(s) selected')),
                style: AppStyles.outlineButton,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _convert,
                style: AppStyles.primaryButton,
                child: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isPdfToImage ? 'Convert to Images' : 'Convert to PDF'),
              ),
            ),
            if (_outputFiles.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Output Files', style: AppFonts.h4),
              const SizedBox(height: 8),
              ..._outputFiles.map((f) => Card(
                    child: ListTile(
                      leading: Icon(isPdfToImage ? Icons.image : Icons.picture_as_pdf, color: AppColors.primary),
                      title: Text(f.path.split('/').last, style: AppFonts.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(icon: const Icon(Icons.share), onPressed: () => _shareFile(f)),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
