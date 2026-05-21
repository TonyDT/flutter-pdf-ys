import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:image/image.dart' as img;
import 'package:pdf_render/pdf_render.dart' as pdf_render;

class ConvertService {
  ConvertService._();

  /// PDF page to image (PNG) - 使用 pdf_render 包
  static Future<File?> pdfPageToImage(File pdfFile, int pageNumber) async {
    pdf_render.PdfDocument? pdfDocument;
    
    try {
      // 使用 pdf_render 打开 PDF 文件
      pdfDocument = await pdf_render.PdfDocument.openFile(pdfFile.path);
      
      if (pageNumber < 1 || pageNumber > pdfDocument.pageCount) {
        await pdfDocument.dispose();
        return null;
      }
      
      // 获取指定页面
      final page = await pdfDocument.getPage(pageNumber);
      
      // 渲染页面为图片 (使用 2x 缩放以获得更清晰的图片)
      final pageImage = await page.render(
        width: (page.width * 2).toInt(),
        height: (page.height * 2).toInt(),
      );
      
      // 将 PdfPageImage 转换为 PNG 字节
      final pngBytes = await _convertPageImageToPng(pageImage);
      
      await pdfDocument.dispose();

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
      // 清理资源
      try {
        await pdfDocument?.dispose();
      } catch (_) {}
      return null;
    }
  }

  /// All PDF pages to images - 使用 pdf_render 包
  static Future<List<File>> pdfToImages(File pdfFile) async {
    pdf_render.PdfDocument? pdfDocument;
    
    try {
      // 使用 pdf_render 打开 PDF 文件
      pdfDocument = await pdf_render.PdfDocument.openFile(pdfFile.path);
      final files = <File>[];

      for (int i = 1; i <= pdfDocument.pageCount; i++) {
        // 获取页面
        final page = await pdfDocument.getPage(i);
        
        // 渲染页面为图片 (使用 2x 缩放以获得更清晰的图片)
        final pageImage = await page.render(
          width: (page.width * 2).toInt(),
          height: (page.height * 2).toInt(),
        );
        
        // 将 PdfPageImage 转换为 PNG 字节
        final pngBytes = await _convertPageImageToPng(pageImage);

        final appDir = await getApplicationDocumentsDirectory();
        final outputDir = Directory(p.join(appDir.path, 'pdf_output'));
        if (!await outputDir.exists()) {
          await outputDir.create(recursive: true);
        }
        final file = File(p.join(outputDir.path, 'page_${i}_${_timestamp()}.png'));
        await file.writeAsBytes(pngBytes);
        files.add(file);
      }
      
      await pdfDocument.dispose();
      return files;
    } catch (e) {
      debugPrint('PDF to images failed: $e');
      // 清理资源
      try {
        await pdfDocument?.dispose();
      } catch (_) {}
      return [];
    }
  }

  /// 将 PdfPageImage 转换为 PNG 字节
  static Future<Uint8List> _convertPageImageToPng(pdf_render.PdfPageImage pageImage) async {
    // 获取像素数据 (Uint8List 格式，每4个字节表示一个像素的 RGBA)
    final Uint8List pixels = pageImage.pixels;
    final int width = pageImage.width;
    final int height = pageImage.height;
    
    // 使用 dart:ui 创建 Image 并编码为 PNG
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;
    
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Images to PDF
  static Future<File?> imagesToPdf(List<File> imageFiles) async {
    try {
      final doc = syncfusion.PdfDocument();
      for (int i = 0; i < imageFiles.length; i++) {
        final imageBytes = await imageFiles[i].readAsBytes();
        // 第一页需要手动添加，后续页面通过 add() 添加
        if (i == 0) {
          doc.pages.add();
        }
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

      // Decode all images
      final images = <img.Image>[];
      for (final file in imageFiles) {
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          images.add(decoded);
        }
      }

      if (images.isEmpty) return null;

      // Calculate total height and max width
      int totalHeight = 0;
      int maxWidth = 0;
      for (final image in images) {
        totalHeight += image.height;
        if (image.width > maxWidth) {
          maxWidth = image.width;
        }
      }

      // Create a new image with the calculated dimensions
      final longImage = img.Image(width: maxWidth, height: totalHeight);
      img.fill(longImage, color: img.ColorRgb8(255, 255, 255));

      // Draw each image onto the long image
      int currentY = 0;
      for (final image in images) {
        // Center the image horizontally if widths don't match
        final xOffset = (maxWidth - image.width) ~/ 2;
        img.compositeImage(longImage, image, dstX: xOffset, dstY: currentY);
        currentY += image.height;
      }

      // Save the long image
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
