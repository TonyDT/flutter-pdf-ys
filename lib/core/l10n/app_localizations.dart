import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const _localizedValues = {
    'en': {
      'app_name': 'GPTesting',
      'apps': 'Apps',
      'test': 'Test',
      'settings': 'Settings',
      'report': 'Report',
      'search_hint': 'Search local apps...',
      'scan_button': 'Scan Apps',
      'no_apps': 'No apps found',
      'test_button': 'Test',
      'tested_button': 'Tested',
      'test_center': 'Test Center',
      'no_test_apps': 'No apps in test',
      'days_progress': 'Progress: {days}/14 Days',
      'tested_tag': 'Tested',
      'view_store': 'View Store',
      'stop_test': 'Stop Test',
      'online_alert': 'App "{name}" is online. Please stop testing.',
      'report_center': 'Report Center',
      'daily_report': 'Daily Report',
      'stat_total': 'Total Apps',
      'stat_tested': 'Tested Today',
      'save_success': 'Report saved to gallery',
      'save_failed': 'Failed to save report',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'check_update': 'Check Update',
      'latest_version': 'Already latest version',
    },
    'zh': {
      'app_name': 'GPTesting',
      'apps': '应用',
      'test': '测试',
      'settings': '设置',
      'report': '报告',
      'search_hint': '快速搜索本地应用...',
      'scan_button': '扫描手机应用',
      'no_apps': '尚未扫描应用',
      'test_button': '测试',
      'tested_button': '已测',
      'test_center': '测试中心',
      'no_test_apps': '暂无测试应用',
      'days_progress': '进度: {days}/14 天',
      'tested_tag': '已测',
      'view_store': '查看商店',
      'stop_test': '停止测试',
      'online_alert': '检测到应用“{name}”已上线，请停止打卡。',
      'report_center': '报告中心',
      'daily_report': '每日测试报告',
      'stat_total': '测试应用',
      'stat_tested': '今日已测',
      'save_success': '报告已成功保存到相册',
      'save_failed': '保存失败，请稍后重试',
      'version': '版本信息',
      'privacy_policy': '隐私政策',
      'check_update': '检查更新',
      'latest_version': '当前已是最新版本',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String translateWithParam(String key, Map<String, String> params) {
    String value = translate(key);
    params.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
