import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static InputDecoration inputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20) : null,
        filled: true,
        fillColor: AppColors.primaryLight.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
  );
}
