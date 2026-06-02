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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                isZh ? '更新日期：2024年12月14日' : 'Updated: Dec 14, 2024',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              isZh ? '1. 引言' : '1. Introduction',
              isZh 
                ? '我们高度重视您的隐私。本政策旨在说明 GPTesting 助手如何处理您的数据。GPTesting 是一款离线优先的本地工具，旨在协助开发者进行 Google Play 封闭测试。' 
                : 'We value your privacy. This policy explains how GPTesting Assistant handles your data. GPTesting is an offline-first tool designed to help developers manage Google Play closed testing.',
            ),
            _buildSection(
              isZh ? '2. 信息收集与使用' : '2. Information Collection',
              isZh 
                ? '• 应用程序列表：本应用需要扫描您设备上安装的应用程序包名和名称。此信息仅用于在 App 内展示并协助您记录测试进度，绝不会离开您的设备。\n'
                  '• 存储数据：所有的测试记录和应用偏好均存储在您手机本地的 Hive 数据库中。\n'
                  '• 无个人数据收集：我们不收集您的姓名、电话、邮件或任何设备唯一识别码（如 IMEI）。' 
                : '• App List: This app scans package names and names of installed applications. This information is only used locally to display and track testing progress.\n'
                  '• Local Storage: All testing records are stored in a local Hive database on your device.\n'
                  '• No PII: We do not collect names, phone numbers, emails, or unique device identifiers like IMEI.',
            ),
            _buildSection(
              isZh ? '3. 核心权限说明' : '3. Permissions',
              isZh 
                ? '• QUERY_ALL_PACKAGES：这是核心权限，用于扫描待测应用。根据 Google Play 政策，此权限仅用于实现应用的核心功能（封闭测试追踪）。\n'
                  '• 照片与视频权限：仅用于将生成的打卡报告保存到您的系统相册。\n'
                  '• 网络访问：仅用于异步核对应用是否在商店公开发布，不涉及数据上传。' 
                : '• QUERY_ALL_PACKAGES: Core permission to scan apps for testing. In compliance with Google Play policy, this is used only for core functionality.\n'
                  '• Photos & Videos: Only used to save generated report images to your gallery.\n'
                  '• Network: Only used to verify if an app is publicly available on the Play Store.',
            ),
            _buildSection(
              isZh ? '4. 数据保留与删除' : '4. Data Retention',
              isZh 
                ? '您可以随时通过“停止测试”功能删除特定的测试记录。当您卸载本应用时，所有存储在本地的数据将由系统自动清除。' 
                : 'You can delete testing records via the "Stop Test" feature. When you uninstall the app, all local data is automatically cleared by the system.',
            ),
            _buildSection(
              isZh ? '5. 儿童隐私' : '5. Children\'s Privacy',
              isZh 
                ? '本应用不针对 13 岁以下的儿童，且不会知情收集其任何信息。' 
                : 'This app is not directed at children under 13 and we do not knowingly collect information from them.',
            ),
            _buildSection(
              isZh ? '6. 联系我们' : '6. Contact Us',
              isZh 
                ? '如有任何疑问，请联系：support@gptesting.app' 
                : 'For questions, contact: support@gptesting.app',
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                '© 2024 GPTesting Assistant Team',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
      ],
    );
  }
}
