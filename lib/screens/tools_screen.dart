// tools_screen.dart - 单列布局，所有文字完整显示
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/theme_provider.dart';
import 'add_annotation_screen.dart';
import 'add_signature_screen.dart';
import 'add_text_screen.dart';
import 'compress_screen.dart';
import 'edit_pdf_text_screen.dart';
import 'encrypt_screen.dart';
import 'images_to_pdf_screen.dart';
import 'merge_screen.dart';
import 'pdf_to_images_screen.dart';
import 'pdf_to_long_image_screen.dart';
import 'split_screen.dart';
import 'text_to_pdf_screen.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  void _navigateToFeature(BuildContext context, String featureName) {
    final featurePages = <String, Widget>{
      'Images to PDF': const ImagesToPdfScreen(),
      'PDF to Images': const PdfToImagesScreen(),
      'PDF to Long Image': const PdfToLongImageScreen(),
      'Text to PDF': const TextToPdfScreen(),
      'Edit PDF Text': const EditPdfTextScreen(),
      'Add Text': const AddTextScreen(),
      'Add Annotation': const AddAnnotationScreen(),
      'Add Signature': const AddSignatureScreen(),
      'Merge PDF': const MergeScreen(),
      'Split PDF': const SplitScreen(),
      'Compress PDF': const CompressScreen(),
      'Encrypt PDF': const EncryptScreen(mode: EncryptMode.encrypt),
      'Decrypt PDF': const EncryptScreen(mode: EncryptMode.decrypt),
    };

    final page = featurePages[featureName];
    if (page != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$featureName ${l10n.comingSoon}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 监听主题状态，获取当前是否为深色模式
    final isDark = ref.watch(themeProvider).isDarkMode;

    // 工具列表 - 使用英文key，根据语言显示对应文本
    final List<Map<String, dynamic>> tools = [
      {
        'key': 'imagesToPDF',
        'name_en': 'Images to PDF',
        'name_zh': '图片转PDF',
        'icon': Icons.image,
        'color': Colors.blue,
        'desc_en': 'Merge multiple images into a PDF file',
        'desc_zh': '将多张图片合并为PDF文件',
      },
      {
        'key': 'pdfToImages',
        'name_en': 'PDF to Images',
        'name_zh': 'PDF转图片',
        'icon': Icons.photo_library,
        'color': Colors.teal,
        'desc_en': 'Export each page of PDF as separate images',
        'desc_zh': '将PDF每一页导出为独立图片',
      },
      {
        'key': 'pdfToLongImage',
        'name_en': 'PDF to Long Image',
        'name_zh': 'PDF转长图',
        'icon': Icons.view_column,
        'color': Colors.cyan,
        'desc_en': 'Stitch all pages into one long image',
        'desc_zh': '将所有页面拼接为一张长图',
      },
      {
        'key': 'textToPdf',
        'name_en': 'Text to PDF',
        'name_zh': '文本转PDF',
        'icon': Icons.text_fields,
        'color': Colors.indigo,
        'desc_en': 'Generate PDF document from text content',
        'desc_zh': '将文本内容生成PDF文档',
      },
      {
        'key': 'editPdfText',
        'name_en': 'Edit PDF Text',
        'name_zh': '编辑PDF文本',
        'icon': Icons.edit_note,
        'color': Colors.blueGrey,
        'desc_en': 'Edit text content in PDF document',
        'desc_zh': '编辑PDF文档中的文本内容',
      },
      {
        'key': 'addText',
        'name_en': 'Add Text',
        'name_zh': '添加文字',
        'icon': Icons.add_comment,
        'color': Colors.lightBlue,
        'desc_en': 'Add text annotations on PDF pages',
        'desc_zh': '在PDF页面上添加文字注释',
      },
      {
        'key': 'addAnnotation',
        'name_en': 'Add Annotation',
        'name_zh': '添加注释',
        'icon': Icons.comment,
        'color': Colors.amber,
        'desc_en': 'Add highlights, underlines and other annotations',
        'desc_zh': '在PDF中添加高亮、下划线等注释',
      },
      {
        'key': 'addSignature',
        'name_en': 'Add Signature',
        'name_zh': '添加签名',
        'icon': Icons.draw,
        'color': Colors.deepOrange,
        'desc_en': 'Add handwritten signature to PDF document',
        'desc_zh': '在PDF文档上添加手写签名',
      },
      {
        'key': 'mergePdf',
        'name_en': 'Merge PDF',
        'name_zh': '合并PDF',
        'icon': Icons.merge_type,
        'color': Colors.green,
        'desc_en': 'Merge multiple PDF files into one document',
        'desc_zh': '将多个PDF文件合并为一个文档',
      },
      {
        'key': 'splitPdf',
        'name_en': 'Split PDF',
        'name_zh': '拆分PDF',
        'icon': Icons.call_split,
        'color': Colors.lightGreen,
        'desc_en': 'Split a PDF into multiple files by page number',
        'desc_zh': '将一个PDF按页码拆分成多个文件',
      },
      {
        'key': 'compressPdf',
        'name_en': 'Compress PDF',
        'name_zh': '压缩PDF',
        'icon': Icons.compress,
        'color': Colors.orange,
        'desc_en': 'Compress PDF file size to save storage space',
        'desc_zh': '压缩PDF文件大小，节省存储空间',
      },
      {
        'key': 'encryptPdf',
        'name_en': 'Encrypt PDF',
        'name_zh': '锁定PDF',
        'icon': Icons.lock,
        'color': Colors.red,
        'desc_en': 'Add password encryption to PDF file',
        'desc_zh': '给PDF文件添加密码加密保护',
      },
      {
        'key': 'decryptPdf',
        'name_en': 'Decrypt PDF',
        'name_zh': '解锁PDF',
        'icon': Icons.lock_open,
        'color': Colors.pink,
        'desc_en': 'Remove password protection from PDF document',
        'desc_zh': '移除PDF文档的密码保护',
      },
    ];

    // 单列布局，每排只有1个，确保所有文字都完整显示
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pdfTools),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          final isChinese = l10n.isChinese;
          final name = isChinese ? tool['name_zh'] : tool['name_en'];
          final desc = isChinese ? tool['desc_zh'] : tool['desc_en'];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tool['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tool['icon'], color: tool['color'], size: 32),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _navigateToFeature(context, tool['name_en']),
            ),
          );
        },
      ),
    );
  }
}