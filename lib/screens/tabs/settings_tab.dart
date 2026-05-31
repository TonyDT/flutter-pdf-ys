import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../privacy_policy_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  void _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.translate('settings'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: AppStyles.cardDecoration(),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.primary,
                  title: l10n.translate('version'),
                  trailing: Text(_version, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                _buildSettingTile(
                  icon: Icons.privacy_tip_outlined,
                  color: AppColors.success,
                  title: l10n.translate('privacy_policy'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                  },
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                _buildSettingTile(
                  icon: Icons.system_update_rounded,
                  color: AppColors.accent,
                  title: l10n.translate('check_update'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.translate('latest_version')),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'GPTesting Assistant',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required Color color, required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
