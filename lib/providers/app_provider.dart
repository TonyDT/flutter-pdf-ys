import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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
  static const String _cacheBoxName = 'installed_apps_cache_v2'; // 升级版本以匹配新字段

  Future<void> _init() async {
    // 1. 加载测试中心数据
    final box = await Hive.openBox(_boxName);
    final data = box.get('apps', defaultValue: []) as List;
    final List<TestApp> tApps = data.map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map['icon'] != null && map['icon'] is! Uint8List) {
        map['icon'] = Uint8List.fromList(List<int>.from(map['icon']));
      }
      return TestApp.fromMap(map);
    }).toList();
    
    tApps.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    state = state.copyWith(testingApps: tApps);

    // 2. 加载本地缓存的应用列表
    final cacheBox = await Hive.openBox(_cacheBoxName);
    final cachedData = cacheBox.get('cached_list', defaultValue: null);

    if (cachedData != null) {
      final List<dynamic> list = cachedData;
      List<AppInfo> cachedApps = list.map((item) {
        final m = Map<String, dynamic>.from(item);
        return AppInfo(
          name: m['name'] ?? '',
          packageName: m['packageName'] ?? '',
          versionName: m['versionName'] ?? '',
          versionCode: m['versionCode'] ?? 0,
          icon: m['icon'] != null ? Uint8List.fromList(List<int>.from(m['icon'])) : null,
          builtWith: BuiltWith.values[m['builtWith'] ?? 0],
          installedTimestamp: m['installedTimestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        );
      }).toList().cast<AppInfo>();

      _applySortingAndSetState(cachedApps);
    } else {
      scanApps();
    }
  }

  /// 核心排序逻辑
  void _applySortingAndSetState(List<AppInfo> apps) {
    List<AppInfo> testing = [];
    List<AppInfo> others = List.from(apps);

    // 提取所有已测应用
    for (var tApp in state.testingApps) {
      final index = others.indexWhere((a) => a.packageName == tApp.packageName);
      if (index != -1) {
        testing.add(others[index]);
        others.removeAt(index);
      }
    }

    state = state.copyWith(installedApps: [...testing, ...others]);
  }

  /// 扫描系统应用并缓存到本地
  Future<void> scanApps() async {
    state = state.copyWith(isLoading: true);
    try {
      List<AppInfo> freshApps = await InstalledApps.getInstalledApps(true, true);
      // 默认按安装时间倒序
      freshApps.sort((a, b) => b.installedTimestamp.compareTo(a.installedTimestamp));

      final cacheBox = Hive.box(_cacheBoxName);
      final List<Map<String, dynamic>> dataToSave = freshApps.map((a) => {
        'name': a.name,
        'packageName': a.packageName,
        'versionName': a.versionName,
        'versionCode': a.versionCode,
        'icon': a.icon,
        'builtWith': a.builtWith.index,
        'installedTimestamp': a.installedTimestamp,
      }).toList();
      
      await cacheBox.put('cached_list', dataToSave);

      _applySortingAndSetState(freshApps);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

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

    final updatedTApps = [newApp, ...state.testingApps];
    await _saveToHive(updatedTApps);
    state = state.copyWith(testingApps: updatedTApps);
    _applySortingAndSetState(state.installedApps);
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
    _applySortingAndSetState(state.installedApps);
  }

  Future<void> openStore(String packageName) async {
    final url = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveToHive(List<TestApp> apps) async {
    final box = Hive.box(_boxName);
    final data = apps.map((a) => a.toMap()).toList();
    await box.put('apps', data);
  }
}
