// settings_screen.dart - 最终干净版本，无任何错误
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final String _appVersion = '1.0.0+1';

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('联系我们'),
        content: const Text('如有任何问题或建议，请发送邮件至：support@pdfreader.com\n\n我们会尽快回复您的反馈。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私协议'),
        content: const SingleChildScrollView(
          child: Text(
            '隐私协议\n\n'
                '本应用尊重并保护所有用户的隐私权益。请您仔细阅读以下内容：\n\n'
                '🔒 数据本地化\n'
                '本应用所有功能均完全离线运行，您的所有PDF文件、注释、书签等数据仅保存在您的设备本地。\n\n'
                '📁 权限说明\n'
                '应用仅需要存储权限，用于读取您设备上的PDF文件，并保存您对文件的修改。除此之外不会访问任何其他数据。\n\n'
                '🚫 无数据收集\n'
                '我们不会上传、收集或共享您的任何个人信息和文件数据到任何服务器。\n\n'
                '🗑️ 数据删除\n'
                '您随时可以卸载本应用，卸载后所有应用相关数据都会从您的设备上完全清除。\n\n'
                '最后更新：2024年1月',
            style: TextStyle(height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('我已知晓'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 主题切换
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 28),
            title: const Text('主题设置', style: TextStyle(fontSize: 16)),
            subtitle: Text(
              isDark ? '深色模式' : '浅色模式',
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),

          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 8),

          // 关于部分标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Text('关于', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          ),

          // 联系我们
          ListTile(
            leading: const Icon(Icons.email, size: 28, color: Colors.blue),
            title: const Text('联系我们', style: TextStyle(fontSize: 16)),
            onTap: () => _showContactDialog(context),
          ),

          // 隐私协议
          ListTile(
            leading: const Icon(Icons.privacy_tip, size: 28, color: Colors.green),
            title: const Text('隐私协议', style: TextStyle(fontSize: 16)),
            onTap: () => _showPrivacyPolicy(context),
          ),

          // 版本号
          ListTile(
            leading: const Icon(Icons.info, size: 28, color: Colors.purple),
            title: const Text('版本号', style: TextStyle(fontSize: 16)),
            subtitle: Text(_appVersion, style: const TextStyle(fontSize: 14)),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}