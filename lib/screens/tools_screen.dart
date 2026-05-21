// tools_screen.dart - 单列布局，所有文字完整显示
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      '图片转PDF': const ImagesToPdfScreen(),
      'PDF转长图': const PdfToLongImageScreen(),
      'PDF转图片': const PdfToImagesScreen(),
      '文本转PDF': const TextToPdfScreen(),
      '编辑PDF文本': const EditPdfTextScreen(),
      '添加文字': const AddTextScreen(),
      '添加注释': const AddAnnotationScreen(),
      '添加签名': const AddSignatureScreen(),
      '合并PDF': const MergeScreen(),
      '拆分PDF': const SplitScreen(),
      '压缩PDF': const CompressScreen(),
      '锁定PDF': const EncryptScreen(mode: EncryptMode.encrypt),
      '解锁PDF': const EncryptScreen(mode: EncryptMode.decrypt),
    };

    final page = featurePages[featureName];
    if (page != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$featureName 功能开发中，敬请期待...')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // 监听主题状态，获取当前是否为深色模式
    final isDark = ref.watch(themeProvider).isDarkMode;

    // 完整的工具列表，全部中文显示
    final List<Map<String, dynamic>> tools = [
      {'name': '图片转PDF', 'icon': Icons.image, 'color': Colors.blue, 'description': '将多张图片合并为PDF文件'},
      {'name': 'PDF转图片', 'icon': Icons.photo_library, 'color': Colors.teal, 'description': '将PDF每一页导出为独立图片'},
      {'name': 'PDF转长图', 'icon': Icons.view_column, 'color': Colors.cyan, 'description': '将所有页面拼接为一张长图'},
      {'name': '文本转PDF', 'icon': Icons.text_fields, 'color': Colors.indigo, 'description': '将文本内容生成PDF文档'},
      {'name': '编辑PDF文本', 'icon': Icons.edit_note, 'color': Colors.blueGrey, 'description': '编辑PDF文档中的文本内容'},
      {'name': '添加文字', 'icon': Icons.add_comment, 'color': Colors.lightBlue, 'description': '在PDF页面上添加文字注释'},
      {'name': '添加注释', 'icon': Icons.comment, 'color': Colors.amber, 'description': '在PDF中添加高亮、下划线等注释'},
      {'name': '添加签名', 'icon': Icons.draw, 'color': Colors.deepOrange, 'description': '在PDF文档上添加手写签名'},
      {'name': '合并PDF', 'icon': Icons.merge_type, 'color': Colors.green, 'description': '将多个PDF文件合并为一个文档'},
      {'name': '拆分PDF', 'icon': Icons.call_split, 'color': Colors.lightGreen, 'description': '将一个PDF按页码拆分成多个文件'},
      {'name': '压缩PDF', 'icon': Icons.compress, 'color': Colors.orange, 'description': '压缩PDF文件大小，节省存储空间'},
      {'name': '锁定PDF', 'icon': Icons.lock, 'color': Colors.red, 'description': '给PDF文件添加密码加密保护'},
      {'name': '解锁PDF', 'icon': Icons.lock_open, 'color': Colors.pink, 'description': '移除PDF文档的密码保护'},
    ];

    // 单列布局，每排只有1个，确保所有文字都完整显示
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF工具'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
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
                tool['name'],
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  tool['description'],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _navigateToFeature(context, tool['name']),
            ),
          );
        },
      ),
    );
  }
}