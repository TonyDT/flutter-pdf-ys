import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/l10n/app_localizations.dart';
import '../core/legal/legal_text.dart';
import '../core/premium/premium_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isShowingBillingError = false;

  Future<void> _purchasePlan() async {
    final started = await ref.read(premiumProvider.notifier).purchasePlan();
    final message = ref.read(premiumProvider).errorMessage;
    if (!started && message == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .t('google_play_product_unavailable')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLegalDialog(String title, String content) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(height: 1.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('confirm')),
          ),
        ],
      ),
    );
  }

  Future<void> _showBillingErrorDialog(String message) async {
    if (_isShowingBillingError || !mounted) return;
    _isShowingBillingError = true;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('purchase_issue')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(message, style: const TextStyle(height: 1.45)),
              const SizedBox(height: 12),
              Text(
                l10n.t('billing_help'),
                style:
                    AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('confirm')),
          ),
        ],
      ),
    );
    _isShowingBillingError = false;
  }

  Future<void> _restorePurchases() async {
    await ref.read(premiumProvider.notifier).restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);
    final l10n = AppLocalizations.of(context);
    ref.listen<PremiumState>(premiumProvider, (previous, next) {
      final message = next.errorMessage;
      if (message == null || message == previous?.errorMessage || !mounted) {
        return;
      }
      _showBillingErrorDialog(message);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('upgrade_pro'), style: AppFonts.h3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // 皇冠图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.premiumGold,
                            AppColors.premiumGoldDark
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  AppColors.premiumGold.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.workspace_premium,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.t('pdf_reader_pro'),
                      textAlign: TextAlign.center,
                      style: AppFonts.h2.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.t('unlock_pro_desc'),
                      textAlign: TextAlign.center,
                      style: AppFonts.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // Feature list
                    // _buildFeatureItem(Icons.edit_note, '编辑 PDF 文本', '直接修改文档中的文字内容'),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.compress, l10n.t('compress_pdf'),
                        l10n.t('compress_pdf_desc')),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.lock, l10n.t('encrypt_pdf'),
                        l10n.t('encrypt_pdf_desc')),
                    const SizedBox(height: 12),
                    // _buildFeatureItem(Icons.draw, '电子签名', '在手机上即可完成文档签署'),
                    // const SizedBox(height: 32),

                    // Purchase Section
                    if (!premiumState.isPremium) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.05),
                              AppColors.primary.withValues(alpha: 0.1)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.t('lifetime_member'),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.h3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.t('one_time_purchase'),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.bodySmall.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // 优先显示 Google Play 获取的真实价格
                                premiumState.isLoading &&
                                        premiumState.productDetails == null
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Flexible(
                                        flex: 0,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 150),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              premiumState
                                                      .productDetails?.price ??
                                                  l10n.t('loading_price'),
                                              maxLines: 1,
                                              style: AppFonts.h2.copyWith(
                                                  color: AppColors.primary),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: premiumState.isLoading
                                    ? null
                                    : _purchasePlan,
                                style: AppStyles.primaryButton,
                                child: premiumState.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3))
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(l10n.t('unlock_pro_now'),
                                            style: AppFonts.button),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: AppStyles.cardDecoration().copyWith(
                          border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.success, size: 48),
                            const SizedBox(height: 16),
                            Text(l10n.t('already_pro'), style: AppFonts.h3),
                            const SizedBox(height: 8),
                            Text(l10n.t('lifetime_active'),
                                style: AppFonts.bodyMedium),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        GestureDetector(
                          onTap: () => _showLegalDialog(
                            l10n.t('terms'),
                            l10n.locale.languageCode == 'zh'
                                ? LegalText.termsOfServiceZh
                                : LegalText.termsOfService,
                          ),
                          child: _buildLinkText(l10n.t('terms')),
                        ),
                        GestureDetector(
                          onTap: () => _showLegalDialog(
                            l10n.t('privacy_policy'),
                            l10n.locale.languageCode == 'zh'
                                ? LegalText.privacyPolicyZh
                                : LegalText.privacyPolicy,
                          ),
                          child: _buildLinkText(l10n.t('privacy_policy')),
                        ),
                        GestureDetector(
                            onTap: premiumState.isLoading
                                ? null
                                : _restorePurchases,
                            child: _buildLinkText(l10n.t('restore_purchase'))),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                softWrap: true,
                style:
                    AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkText(String text) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.bodySmall.copyWith(
          color: AppColors.textHint, decoration: TextDecoration.underline),
    );
  }
}
