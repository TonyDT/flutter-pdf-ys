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
    
    // 2. 测试中心排序：最后添加的在最顶上
    _sortAndSetTestingApps(apps);
  }

  void _sortAndSetTestingApps(List<TestApp> apps) {
    apps.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    state = state.copyWith(testingApps: apps);
  }

  Future<void> scanApps() async {
    state = state.copyWith(isLoading: true);
    try {
      // 快速扫描本地所有应用
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      
      // 1. 应用库排序：虽然插件不直接提供安装时间，但通常系统返回的顺序可以优化
      // 我们将其按名称排序作为基础，或者如果有安装时间字段再优化
      apps.sort((a, b) => a.name.compareTo(b.name));
      
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
      return false; 
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

    final updatedList = [newApp, ...state.testingApps]; // 直接插入到最前面
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
