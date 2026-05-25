import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/constants/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../core/premium/premium_provider.dart';
import '../core/theme/theme_provider.dart';
import 'premium_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (e) {
      debugPrint('Error getting app version: $e');
      if (mounted) {
        setState(() {
          _appVersion = '1.0.0+1';
        });
      }
    }
  }

  void _showContactDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactUs),
        content: Text(l10n.contactEmail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.confirm),
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
        title: Text(l10n.privacyTitle),
        content: SingleChildScrollView(
          child: Text(
            l10n.privacyContent,
            style: const TextStyle(height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.iKnow),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLocalizations.supportedLocales.map((locale) {
            final isSelected = ref.read(localeProvider).languageCode == locale.languageCode;
            final languageName = AppLocalizations.languageNames[locale.languageCode] ?? locale.languageCode;
            return ListTile(
              title: Text(languageName),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final premiumState = ref.watch(premiumProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Premium 状态卡片
          if (!premiumState.isPremium)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.premiumGold, AppColors.premiumGoldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.upgradeToPro, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(l10n.unlockAllFeatures, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PremiumScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.premiumGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(l10n.upgradeNow, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.proActivated, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 14)),
                          if (premiumState.expiryDate != null)
                            Text(
                              '${l10n.expiryDate}: ${premiumState.expiryDate!.year}-${premiumState.expiryDate!.month.toString().padLeft(2, '0')}-${premiumState.expiryDate!.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),

          // 主题切换
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 28),
            title: Text(l10n.themeSettings),
            subtitle: Text(
              isDark ? l10n.darkMode : l10n.lightMode,
            ),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),

          const Divider(height: 1, thickness: 1),

          // 语言切换
          ListTile(
            leading: const Icon(Icons.language, size: 28, color: Colors.orange),
            title: Text(l10n.language),
            subtitle: Text(AppLocalizations.languageNames[currentLocale.languageCode] ?? 'English'),
            onTap: () => _showLanguageDialog(),
          ),

          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 8),

          // 关于部分标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.about,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // 联系我们
          ListTile(
            leading: const Icon(Icons.email, size: 28, color: Colors.blue),
            title: Text(l10n.contactUs),
            onTap: () => _showContactDialog(context),
          ),

          // 隐私协议
          ListTile(
            leading: const Icon(Icons.privacy_tip, size: 28, color: Colors.green),
            title: Text(l10n.privacyPolicy),
            onTap: () => _showPrivacyPolicy(context),
          ),

          // 版本号
          ListTile(
            leading: const Icon(Icons.info, size: 28, color: Colors.purple),
            title: Text(l10n.version),
            subtitle: Text(_appVersion.isEmpty ? l10n.loading : _appVersion),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
