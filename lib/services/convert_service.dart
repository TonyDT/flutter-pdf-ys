import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart' as pdfx;

class ConvertService {
  ConvertService._();

  /// PDF page to image (PNG) - 使用 pdfx 适配
  static Future<File?> pdfPageToImage(File pdfFile, int pageNumber) async {
    pdfx.PdfDocument? pdfDocument;
    
    try {
      // 使用 pdfx 打开 PDF 文件
      pdfDocument = await pdfx.PdfDocument.openFile(pdfFile.path);
      
      if (pageNumber < 1 || pageNumber > pdfDocument.pagesCount) {
        await pdfDocument.close();
        return null;
      }
      
      // 获取指定页面 (pdfx 的 getPage 索引从 1 开始)
      final page = await pdfDocument.getPage(pageNumber);
      
      // 渲染页面为图片
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: pdfx.PdfPageImageFormat.png,
      );
      
      if (pageImage == null) {
        await page.close();
        await pdfDocument.close();
        return null;
      }
      
      final pngBytes = pageImage.bytes;
      
      await page.close();
      await pdfDocument.close();

      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      final file = File(p.join(outputDir.path, 'page_${pageNumber}_${_timestamp()}.png'));
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint('PDF to image failed: $e');
      try {
        await pdfDocument?.close();
      } catch (_) {}
      return null;
    }
  }

  /// All PDF pages to images
  static Future<List<File>> pdfToImages(File pdfFile) async {
    pdfx.PdfDocument? pdfDocument;
    
    try {
      pdfDocument = await pdfx.PdfDocument.openFile(pdfFile.path);
      final files = <File>[];

      for (int i = 1; i <= pdfDocument.pagesCount; i++) {
        final page = await pdfDocument.getPage(i);
        final pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: pdfx.PdfPageImageFormat.png,
        );
        
        if (pageImage != null) {
          final appDir = await getApplicationDocumentsDirectory();
          final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
          if (!await outputDir.exists()) {
            await outputDir.create(recursive: true);
          }
          final file = File(p.join(outputDir.path, 'page_${i}_${_timestamp()}.png'));
          await file.writeAsBytes(pageImage.bytes);
          files.add(file);
        }
        await page.close();
      }
      
      await pdfDocument.close();
      return files;
    } catch (e) {
      debugPrint('PDF to images failed: $e');
      try {
        await pdfDocument?.close();
      } catch (_) {}
      return [];
    }
  }

  /// Images to PDF
  static Future<File?> imagesToPdf(List<File> imageFiles) async {
    try {
      final doc = syncfusion.PdfDocument();
      for (int i = 0; i < imageFiles.length; i++) {
        final imageBytes = await imageFiles[i].readAsBytes();
        doc.pages.add();
        final page = doc.pages[i];
        final pdfImage = syncfusion.PdfBitmap(imageBytes);
        final size = page.getClientSize();
        page.graphics.drawImage(
          pdfImage,
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
      }
      final bytes = doc.saveSync();
      doc.dispose();
      return await _savePdf(bytes, 'from_images_${_timestamp()}.pdf');
    } catch (e) {
      debugPrint('Images to PDF failed: $e');
      return null;
    }
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

  /// Concatenate multiple images vertically into one long image
  static Future<File?> concatenateImages(List<File> imageFiles) async {
    try {
      if (imageFiles.isEmpty) return null;

      final images = <img.Image>[];
      for (final file in imageFiles) {
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          images.add(decoded);
        }
      }

      if (images.isEmpty) return null;

      int totalHeight = 0;
      int maxWidth = 0;
      for (final image in images) {
        totalHeight += image.height;
        if (image.width > maxWidth) {
          maxWidth = image.width;
        }
      }

      final longImage = img.Image(width: maxWidth, height: totalHeight);
      img.fill(longImage, color: img.ColorRgb8(255, 255, 255));

      int currentY = 0;
      for (final image in images) {
        final xOffset = (maxWidth - image.width) ~/ 2;
        img.compositeImage(longImage, image, dstX: xOffset, dstY: currentY);
        currentY += image.height;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      final file = File(p.join(outputDir.path, 'long_image_${_timestamp()}.png'));
      await file.writeAsBytes(img.encodePng(longImage));
      return file;
    } catch (e) {
      debugPrint('Concatenate images failed: $e');
      return null;
    }
  }
}
