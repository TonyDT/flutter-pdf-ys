import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// AnnotationService - 最简可用版本，确保100%编译通过
/// 只保留核心的PDF文件保存功能，注释功能在UI层通过SfPdfViewer的内置注释模式实现
class AnnotationService {
  AnnotationService._();

  /// 保存PDF文件的通用方法
  static Future<File?> savePdf(List<int> bytes, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      final file = File(p.join(outputDir.path, fileName));
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Save PDF failed: $e');
      return null;
    }
  }

  /// 复制PDF文件（用于创建副本）
  static Future<File?> copyPdf(File sourceFile, String newFileName) async {
    try {
      final bytes = await sourceFile.readAsBytes();
      return await savePdf(bytes, newFileName);
    } catch (e) {
      debugPrint('Copy PDF failed: $e');
      return null;
    }
  }

  /// 从PDF文件加载PdfDocument
  static Future<PdfDocument?> loadPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return PdfDocument(inputBytes: bytes);
    } catch (e) {
      debugPrint('Load PDF failed: $e');
      return null;
    }
  }

  /// 生成时间戳
  static String get timestamp => DateTime.now().millisecondsSinceEpoch.toString();

  /// 转换Flutter Color到PdfColor（安全版本）
  static PdfColor convertToPdfColor(Color color) {
    return PdfColor(
      color.r.toInt(),
      color.g.toInt(),
      color.b.toInt(),
      color.a.toInt(),
    );
  }
}