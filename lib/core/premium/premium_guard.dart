import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'premium_provider.dart';
export 'premium_provider.dart'; // 导出供其他文件使用
import '../../screens/premium_screen.dart';

/// 检查Premium权限，无权限时弹出升级对话框
/// 返回 true 表示有权限，false 表示无权限且已展示提示
Future<bool> checkPremium(BuildContext context, WidgetRef ref) async {
  final isPremium = ref.read(premiumProvider).isPremium;
  if (isPremium) return true;

  // 无权限，弹出升级对话框
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.premiumGold, AppColors.premiumGoldDark],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Premium Required',
              style: AppFonts.h3,
            ),
          ),
        ],
      ),
      content: const Text(
        'This feature requires ZeronPDF Pro.\n\n'
        'Upgrade to Pro to unlock:\n'
        '• PDF Annotation & Highlight\n'
        '• Split & Reorder Pages\n'
        '• Compress PDF\n'
        '• Encrypt & Decrypt\n'
        '• Image to PDF',
        style: TextStyle(fontSize: 14, height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.premiumGold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Upgrade'),
        ),
      ],
    ),
  );
  return false;
}
