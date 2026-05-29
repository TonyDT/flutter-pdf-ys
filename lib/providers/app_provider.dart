import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/test_app.dart';

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});

class AppState {
  final List<AppInfo> installedApps;
  final List<TestApp> testingApps;
  final bool isLoading;

  AppState({
    required this.installedApps,
    required this.testingApps,
    this.isLoading = false,
  });

  AppState copyWith({
    List<AppInfo>? installedApps,
    List<TestApp>? testingApps,
    bool? isLoading,
  }) {
    return AppState(
      installedApps: installedApps ?? this.installedApps,
      testingApps: testingApps ?? this.testingApps,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(AppState(installedApps: [], testingApps: [])) {
    _init();
  }

  static const String _boxName = 'gp_tester_box_v2';

  Future<void> _init() async {
    final box = await Hive.openBox(_boxName);
    final data = box.get('apps', defaultValue: []) as List;
    final apps = data.map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map['icon'] != null && map['icon'] is! Uint8List) {
        map['icon'] = Uint8List.fromList(List<int>.from(map['icon']));
      }
      return TestApp.fromMap(map);
    }).toList();
    state = state.copyWith(testingApps: apps);
  }

  Future<void> scanApps() async {
    state = state.copyWith(isLoading: true);
    try {
      // 快速扫描本地所有应用，不再进行在线状态检查
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      state = state.copyWith(installedApps: apps, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // 检查应用是否上线（仅在点击打卡时触发）
  Future<bool> checkIfAppIsOnline(String packageName) async {
    try {
      final response = await http.head(
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
      ).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false; // 无法检查或网络错误时默认认为没上线
    }
  }

  Future<void> addToTest(AppInfo app) async {
    if (state.testingApps.any((a) => a.packageName == app.packageName)) return;

    final newApp = TestApp(
      name: app.name,
      packageName: app.packageName,
      checkInDates: [],
      addedDate: DateTime.now(),
      icon: app.icon,
    );

    final updatedList = [...state.testingApps, newApp];
    await _saveToHive(updatedList);
    state = state.copyWith(testingApps: updatedList);
  }

  Future<void> checkIn(TestApp app) async {
    if (app.isCheckInToday) return;

    final updatedList = state.testingApps.map((a) {
      if (a.packageName == app.packageName) {
        return a.copyWith(checkInDates: [...a.checkInDates, DateTime.now()]);
      }
      return a;
    }).toList();

    await _saveToHive(updatedList);
    state = state.copyWith(testingApps: updatedList);
  }

  Future<void> removeApp(String packageName) async {
    final updatedList = state.testingApps.where((a) => a.packageName != packageName).toList();
    await _saveToHive(updatedList);
    state = state.copyWith(testingApps: updatedList);
  }

  Future<void> _saveToHive(List<TestApp> apps) async {
    final box = Hive.box(_boxName);
    final data = apps.map((a) => a.toMap()).toList();
    await box.put('apps', data);
  }
}
