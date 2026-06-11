// tools_screen.dart - 单列布局，所有文字完整显示
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/theme_provider.dart';
import '../core/premium/premium_provider.dart';
import 'premium_screen.dart';
import 'compress_screen.dart';
import 'edit_pdf_text_screen.dart';
import 'encrypt_screen.dart';
import 'images_to_pdf_screen.dart';
import 'merge_screen.dart';
import 'pdf_to_long_image_screen.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  void _navigateToFeature(BuildContext context, String featureId) {
    // 权限检查
    final premiumState = ref.read(premiumProvider);
    if (!premiumState.canAccess(featureId)) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PremiumScreen()),
      );
      return;
    }

    final featurePages = <String, Widget>{
      'image_to_pdf': const ImagesToPdfScreen(),
      'pdf_to_long_image': const PdfToLongImageScreen(),
      'edit_pdf_text': const EditPdfTextScreen(),
      'merge_pdf': const MergeScreen(),
      'compress_pdf': const CompressScreen(),
      'encrypt_pdf': const EncryptScreen(mode: EncryptMode.encrypt),
    };

    final page = featurePages[featureId];
    if (page != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('feature_coming_soon'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听主题状态，获取当前是否为深色模式
    final isDark = ref.watch(themeProvider).isDarkMode;
    final l10n = AppLocalizations.of(context);

    // 完整的工具列表，全部中文显示
    final List<Map<String, dynamic>> tools = [
      {
        'id': 'image_to_pdf',
        'name': l10n.t('image_to_pdf'),
        'icon': Icons.image,
        'color': Colors.blue,
        'description': l10n.t('image_to_pdf_desc')
      },
      {
        'id': 'pdf_to_long_image',
        'name': l10n.t('pdf_to_long_image'),
        'icon': Icons.view_column,
        'color': Colors.cyan,
        'description': l10n.t('pdf_to_long_image_desc')
      },
      {
        'id': 'edit_pdf_text',
        'name': l10n.t('edit_pdf_text'),
        'icon': Icons.edit_note,
        'color': Colors.blueGrey,
        'description': l10n.t('edit_pdf_text_desc')
      },
      {
        'id': 'merge_pdf',
        'name': l10n.t('merge_pdf'),
        'icon': Icons.merge_type,
        'color': Colors.green,
        'description': l10n.t('merge_pdf_desc')
      },
      {
        'id': 'compress_pdf',
        'name': l10n.t('compress_pdf'),
        'icon': Icons.compress,
        'color': Colors.orange,
        'description': l10n.t('compress_pdf_desc')
      },
      {
        'id': 'encrypt_pdf',
        'name': l10n.t('encrypt_pdf'),
        'icon': Icons.lock,
        'color': Colors.red,
        'description': l10n.t('encrypt_pdf_desc')
      },
    ];

    // '编辑PDF文本': const EditPdfTextScreen(),
    // '合并PDF': const MergeScreen(),
    // '压缩PDF': const CompressScreen(),
    // '加密PDF': cons
    // 单列布局，每排只有1个，确保所有文字都完整显示
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('tools')),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
              onTap: () => _navigateToFeature(context, tool['id']),
            ),
          );
        },
      ),
    );
  }
}
