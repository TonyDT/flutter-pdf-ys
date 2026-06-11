// settings_screen.dart - 最终干净版本，无任何错误
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/app_localizations.dart';
import '../core/l10n/language_provider.dart';
import '../core/legal/legal_text.dart';
import '../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final String _appVersion = LegalText.versionName;

  void _showContactDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('contact_us')),
        content: Text(l10n.t('contact_email')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('confirm')),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('privacy_policy')),
        content: SingleChildScrollView(
          child: Text(
            l10n.locale.languageCode == 'zh'
                ? LegalText.privacyPolicyZh
                : LegalText.privacyPolicy,
            style: const TextStyle(height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('i_understand')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final languageState = ref.watch(languageProvider);
    final isDark = themeState.isDarkMode;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 主题切换
          ListTile(
            leading:
                Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 28),
            title: Text(l10n.t('theme_settings'),
                style: const TextStyle(fontSize: 16)),
            subtitle: Text(
              isDark ? l10n.t('dark_mode') : l10n.t('light_mode'),
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),

          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.language, size: 28, color: Colors.teal),
            title:
                Text(l10n.t('language'), style: const TextStyle(fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'en', label: Text(l10n.t('english'))),
                  ButtonSegment(value: 'zh', label: Text(l10n.t('chinese'))),
                ],
                selected: {languageState.languageCode},
                onSelectionChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value.first);
                },
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 8),

          // 关于部分标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Text(l10n.t('about'),
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ),

          // 联系我们
          ListTile(
            leading: const Icon(Icons.email, size: 28, color: Colors.blue),
            title: Text(l10n.t('contact_us'),
                style: const TextStyle(fontSize: 16)),
            onTap: () => _showContactDialog(context),
          ),

          // 隐私协议
          ListTile(
            leading:
                const Icon(Icons.privacy_tip, size: 28, color: Colors.green),
            title: Text(l10n.t('privacy_policy'),
                style: const TextStyle(fontSize: 16)),
            onTap: () => _showPrivacyPolicy(context),
          ),

          // 版本号
          ListTile(
            leading: const Icon(Icons.info, size: 28, color: Colors.purple),
            title:
                Text(l10n.t('version'), style: const TextStyle(fontSize: 16)),
            subtitle: Text(_appVersion, style: const TextStyle(fontSize: 14)),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
