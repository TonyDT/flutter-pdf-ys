import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PdfService {
  PdfService._();

  /// 选择PDF文件
  static Future<File?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// 选择多个PDF文件
  static Future<List<File>?> pickMultiplePdfFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      return result.files.where((f) => f.path != null).map((f) => File(f.path!)).toList();
    }
    return null;
  }

  /// 选择多个图片文件
  static Future<List<File>?> pickImageFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );

    if (result != null) {
      return result.files.where((f) => f.path != null).map((f) => File(f.path!)).toList();
    }
    return null;
  }

  /// 复制PDF到应用目录
  static Future<File> copyToAppDir(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(sourceFile.path);
    final destPath = p.join(appDir.path, 'pdfs', fileName);
    final destFile = File(destPath);

    if (!await destFile.parent.exists()) {
      await destFile.parent.create(recursive: true);
    }

    if (await destFile.exists()) {
      await destFile.delete();
    }

    return await sourceFile.copy(destPath);
  }

  /// 获取已保存的PDF列表
  static Future<List<File>> getSavedPdfs() async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(appDir.path, 'pdfs'));

    if (!await pdfDir.exists()) {
      return [];
    }

    final files = await pdfDir.list().toList();
    return files
        .whereType<File>()
        .where((f) => p.extension(f.path).toLowerCase() == '.pdf')
        .toList();
  }

  /// 删除PDF文件
  static Future<bool> deletePdf(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      debugPrint('删除PDF失败: $e');
      return false;
    }
  }

  /// 获取文件大小
  static Future<String> getFileSize(File file) async {
    final bytes = await file.length();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
