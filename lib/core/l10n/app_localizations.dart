import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用本地化支持
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// 获取当前本地化实例
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
    Locale('ru', 'RU'),
  ];

  /// 语言显示名称
  static const Map<String, String> languageNames = {
    'en': 'English',
    'zh': '中文',
    'ru': 'Русский',
  };

  /// 获取当前语言的本地化实例
  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// 代理
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// 获取当前语言代码
  String get languageCode => locale.languageCode;

  /// 是否是中文
  bool get isChinese => locale.languageCode == 'zh';

  /// 是否是英文
  bool get isEnglish => locale.languageCode == 'en';

  /// 是否是俄语
  bool get isRussian => locale.languageCode == 'ru';

  // 通用
  String get appName => 'ZeronPDF';
  String get settings {
    if (isChinese) return '设置';
    if (isRussian) return 'Настройки';
    return 'Settings';
  }
  String get cancel {
    if (isChinese) return '取消';
    if (isRussian) return 'Отмена';
    return 'Cancel';
  }
  String get confirm {
    if (isChinese) return '确认';
    if (isRussian) return 'Подтвердить';
    return 'Confirm';
  }
  String get save {
    if (isChinese) return '保存';
    if (isRussian) return 'Сохранить';
    return 'Save';
  }
  String get delete {
    if (isChinese) return '删除';
    if (isRussian) return 'Удалить';
    return 'Delete';
  }
  String get edit {
    if (isChinese) return '编辑';
    if (isRussian) return 'Редактировать';
    return 'Edit';
  }
  String get close {
    if (isChinese) return '关闭';
    if (isRussian) return 'Закрыть';
    return 'Close';
  }
  String get loading {
    if (isChinese) return '加载中...';
    if (isRussian) return 'Загрузка...';
    return 'Loading...';
  }
  String get success {
    if (isChinese) return '成功';
    if (isRussian) return 'Успех';
    return 'Success';
  }
  String get error {
    if (isChinese) return '错误';
    if (isRussian) return 'Ошибка';
    return 'Error';
  }
  String get retry {
    if (isChinese) return '重试';
    if (isRussian) return 'Повторить';
    return 'Retry';
  }

  // 主题
  String get themeSettings {
    if (isChinese) return '主题设置';
    if (isRussian) return 'Настройки темы';
    return 'Theme Settings';
  }
  String get lightMode {
    if (isChinese) return '浅色模式';
    if (isRussian) return 'Светлая тема';
    return 'Light Mode';
  }
  String get darkMode {
    if (isChinese) return '深色模式';
    if (isRussian) return 'Темная тема';
    return 'Dark Mode';
  }

  // 首页
  String get homeTitle => 'ZeronPDF';
  String get tools {
    if (isChinese) return '工具';
    if (isRussian) return 'Инструменты';
    return 'Tools';
  }
  String get recentFiles {
    if (isChinese) return '最近文件';
    if (isRussian) return 'Недавние файлы';
    return 'Recent Files';
  }
  String get noRecentFiles {
    if (isChinese) return '暂无最近文件';
    if (isRussian) return 'Нет недавних файлов';
    return 'No recent files';
  }
  String get selectPDF {
    if (isChinese) return '选择PDF';
    if (isRussian) return 'Выбрать PDF';
    return 'Select PDF';
  }

  // 工具
  String get pdfTools {
    if (isChinese) return 'PDF工具';
    if (isRussian) return 'Инструменты PDF';
    return 'PDF Tools';
  }
  String get mergePDF {
    if (isChinese) return '合并PDF';
    if (isRussian) return 'Объединить PDF';
    return 'Merge PDF';
  }
  String get splitPDF {
    if (isChinese) return '拆分PDF';
    if (isRussian) return 'Разделить PDF';
    return 'Split PDF';
  }
  String get compressPDF {
    if (isChinese) return '压缩PDF';
    if (isRussian) return 'Сжать PDF';
    return 'Compress PDF';
  }
  String get encryptPDF {
    if (isChinese) return '加密PDF';
    if (isRussian) return 'Зашифровать PDF';
    return 'Encrypt PDF';
  }
  String get decryptPDF {
    if (isChinese) return '解密PDF';
    if (isRussian) return 'Расшифровать PDF';
    return 'Decrypt PDF';
  }
  String get imagesToPDF {
    if (isChinese) return '图片转PDF';
    if (isRussian) return 'Изображения в PDF';
    return 'Images to PDF';
  }
  String get pdfToImages {
    if (isChinese) return 'PDF转图片';
    if (isRussian) return 'PDF в изображения';
    return 'PDF to Images';
  }
  String get annotatePDF {
    if (isChinese) return '注释PDF';
    if (isRussian) return 'Аннотировать PDF';
    return 'Annotate PDF';
  }
  String get editText {
    if (isChinese) return '编辑文本';
    if (isRussian) return 'Редактировать текст';
    return 'Edit Text';
  }

  // Premium
  String get upgradeToPro => isChinese ? '升级到Pro' : 'Upgrade to Pro';
  String get premiumRequired => isChinese ? '需要Premium' : 'Premium Required';
  String get premiumFeature => isChinese ? '高级功能' : 'Premium Feature';
  String get unlockAllFeatures => isChinese ? '解锁全部功能' : 'Unlock all features';
  String get lifetimeSubscription {
    if (isChinese) return '永久专业版';
    if (isRussian) return 'Пожизненный Pro';
    return 'Lifetime Pro';
  }
  String get restorePurchase => isChinese ? '恢复购买' : 'Restore Purchase';
  String get purchaseSuccess => isChinese ? '购买成功' : 'Purchase Successful';
  String get alreadyPro => isChinese ? '已是Pro会员' : 'Already Pro Member';
  String get upgradeNow => isChinese ? '立即升级' : 'Upgrade Now';
  String get proActivated => isChinese ? 'Pro会员已激活' : 'Pro Member Activated';
  String get expiryDate => isChinese ? '到期时间' : 'Expiry Date';

  // 设置
  String get about => isChinese ? '关于' : 'About';
  String get contactUs => isChinese ? '联系我们' : 'Contact Us';
  String get privacyPolicy => isChinese ? '隐私协议' : 'Privacy Policy';
  String get version => isChinese ? '版本号' : 'Version';
  String get language {
    if (isChinese) return '语言';
    if (isRussian) return 'Язык';
    return 'Language';
  }
  String get selectLanguage {
    if (isChinese) return '选择语言';
    if (isRussian) return 'Выберите язык';
    return 'Select Language';
  }

  // 功能描述
  String get featureAnnotation => isChinese ? 'PDF标注、高亮、删除线' : 'PDF annotation, highlight, strikethrough';
  String get featureSplit => isChinese ? '提取页面、重排、删除页面' : 'Extract pages, reorder, delete pages';
  String get featureCompress => isChinese ? '离线压缩PDF文件大小' : 'Compress PDF file size offline';
  String get featureEncrypt => isChinese ? '密码保护您的PDF文件' : 'Password protect your PDF files';
  String get featureImageToPdf => isChinese ? '多张图片合并为PDF' : 'Merge multiple images to PDF';
  String get featureOffline => isChinese ? '所有处理均在本地完成' : 'All processing done locally';

  // 提示信息
  String get comingSoon => isChinese ? '即将推出' : 'Coming Soon';
  String get processing => isChinese ? '处理中...' : 'Processing...';
  String get fileSaved => isChinese ? '文件已保存' : 'File Saved';
  String get fileOpenFailed => isChinese ? '文件打开失败' : 'Failed to open file';
  String get noFileSelected => isChinese ? '未选择文件' : 'No file selected';
  String get confirmDelete => isChinese ? '确定要删除此PDF文件吗？' : 'Are you sure you want to delete this PDF?';

  // 联系我们
  String get contactEmail => isChinese ? '如有任何问题或建议，请发送邮件至：\nsupport@zeronpdf.com\n\n我们会尽快回复您的反馈。' : 'If you have any questions or suggestions, please email us at:\nsupport@zeronpdf.com\n\nWe will reply to your feedback as soon as possible.';

  // 隐私政策
  String get privacyTitle => isChinese ? '隐私协议' : 'Privacy Policy';
  String get privacyContent => isChinese
      ? '隐私协议\n\n'
          '本应用尊重并保护所有用户的隐私权益。请您仔细阅读以下内容：\n\n'
          '🔒 数据本地化\n'
          '本应用所有功能均完全离线运行，您的所有PDF文件、注释、书签等数据仅保存在您的设备本地。\n\n'
          '📁 权限说明\n'
          '应用仅需要存储权限，用于读取您设备上的PDF文件，并保存您对文件的修改。除此之外不会访问任何其他数据。\n\n'
          '🚫 无数据收集\n'
          '我们不会上传、收集或共享您的任何个人信息和文件数据到任何服务器。\n\n'
          '🗑️ 数据删除\n'
          '您随时可以卸载本应用，卸载后所有应用相关数据都会从您的设备上完全清除。\n\n'
          '最后更新：2024年1月'
      : 'Privacy Policy\n\n'
          'This app respects and protects the privacy rights of all users. Please read the following carefully:\n\n'
          '🔒 Data Localization\n'
          'All features of this app run completely offline. All your PDF files, annotations, bookmarks and other data are only stored locally on your device.\n\n'
          '📁 Permission Description\n'
          'The app only needs storage permission to read PDF files on your device and save your modifications. No other data will be accessed.\n\n'
          '🚫 No Data Collection\n'
          'We do not upload, collect or share any of your personal information or file data to any servers.\n\n'
          '🗑️ Data Deletion\n'
          'You can uninstall this app at any time. After uninstallation, all app-related data will be completely removed from your device.\n\n'
          'Last updated: January 2024';

  String get iKnow => isChinese ? '我已知晓' : 'I Understand';
}

/// 本地化代理
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// 语言Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('zh', 'CN'));

  /// 设置语言
  void setLocale(Locale locale) {
    if (AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      state = locale;
    }
  }

  /// 切换语言
  void toggleLocale() {
    if (state.languageCode == 'en') {
      state = const Locale('zh', 'CN');
    } else if (state.languageCode == 'zh') {
      state = const Locale('ru', 'RU');
    } else {
      state = const Locale('en', 'US');
    }
  }

  /// 是否是中文
  bool get isChinese => state.languageCode == 'zh';
}
