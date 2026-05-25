import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/l10n/app_localizations.dart';
import '../core/premium/premium_provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  ProductDetails? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await ref.read(premiumProvider.notifier).getProductDetails();
    setState(() {
      _product = product;
      _loading = false;
    });
  }

  String _formatPrice(ProductDetails product) {
    // 显示本地化价格
    return product.price;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.upgradeToPro, style: AppFonts.h3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        actions: [
          // 恢复购买按钮
          TextButton(
            onPressed: premiumState.isPending
                ? null
                : () async {
                    await ref.read(premiumProvider.notifier).restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.restorePurchase),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    }
                  },
            child: Text(l10n.restorePurchase, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 皇冠图标
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.premiumGold, AppColors.premiumGoldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppColors.premiumGold.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text('ZeronPDF Pro', style: AppFonts.h1.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(l10n.unlockAllFeatures, style: AppFonts.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            // Feature list
            _buildFeatureItem(Icons.highlight, l10n.featureAnnotation, l10n.featureAnnotation),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.call_split, l10n.featureSplit, l10n.featureSplit),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.compress, l10n.compressPDF, l10n.featureCompress),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.lock, l10n.encryptPDF, l10n.featureEncrypt),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.photo_library, l10n.imagesToPDF, l10n.featureImageToPdf),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.cloud_off, l10n.featureOffline, l10n.featureOffline),
            const SizedBox(height: 40),

            // 价格卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration().copyWith(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(l10n.lifetimeSubscription, style: AppFonts.h3),
                  const SizedBox(height: 8),
                  if (_loading)
                    const SizedBox(
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_product != null) ...[
                    Text(_formatPrice(_product!), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(l10n.lifetimeSubscription, style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ] else ...[
                    Text('--', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(l10n.comingSoon, style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: premiumState.isPremium || premiumState.isPending
                          ? null
                          : () async {
                              if (_product != null) {
                                await ref.read(premiumProvider.notifier).purchase(_product!);
                              } else {
                                // 内购未配置时，提示用户
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.comingSoon),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                }
                              }
                            },
                      style: AppStyles.primaryButton,
                      child: premiumState.isPending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(premiumState.isPremium ? l10n.alreadyPro : l10n.upgradeNow, style: AppFonts.button),
                    ),
                  ),
                ],
              ),
            ),

            if (premiumState.isPremium) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.proActivated, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                            if (premiumState.expiryDate != null)
                              Text('${l10n.expiryDate}: ${premiumState.expiryDate!.year}-${premiumState.expiryDate!.month.toString().padLeft(2, '0')}-${premiumState.expiryDate!.day.toString().padLeft(2, '0')}',
                                  style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ),
            ],

            const SizedBox(height: 24),
            Text(l10n.featureOffline, style: AppFonts.bodySmall.copyWith(color: AppColors.textHint)),
            const SizedBox(height: 12),
            // 隐私政策和使用条款链接
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final uri = Uri.parse('https://zeronpdf.com/privacy');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(l10n.privacyPolicy, style: const TextStyle(fontSize: 12)),
                ),
                const Text('•', style: TextStyle(color: AppColors.textHint)),
                TextButton(
                  onPressed: () async {
                    final uri = Uri.parse('https://zeronpdf.com/terms');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(l10n.premiumRequired, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.h4),
                const SizedBox(height: 2),
                Text(subtitle, style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}
