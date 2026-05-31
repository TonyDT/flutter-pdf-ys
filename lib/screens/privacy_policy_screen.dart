import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isZh = l10n.locale.languageCode == 'zh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.translate('privacy_policy'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? 'GPTesting 隐私政策' : 'GPTesting Privacy Policy',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              isZh ? '生效日期：2024年1月1日' : 'Effective Date: Jan 1, 2024',
              style: const TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildSection(
              isZh ? '1. 我们收集的信息' : '1. Information We Collect',
              isZh 
                ? 'GPTesting 是一款纯本地运行的工具软件。我们不会收集您的任何个人身份信息。数据仅存储在您的本地设备上。' 
                : 'GPTesting is a local-only tool. We do not collect any personally identifiable information (PII). Your data stays on your device.',
            ),
            _buildSection(
              isZh ? '2. 权限使用说明' : '2. Permissions',
              isZh 
                ? '• QUERY_ALL_PACKAGES: 扫描已安装应用进行测试。\n• 存储权限: 保存报告到相册。\n• 联网权限: 仅用于检查商店状态。' 
                : '• QUERY_ALL_PACKAGES: To scan installed apps for testing.\n• Storage: To save reports to your gallery.\n• Internet: To check Google Play Store status.',
            ),
            _buildSection(
              isZh ? '3. 数据安全' : '3. Data Security',
              isZh 
                ? '所有数据在您卸载应用时会同步删除。我们没有中央服务器。' 
                : 'All data is deleted when you uninstall the app. We have no central servers.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
      ],
    );
  }
}
