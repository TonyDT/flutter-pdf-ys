// /Users/taodong/Desktop/flutter/flutter_pdf/lib/core/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      'app_name': 'PDF阅读器',
      'pdf_pro': 'PDF Pro',
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
      'contact_email': '如有任何问题或建议，请发送邮件至：privacy@zeronpdf.com\n\n我们会尽快回复您的反馈。',
      'privacy_content':
          '隐私协议\n\n生效日期：2026年6月10日\n\nZeronPDF-OffVault 是离线 PDF 处理应用。PDF 文件、生成文件、注释、书签、主题设置和会员状态均在您的设备本地处理和保存。\n\n我们不运营应用服务器，不收集、上传、出售或共享您的 PDF 文件或个人信息。\n\nGoogle Play 购买\n应用使用 Google Play Billing 处理一次性 Pro 解锁。付款信息由 Google Play 处理。应用仅保存用于解锁和恢复 Pro 功能所需的本地会员状态和购买引用。\n\n文件和文档\n应用可能访问您通过系统文件选择器主动选择的文件，仅用于打开、编辑、转换、压缩、加密、导出或分享这些文件。\n\n第三方服务\n应用不包含广告 SDK、分析 SDK 或跟踪 SDK。购买或恢复 Pro 时，Google Play 服务可能会处理购买信息。\n\n数据删除\n您可以删除设备上的生成文件，并可通过卸载应用移除本地应用数据。购买记录仍与您的 Google Play 账号关联，可通过 Google Play 恢复。\n\n联系邮箱：privacy@zeronpdf.com',
      'processing': '正在处理...',
      'success': '操作成功！',
      'error': '错误',
      'feature_dev': '功能开发中，敬请期待...',
      'password_too_short': '密码至少需要4位字符',
      'please_enter_content': '请输入文本内容',
      'select_at_least_two': '请至少选择2个PDF文件进行合并',
      'sending_to_printer': '正在发送到打印机...',
      'language': '语言',
      'english': 'English',
      'chinese': '中文',
      'open_pdf': '打开 PDF',
      'toggle_theme': '切换主题',
      'delete': '删除',
      'cancel': '取消',
      'delete_pdf_confirm': '确定要删除这个 PDF 吗？',
      'image_to_pdf': '图片转 PDF',
      'pdf_to_long_image': 'PDF 转长图',
      'edit_pdf_text': '编辑 PDF 文本',
      'merge_pdf': '合并 PDF',
      'compress_pdf': '压缩 PDF',
      'encrypt_pdf': '加密 PDF',
      'image_to_pdf_desc': '将多张图片合并为 PDF 文件',
      'pdf_to_long_image_desc': '将所有页面拼接为一张长图',
      'edit_pdf_text_desc': '编辑 PDF 文档中的文本内容',
      'merge_pdf_desc': '将多个 PDF 文件合并为一个文档',
      'compress_pdf_desc': '压缩 PDF 文件大小，节省存储空间',
      'encrypt_pdf_desc': '给 PDF 文件添加密码加密保护',
      'feature_coming_soon': '功能开发中，敬请期待...',
      'choose_pdf_file': '选择 PDF 文件',
      'add_pdf_files': '添加 PDF 文件',
      'add_files_to_merge': '添加要合并的文件',
      'select_two_pdfs': '请至少选择 2 个 PDF 文件',
      'pdf_merge_success': 'PDF 合并成功！',
      'saved_to_app_dir': '已保存至应用目录',
      'merge_failed': '合并失败',
      'merge_files': '合并 {count} 个文件',
      'select_images': '选择图片',
      'selected_images': '已选择 {count} 张图片',
      'generate_pdf': '生成 PDF',
      'pdf_generate_success': 'PDF 生成成功！',
      'pdf_generate_failed': 'PDF 生成失败，请重试',
      'save_failed': '保存失败',
      'output_file': '输出文件',
      'save_to_gallery': '保存到相册',
      'share': '分享',
      'long_image_success': '长图生成成功！',
      'instructions': '说明',
      'long_image_desc': '将 PDF 所有页面纵向拼接为一张长图',
      'generate_long_image': '生成长图',
      'compress_success': '压缩成功',
      'compress_failed': '压缩失败',
      'original_size': '原始大小',
      'compressed_size': '压缩后',
      'compression_strength': '压缩强度',
      'low': '低',
      'medium': '中',
      'high': '高',
      'run_compression': '执行压缩',
      'share_compressed_file': '分享压缩后的文件',
      'lock_pdf': '锁定 PDF',
      'unlock_pdf': '解锁 PDF',
      'enter_password': '请输入密码',
      'password_mismatch': '两次输入的密码不一致',
      'pdf_encrypt_success': 'PDF 加密成功！',
      'pdf_decrypt_success': 'PDF 解密成功！',
      'encrypt_failed': '加密失败',
      'decrypt_failed': '解密失败，请检查密码是否正确',
      'encrypt_now': '立即加密',
      'decrypt_now': '立即解密',
      'set_password': '设置密码',
      'existing_password': '输入现有密码',
      'confirm_password': '确认密码',
      'encrypt_help': '加密后，任何人打开此 PDF 都需要输入您设置的密码。请务必牢记密码。',
      'decrypt_help': '解密将移除 PDF 的密码保护，生成一个新的无密码副本。',
      'enter_find_text': '请输入要查找的文本',
      'text_replace_success': '文本替换成功！',
      'text_replace_failed': '文本替换失败，可能未找到匹配项',
      'total_pages': '总页数',
      'find_replace': '查找并替换',
      'find_text': '查找文本',
      'replace_with': '替换为',
      'run_replace': '执行替换',
      'edit_text_note': '注意：此功能会查找文档中所有匹配的文本并用新文本覆盖。仅适用于可编辑文本的 PDF。',
      'upgrade_pro': '升级 Pro',
      'pdf_reader_pro': 'PDF 阅读器 Pro',
      'unlock_pro_desc': '解锁高级 PDF 压缩和加密功能',
      'lifetime_member': '终身会员',
      'one_time_purchase': '一次购买，永久使用',
      'loading_price': '获取中...',
      'unlock_pro_now': '立即解锁 Pro',
      'already_pro': '您已是 Pro 会员',
      'lifetime_active': '终身特权已激活',
      'terms': '服务条款',
      'restore_purchase': '恢复购买',
      'google_play_product_unavailable': '暂时无法获取 Google Play 商品信息，请稍后重试',
      'purchase_issue': '购买遇到问题',
      'billing_help':
          '如果商品不可用，请确认您是从 Google Play 测试链接安装应用，并检查测试账号、商品状态、国家/地区和签名证书。',
    },
    'en': {
      'app_name': 'PDF Reader',
      'pdf_pro': 'PDF Pro',
      'home': 'Home',
      'tools': 'PDF Tools',
      'settings': 'Settings',
      'my_pdfs': 'My PDFs',
      'no_pdfs_found':
          'No PDF files found. Please ensure you have PDF files on your device.',
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
      'contact_email':
          'If you have any questions or suggestions, please email us at: privacy@zeronpdf.com\n\nWe will reply to your feedback as soon as possible.',
      'privacy_content':
          'Privacy Policy\n\nEffective date: June 10, 2026\n\nZeronPDF-OffVault is an offline PDF processing app. PDF files, generated files, annotations, bookmarks, theme settings, and premium status are processed and stored locally on your device.\n\nWe do not operate an app server and do not collect, upload, sell, or share your PDF files or personal information.\n\nGoogle Play purchases\nThe app uses Google Play Billing to process the one-time Pro unlock. Payment information is handled by Google Play. The app stores only the local premium entitlement state and purchase reference needed to unlock and restore Pro features.\n\nFiles and documents\nThe app may access files that you choose through the system file picker. This access is used only to open, edit, convert, compress, encrypt, export, or share the files you select.\n\nThird-party services\nThe app does not include advertising SDKs, analytics SDKs, or tracking SDKs. Google Play services may process purchase information when you buy or restore Pro.\n\nData deletion\nYou can delete generated files from your device and uninstall the app to remove local app data. Purchases remain associated with your Google Play account and can be restored through Google Play.\n\nContact: privacy@zeronpdf.com',
      'processing': 'Processing...',
      'success': 'Success!',
      'error': 'Error',
      'feature_dev': 'Feature is under development, coming soon...',
      'password_too_short': 'Password must be at least 4 characters',
      'please_enter_content': 'Please enter content',
      'select_at_least_two': 'Please select at least 2 PDF files to merge',
      'sending_to_printer': 'Sending to printer...',
      'language': 'Language',
      'english': 'English',
      'chinese': '中文',
      'open_pdf': 'Open PDF',
      'toggle_theme': 'Toggle theme',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'delete_pdf_confirm': 'Are you sure you want to delete this PDF?',
      'image_to_pdf': 'Images to PDF',
      'pdf_to_long_image': 'PDF to Long Image',
      'edit_pdf_text': 'Edit PDF Text',
      'merge_pdf': 'Merge PDF',
      'compress_pdf': 'Compress PDF',
      'encrypt_pdf': 'Encrypt PDF',
      'image_to_pdf_desc': 'Combine multiple images into a PDF file',
      'pdf_to_long_image_desc': 'Stitch all PDF pages into one long image',
      'edit_pdf_text_desc': 'Edit text content inside a PDF document',
      'merge_pdf_desc': 'Merge multiple PDF files into one document',
      'compress_pdf_desc': 'Reduce PDF file size and save storage space',
      'encrypt_pdf_desc': 'Protect a PDF file with password encryption',
      'feature_coming_soon': 'This feature is coming soon.',
      'choose_pdf_file': 'Choose PDF File',
      'add_pdf_files': 'Add PDF Files',
      'add_files_to_merge': 'Add files to merge',
      'select_two_pdfs': 'Please select at least 2 PDF files',
      'pdf_merge_success': 'PDF merged successfully!',
      'saved_to_app_dir': 'Saved to the app folder',
      'merge_failed': 'Merge failed',
      'merge_files': 'Merge {count} files',
      'select_images': 'Select Images',
      'selected_images': '{count} images selected',
      'generate_pdf': 'Generate PDF',
      'pdf_generate_success': 'PDF generated successfully!',
      'pdf_generate_failed': 'Failed to generate PDF. Please try again.',
      'save_failed': 'Save failed',
      'output_file': 'Output File',
      'save_to_gallery': 'Save to gallery',
      'share': 'Share',
      'long_image_success': 'Long image generated successfully!',
      'instructions': 'Instructions',
      'long_image_desc': 'Stitch all PDF pages vertically into one long image',
      'generate_long_image': 'Generate Long Image',
      'compress_success': 'Compression completed',
      'compress_failed': 'Compression failed',
      'original_size': 'Original size',
      'compressed_size': 'Compressed size',
      'compression_strength': 'Compression Strength',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'run_compression': 'Compress PDF',
      'share_compressed_file': 'Share compressed file',
      'lock_pdf': 'Lock PDF',
      'unlock_pdf': 'Unlock PDF',
      'enter_password': 'Please enter a password',
      'password_mismatch': 'The passwords do not match',
      'pdf_encrypt_success': 'PDF encrypted successfully!',
      'pdf_decrypt_success': 'PDF decrypted successfully!',
      'encrypt_failed': 'Encryption failed',
      'decrypt_failed': 'Decryption failed. Please check the password.',
      'encrypt_now': 'Encrypt Now',
      'decrypt_now': 'Decrypt Now',
      'set_password': 'Set password',
      'existing_password': 'Enter existing password',
      'confirm_password': 'Confirm password',
      'encrypt_help':
          'After encryption, anyone opening this PDF must enter the password you set. Please keep it safe.',
      'decrypt_help':
          'Decryption removes password protection and creates a new unprotected copy.',
      'enter_find_text': 'Please enter the text to find',
      'text_replace_success': 'Text replaced successfully!',
      'text_replace_failed':
          'Text replacement failed. No matching text may have been found.',
      'total_pages': 'Total pages',
      'find_replace': 'Find and Replace',
      'find_text': 'Find text',
      'replace_with': 'Replace with',
      'run_replace': 'Replace Text',
      'edit_text_note':
          'Note: This feature finds matching text in the document and covers it with new text. It only works with editable-text PDFs.',
      'upgrade_pro': 'Upgrade Pro',
      'pdf_reader_pro': 'PDF Reader Pro',
      'unlock_pro_desc': 'Unlock advanced PDF compression and encryption',
      'lifetime_member': 'Lifetime Access',
      'one_time_purchase': 'One purchase, lifetime use',
      'loading_price': 'Loading...',
      'unlock_pro_now': 'Unlock Pro Now',
      'already_pro': 'You are Pro',
      'lifetime_active': 'Lifetime access is active',
      'terms': 'Terms',
      'restore_purchase': 'Restore Purchase',
      'google_play_product_unavailable':
          'Google Play product information is temporarily unavailable. Please try again later.',
      'purchase_issue': 'Purchase Issue',
      'billing_help':
          'If the product is unavailable, install the app from the Google Play testing link and check the tester account, product status, country/region, and signing certificate.',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String t(String key, {Map<String, String>? params}) {
    var value = translate(key);
    params?.forEach((key, replacement) {
      value = value.replaceAll('{$key}', replacement);
    });
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
