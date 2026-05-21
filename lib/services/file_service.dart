import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class FileService {
  FileService._();

  /// 保存文本到文件
  static Future<File?> saveTextFile(String content, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'ocr_output'));

      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final file = File(p.join(outputDir.path, fileName));
      await file.writeAsString(content);
      return file;
    } catch (e) {
      debugPrint('保存文件失败: $e');
      return null;
    }
  }

  /// 分享文本内容
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject ?? 'OCR识别结果');
  }

  /// 分享文件
  static Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text ?? 'OCR识别结果',
    );
  }

  /// 复制文本到剪贴板
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// 获取OCR输出目录
  static Future<Directory> getOcrOutputDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'ocr_output'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 获取已保存的OCR结果列表
  static Future<List<File>> getSavedOcrResults() async {
    final dir = await getOcrOutputDir();
    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .where((f) => p.extension(f.path).toLowerCase() == '.txt')
        .toList();
  }

  /// 删除OCR结果文件
  static Future<bool> deleteOcrResult(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      debugPrint('删除OCR结果失败: $e');
      return false;
    }
  }
}
