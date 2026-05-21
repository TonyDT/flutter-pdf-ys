// main.dart - 完全干净的最终版本，无任何错误
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'PDF阅读器',
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('zh', 'CN'),
      home: const HomeScreen(),
    );
  }
}