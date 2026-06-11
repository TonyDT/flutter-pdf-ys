import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class LanguageState {
  final String languageCode;

  const LanguageState({this.languageCode = 'en'});

  Locale get locale => Locale(languageCode);
  bool get isEnglish => languageCode == 'en';

  LanguageState copyWith({String? languageCode}) =>
      LanguageState(languageCode: languageCode ?? this.languageCode);
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  static const String _boxName = 'settings';
  static const String _languageKey = 'language_code';

  LanguageNotifier() : super(const LanguageState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox(_boxName);
    final languageCode = box.get(_languageKey, defaultValue: 'en') as String;
    state = state.copyWith(
      languageCode: languageCode == 'zh' ? 'zh' : 'en',
    );
  }

  Future<void> setLanguage(String languageCode) async {
    final normalizedCode = languageCode == 'zh' ? 'zh' : 'en';
    state = state.copyWith(languageCode: normalizedCode);
    final box = await Hive.openBox(_boxName);
    await box.put(_languageKey, normalizedCode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>(
  (ref) => LanguageNotifier(),
);
