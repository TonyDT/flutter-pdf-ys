import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfEditService {
  PdfEditService._();

  /// Merge multiple PDFs into one
  static Future<File?> mergePdfs(List<File> pdfFiles) async {
    try {
      final doc = PdfDocument();
      for (final file in pdfFiles) {
        final bytes = await file.readAsBytes();
        final srcDoc = PdfDocument(inputBytes: bytes);
        for (int i = 0; i < srcDoc.pages.count; i++) {
          doc.pages.add();
          final srcPage = srcDoc.pages[i];
          final destPage = doc.pages[doc.pages.count - 1];
          destPage.graphics.drawPdfTemplate(
            srcPage.createTemplate(),
            Offset.zero,
            srcPage.size,
          );
        }
        srcDoc.dispose();
      }
      final bytes = doc.saveSync();
      doc.dispose();
      return await _savePdf(bytes, 'merged_${_timestamp()}.pdf');
    } catch (e) {
      debugPrint('Merge PDF failed: $e');
      return null;
    }
  }

  /// Split PDF by page ranges (e.g., "1-3,5,7-9")
  static Future<List<File>> splitPdf(File pdfFile, String pageRanges) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final srcDoc = PdfDocument(inputBytes: bytes);
      final totalPages = srcDoc.pages.count;
      final pageSets = _parsePageRanges(pageRanges, totalPages);
      final result = <File>[];

      for (final pages in pageSets) {
        final newDoc = PdfDocument();
        for (final pageNum in pages) {
          newDoc.pages.add();
          final srcPage = srcDoc.pages[pageNum - 1];
          final destPage = newDoc.pages[newDoc.pages.count - 1];
          destPage.graphics.drawPdfTemplate(
            srcPage.createTemplate(),
            Offset.zero,
            srcPage.size,
          );
        }
        final newBytes = newDoc.saveSync();
        newDoc.dispose();
        final file = await _savePdf(newBytes, 'split_${pages.first}-${pages.last}_${_timestamp()}.pdf');
        if (file != null) result.add(file);
      }
      srcDoc.dispose();
      return result;
    } catch (e) {
      debugPrint('Split PDF failed: $e');
      return [];
    }
  }

  /// Delete specific pages from PDF
  static Future<File?> deletePages(File pdfFile, List<int> pageNumbers) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      // Sort descending to remove from end first
      final sorted = pageNumbers.toList()..sort((a, b) => b.compareTo(a));
      for (final pageNum in sorted) {
        if (pageNum >= 1 && pageNum <= doc.pages.count) {
          doc.pages.removeAt(pageNum - 1);
        }
      }
      final newBytes = doc.saveSync();
      doc.dispose();
      return await _savePdf(newBytes, 'edited_${_timestamp()}.pdf');
    } catch (e) {
      debugPrint('Delete pages failed: $e');
      return null;
    }
  }

  /// Reorder pages in PDF
  static Future<File?> reorderPages(File pdfFile, List<int> newOrder) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final srcDoc = PdfDocument(inputBytes: bytes);
      final newDoc = PdfDocument();
      for (final pageNum in newOrder) {
        if (pageNum >= 1 && pageNum <= srcDoc.pages.count) {
          newDoc.pages.add();
          final srcPage = srcDoc.pages[pageNum - 1];
          final destPage = newDoc.pages[newDoc.pages.count - 1];
          destPage.graphics.drawPdfTemplate(
            srcPage.createTemplate(),
            Offset.zero,
            srcPage.size,
          );
        }
      }
      final newBytes = newDoc.saveSync();
      newDoc.dispose();
      srcDoc.dispose();
      return await _savePdf(newBytes, 'reordered_${_timestamp()}.pdf');
    } catch (e) {
      debugPrint('Reorder pages failed: $e');
      return null;
    }
  }

  /// Compress PDF with quality level (0=low, 1=medium, 2=high compression)
  static Future<File?> compressPdf(File pdfFile, int level) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      doc.compressionLevel = _getCompressionLevel(level);
      final newBytes = doc.saveSync();
      doc.dispose();
      final suffix = ['low', 'medium', 'high'][level.clamp(0, 2)];
      return await _savePdf(newBytes, 'compressed_${suffix}_${_timestamp()}.pdf');
    } catch (e) {
      debugPrint('Compress PDF failed: $e');
      return null;
    }
  }

  /// Encrypt PDF with password
  static Future<File?> encryptPdf(File pdfFile, String password) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      doc.security.userPassword = password;
      doc.security.ownerPassword = password;
      doc.security.permissions.addAll([
        PdfPermissionsFlags.print,
        PdfPermissionsFlags.copyContent,
      ]);
      final newBytes = doc.saveSync();
      doc.dispose();
      return await _savePdf(newBytes, 'encrypted_${_timestamp()}.pdf');
    } catch (e) {
      debugPrint('Encrypt PDF failed: $e');
      return null;
    }
  }

  /// Decrypt PDF (remove password protection)
  static Future<File?> decryptPdf(File pdfFile, String password) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      // 使用密码打开加密的PDF
      final doc = PdfDocument(inputBytes: bytes, password: password);
      
      // 移除密码保护
      doc.security.userPassword = '';
      doc.security.ownerPassword = '';
      
      final newBytes = doc.saveSync();
      doc.dispose();
      return await _savePdf(newBytes, 'decrypted_${_timestamp()}.pdf');
    } catch (e) {
      debugPrint('Decrypt PDF failed: $e');
      return null;
    }
  }

  /// Extract text from a specific page
  static Future<String> extractText(File pdfFile, int pageNumber) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      if (pageNumber < 1 || pageNumber > doc.pages.count) {
        doc.dispose();
        return '';
      }
      final extractor = PdfTextExtractor(doc);
      final text = extractor.extractText(startPageIndex: pageNumber - 1, endPageIndex: pageNumber - 1);
      doc.dispose();
      return text;
    } catch (e) {
      debugPrint('Extract text failed: $e');
      return '';
    }
  }

  /// Get page count
  static Future<int> getPageCount(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      final count = doc.pages.count;
      doc.dispose();
      return count;
    } catch (e) {
      debugPrint('Get page count failed: $e');
      return 0;
    }
  }

  static PdfCompressionLevel _getCompressionLevel(int level) {
    switch (level) {
      case 0: return PdfCompressionLevel.normal;
      case 1: return PdfCompressionLevel.bestSpeed;
      case 2: return PdfCompressionLevel.aboveNormal;
      default: return PdfCompressionLevel.normal;
    }
  }

  static List<List<int>> _parsePageRanges(String input, int totalPages) {
    final result = <List<int>>[];
    final parts = input.split(',');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.contains('-')) {
        final range = trimmed.split('-');
        final start = int.tryParse(range[0].trim()) ?? 1;
        final end = int.tryParse(range[1].trim()) ?? totalPages;
        result.add(List.generate(end - start + 1, (i) => start + i)
            .where((p) => p >= 1 && p <= totalPages).toList());
      } else {
        final num = int.tryParse(trimmed);
        if (num != null && num >= 1 && num <= totalPages) {
          result.add([num]);
        }
      }
    }
    return result.where((list) => list.isNotEmpty).toList();
  }

  static Future<File?> _savePdf(List<int> bytes, String fileName) async {
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

  static String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
}
