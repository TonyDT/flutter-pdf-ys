// /Users/taodong/Desktop/flutter/flutter_pdf/lib/core/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      'app_name': 'PDF阅读器',
      'home': '首页',
      'tools': 'PDF工具',
      'settings': '设置',
      'my_pdfs': '我的PDF文件',
      'no_pdfs_found': '未找到任何PDF文件，请确保您的设备上有PDF文件',
      'modified': '修改时间',
      'theme_settings': '主题设置',
      'light_mode': '浅色模式',
      'dark_mode': '深色模式',
      'about': '关于',
      'contact_us': '联系我们',
      'privacy_policy': '隐私协议',
      'version': '版本号',
      'confirm': '确定',
      'i_understand': '我已知晓',
      'contact_email': '如有任何问题或建议，请发送邮件至：support@pdfreader.com\n\n我们会尽快回复您的反馈。',
      'privacy_content': '隐私协议\n\n本应用尊重并保护所有用户的隐私权益。请您仔细阅读以下内容：\n\n🔒 数据本地化\n本应用所有功能均完全离线运行，您的所有PDF文件、注释、书签等数据仅保存在您的设备本地。\n\n📁 权限说明\n应用仅需要存储权限，用于读取您设备上的PDF文件，并保存您对文件的修改。除此之外不会访问任何其他数据。\n\n🚫 无数据收集\n我们不会上传、收集或共享您的任何个人信息和文件数据到任何服务器。\n\n🗑️ 数据删除\n您随时可以卸载本应用，卸载后所有应用相关数据都会从您的设备上完全清除。\n\n最后更新：2024年1月',
      'processing': '正在处理...',
      'success': '操作成功！',
      'error': '错误',
      'feature_dev': '功能开发中，敬请期待...',
      'enter_password': '请输入密码',
      'password_too_short': '密码至少需要4位字符',
      'please_enter_content': '请输入文本内容',
      'select_at_least_two': '请至少选择2个PDF文件进行合并',
      'sending_to_printer': '正在发送到打印机...',
    },
    'en': {
      'app_name': 'PDF Reader',
      'home': 'Home',
      'tools': 'PDF Tools',
      'settings': 'Settings',
      'my_pdfs': 'My PDFs',
      'no_pdfs_found': 'No PDF files found. Please ensure you have PDF files on your device.',
      'modified': 'Modified',
      'theme_settings': 'Theme Settings',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'about': 'About',
      'contact_us': 'Contact Us',
      'privacy_policy': 'Privacy Policy',
      'version': 'Version',
      'confirm': 'OK',
      'i_understand': 'I Understand',
      'contact_email': 'If you have any questions or suggestions, please email us at: support@pdfreader.com\n\nWe will reply to your feedback as soon as possible.',
      'privacy_content': 'Privacy Policy\n\nThis app respects and protects the privacy rights of all users. Please read the following carefully:\n\n🔒 Local Data\nAll features of this app work completely offline. All your PDF files, annotations, bookmarks and other data are only stored locally on your device.\n\n📁 Permissions\nThe app only requires storage permission to read PDF files on your device and save your modifications. It will not access any other data.\n\n🚫 No Data Collection\nWe will never upload, collect or share any of your personal information or file data to any server.\n\n🗑️ Data Deletion\nYou can uninstall this app at any time. After uninstallation, all app-related data will be completely removed from your device.\n\nLast updated: January 2024',
      'processing': 'Processing...',
      'success': 'Success!',
      'error': 'Error',
      'feature_dev': 'Feature is under development, coming soon...',
      'enter_password': 'Please enter password',
      'password_too_short': 'Password must be at least 4 characters',
      'please_enter_content': 'Please enter content',
      'select_at_least_two': 'Please select at least 2 PDF files to merge',
      'sending_to_printer': 'Sending to printer...',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
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