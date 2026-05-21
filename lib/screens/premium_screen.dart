import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/premium/premium_provider.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('升级Pro', style: AppFonts.h3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
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
            Text('PDF阅读器 Pro', style: AppFonts.h1.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('解锁全部高级功能', style: AppFonts.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            // Feature list
            _buildFeatureItem(Icons.highlight, 'Annotations', 'Highlight, strikethrough & notes'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.call_split, 'Split & Reorder', 'Extract pages, reorder & delete'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.compress, 'Compress', 'Reduce PDF file size offline'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.lock, 'Encrypt', 'Password protect your PDFs'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.photo_library, 'Image to PDF', 'Convert images to PDF'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.cloud_off, 'Fully Offline', 'All processing done locally'),
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
                  Text('年度会员', style: AppFonts.h3),
                  const SizedBox(height: 8),
                  const Text('¥68/年', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('约¥5.7/月', style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: premiumState.isPremium ? null : () async {
                        // 模拟购买流程
                        await ref.read(premiumProvider.notifier).activatePremium();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 恭喜！已成功升级Pro'),
                              backgroundColor: AppColors.success,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: AppStyles.primaryButton,
                      child: Text(premiumState.isPremium ? '已是Pro会员' : '立即升级', style: AppFonts.button),
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
                          const Text('Pro会员已激活', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                          if (premiumState.expiryDate != null)
                            Text('到期时间: ${premiumState.expiryDate!.year}-${premiumState.expiryDate!.month}-${premiumState.expiryDate!.day}',
                                style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text('支付后立即生效，可随时取消续费', style: AppFonts.bodySmall.copyWith(color: AppColors.textHint)),
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
