import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/app_provider.dart';
import '../core/widgets/day_progress_bar.dart';
import '../core/l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String _packageName = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageName = info.packageName);
  }

  void _showPreviewAndSave(Uint8List imageBytes) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(l10n.translate('report_center'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryLight, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.memory(imageBytes)),
            ),
            const SizedBox(height: 20),
            const Text('报告已生成，确认后点击保存', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消', style: TextStyle(color: AppColors.textTertiary))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _executeSaveWithPermission(imageBytes); },
            style: AppStyles.primaryButton.copyWith(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            child: const Text('保存到相册'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSaveWithPermission(Uint8List image) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      bool isGranted = false;
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        isGranted = deviceInfo.version.sdkInt >= 33 
            ? (await Permission.photos.request().isGranted) 
            : (await Permission.storage.request().isGranted);
      } else {
        isGranted = await Permission.photos.request().isGranted;
      }

      if (isGranted) {
        final result = await SaverGallery.saveImage(image, name: "GPTesting_${DateTime.now().millisecondsSinceEpoch}.png", androidRelativePath: "Pictures/GPTesting", androidExistNotSave: false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.translate('save_success'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('需要权限', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('请在设置中开启“照片和视频”权限，以便我们将报告存入您的相册。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () { openAppSettings(); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShareButtonClick() async {
    if (mounted) {
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (ctx) => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }
    await Future.delayed(const Duration(milliseconds: 500));
    final Uint8List? image = await _screenshotController.capture(pixelRatio: 2.5); // 进一步提升清晰度
    if (mounted) Navigator.pop(context);
    if (image != null) _showPreviewAndSave(image);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final l10n = AppLocalizations.of(context)!;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.translate('report_center'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            onPressed: _handleShareButtonClick,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.share_rounded, color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 头部居中
                    Text(todayStr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1)),
                    Text(l10n.translate('daily_report').toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textTertiary, letterSpacing: 2)),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Divider(height: 1, thickness: 1.2, color: Color(0xFFF8FAFC))),
                    
                    // 统计数据
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(l10n.translate('stat_total'), '${state.testingApps.length}', AppColors.primary)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard(l10n.translate('stat_tested'), '${state.testingApps.where((a) => a.isCheckInToday).length}', AppColors.success)),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    if (state.testingApps.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(l10n.translate('no_test_apps'), style: const TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          mainAxisExtent: 100, // 充足的高度防止溢出
                        ),
                        itemCount: state.testingApps.length,
                        itemBuilder: (context, index) {
                          final app = state.testingApps[index];
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFDFF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: app.icon != null 
                                        ? Image.memory(app.icon!, width: 30, height: 30, fit: BoxFit.cover)
                                        : const Icon(Icons.android, color: AppColors.success, size: 20),
                                    ),
                                    const SizedBox(width: 25),
                                    Expanded(
                                      child: Text(
                                        app.isCheckInToday ? l10n.translate('tested_tag') : (l10n.locale.languageCode == 'zh' ? '待测' : 'Pending'), 
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: app.isCheckInToday ? AppColors.success : AppColors.error, 
                                          fontWeight: FontWeight.w900,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Expanded(  // 强制 Text 占据剩余宽度，超出就会折行或省略
                                  child: Text(
                                    app.name,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.2),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                DayProgressBar(days: app.testDays, blockHeight: 5, spacing: 2),
                              ],
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 22),
                    Text(
                      'Generated by GPTesting Assistant'.toUpperCase(), 
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
