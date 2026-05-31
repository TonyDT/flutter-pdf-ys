import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF2563EB); // Modern Blue
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryDark = Color(0xFF1E40AF);

  // Accent & Neutral
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color background = Color(0xFFF8FAFC); // Very light grey-blue
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  
  // Status
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  
  // Rainbow Progress Colors
  static const List<Color> rainbow = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFFACC15), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
  ];
}
