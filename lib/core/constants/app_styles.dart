import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppStyles {
  AppStyles._();

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static InputDecoration inputDecoration({
    String? hintText,
    IconData? prefixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.bodyMedium.copyWith(color: AppColors.textHint),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary) : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppFonts.button,
    elevation: 0,
  );
}
