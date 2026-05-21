import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../constants/app_colors.dart';

class ThemeState {
  final bool isDarkMode;

  const ThemeState({this.isDarkMode = false});

  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;
  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;

  ThemeState copyWith({bool? isDarkMode}) =>
      ThemeState(isDarkMode: isDarkMode ?? this.isDarkMode);

  static ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        useMaterial3: true,
      );

  static ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        useMaterial3: true,
      );
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _boxName = 'theme_box';
  static const String _darkModeKey = 'is_dark_mode';

  ThemeNotifier() : super(const ThemeState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox(_boxName);
    final isDark = box.get(_darkModeKey, defaultValue: false) as bool;
    state = state.copyWith(isDarkMode: isDark);
  }

  Future<void> toggleTheme() async {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);
    final box = await Hive.openBox(_boxName);
    await box.put(_darkModeKey, newValue);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
