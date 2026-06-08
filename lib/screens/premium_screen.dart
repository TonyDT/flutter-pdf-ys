import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/premium/premium_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  PremiumPlan _selectedPlan = PremiumPlan.yearly;
  bool _isPurchasing = false;

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);
    final success = await ref.read(premiumProvider.notifier).purchasePlan(_selectedPlan);
    setState(() => _isPurchasing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 恭喜！已成功升级Pro'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.premiumGold, AppColors.premiumGoldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.premiumGold.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text('PDF阅读器 Pro', style: AppFonts.h2.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('解锁全部高级功能，去除广告', style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            // Feature list
            _buildFeatureItem(Icons.edit_note, '编辑PDF文本', '直接修改文档中的文字内容'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.compress, '无损压缩', '在保证清晰度的前提下减小体积'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.lock, '强力加密', '为您的隐私文档设置高强度密码'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.draw, '电子签名', '在手机上即可完成文档签署'),
            const SizedBox(height: 32),

            // Plan Selection
            if (!premiumState.isPremium) ...[
              _buildPlanOption(PremiumPlan.monthly, '月度会员', '¥12', '¥12.0/月'),
              const SizedBox(height: 12),
              _buildPlanOption(PremiumPlan.yearly, '年度会员', '¥68', '约¥5.6/月', isBestValue: true),
              const SizedBox(height: 12),
              _buildPlanOption(PremiumPlan.lifetime, '终身会员', '¥198', '一次购买，永久使用'),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPurchasing ? null : _handlePurchase,
                  style: AppStyles.primaryButton,
                  child: _isPurchasing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text('立即订阅', style: AppFonts.button),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppStyles.cardDecoration().copyWith(
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                    const SizedBox(height: 16),
                    const Text('您已是Pro会员', style: AppFonts.h3),
                    const SizedBox(height: 8),
                    if (premiumState.expiryDate != null)
                      Text('有效期至: ${premiumState.expiryDate!.year}-${premiumState.expiryDate!.month}-${premiumState.expiryDate!.day}',
                          style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary))
                    else
                      const Text('终身特权已激活', style: AppFonts.bodyMedium),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => ref.read(premiumProvider.notifier).cancelPremium(),
                      style: AppStyles.outlineButton,
                      child: const Text('恢复免费版(测试用)'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLinkText('服务条款'),
                const SizedBox(width: 16),
                _buildLinkText('隐私政策'),
                const SizedBox(width: 16),
                _buildLinkText('恢复购买'),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(PremiumPlan plan, String title, String price, String subtext, {bool isBestValue = false}) {
    final isSelected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppFonts.h4),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('最实惠', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtext, style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(price, style: AppFonts.h3.copyWith(color: isSelected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
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
              Text(title, style: AppFonts.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkText(String text) {
    return Text(text, style: AppFonts.bodySmall.copyWith(color: AppColors.textHint, decoration: TextDecoration.underline));
  }
}
