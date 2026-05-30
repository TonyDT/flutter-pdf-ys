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
    if (mounted) {
      setState(() {
        _packageName = info.packageName;
      });
    }
  }

  /// 弹出预览并保存的弹窗
  void _showPreviewAndSave(Uint8List imageBytes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('报告预览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(imageBytes),
              ),
            ),
            const SizedBox(height: 12),
            const Text('确认无误后点击下方按钮保存到相册', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeSaveWithPermission(imageBytes);
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('保存到相册'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 检查权限并执行真实的保存动作
  Future<void> _executeSaveWithPermission(Uint8List image) async {
    try {
      bool isGranted = false;

      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = deviceInfo.version.sdkInt;

        if (sdkInt >= 33) {
          // Android 13+ 需要请求 photos 权限
          var status = await Permission.photos.request();
          isGranted = status.isGranted || status.isLimited;
        } else {
          // Android 12及以下需要 storage 权限
          var status = await Permission.storage.request();
          isGranted = status.isGranted;
        }
      } else {
        // iOS
        var status = await Permission.photos.request();
        isGranted = status.isGranted || status.isLimited;
      }

      if (isGranted) {
        final result = await SaverGallery.saveImage(
          image,
          name: "GPTesting_${DateTime.now().millisecondsSinceEpoch}.png",
          androidRelativePath: "Pictures/GPTesting",
          androidExistNotSave: false,
        );

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🎉 报告已成功保存到相册'), backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ 保存失败，请检查相册空间'), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      debugPrint("Save error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发生错误: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 点击右上角按钮：仅生成预览，不涉及权限
  Future<void> _handleShareButtonClick() async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );
      }

      await Future.delayed(const Duration(milliseconds: 300));
      
      final Uint8List? image = await _screenshotController.capture(
        pixelRatio: 2.0,
      );

      if (mounted) Navigator.pop(context);

      if (image != null) {
        if (mounted) _showPreviewAndSave(image);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('生成报告失败，请重试'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('出现错误: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要照片访问权限'),
        content: const Text('为了将报告保存到相册，请授予应用访问相册的权限。\n\n如果系统未弹出授权框，请前往“设置 -> 权限”中手动开启。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final playStoreUrl = 'https://play.google.com/store/apps/details?id=$_packageName';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('报告中心', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.blue, size: 30),
            onPressed: _handleShareButtonClick,
            tooltip: '生成预览',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            todayStr,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, thickness: 1.5),
                    ),
                    const Text('打卡详情清单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black38)),
                    const SizedBox(height: 8),
                    if (state.testingApps.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('暂无测试数据', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          mainAxisExtent: 120, // 增加高度以容纳方块进度条
                        ),
                        itemCount: state.testingApps.length,
                        itemBuilder: (context, index) {
                          final app = state.testingApps[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: app.icon != null
                                          ? Image.memory(app.icon!, width: 40, height: 40, fit: BoxFit.cover)
                                          : const Icon(Icons.android, color: Colors.green, size: 20),
                                    ),
                                    const SizedBox(width: 4),
                                    Column(
                                      children: [
                                        Text(
                                          app.isCheckInToday ? "已" : "待",
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.1,
                                            color: app.isCheckInToday ? Colors.green[700] : Colors.red[700],
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          "测",
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.1,
                                            color: app.isCheckInToday ? Colors.green[700] : Colors.red[700],
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  app.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                // 14个小方块进度条
                                DayProgressBar(days: app.testDays, blockHeight: 5, spacing: 2),
                              ],
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 20),
                    // 二维码部分
                    // if (_packageName.isNotEmpty)
                    //   Center(
                    //     child: Column(
                    //       children: [
                    //         const Divider(),
                    //         const SizedBox(height: 10),
                    //         const Text('扫描二维码下载最新版本', style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                    //         const SizedBox(height: 10),
                    //         QrImageView(
                    //           data: playStoreUrl,
                    //           version: QrVersions.auto,
                    //           size: 100.0,
                    //           backgroundColor: Colors.white,
                    //         ),
                    //
                    //       ],
                    //     ),
                    //   ),

                    const SizedBox(height: 40),
                    const Center(
                      child: Column(
                        children: [
                          Divider(),
                          SizedBox(height: 12),
                          Text('Generated by GPTesting Assistant', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
