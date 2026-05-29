import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_provider.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _saveToGallery() async {
    // 1. 权限检查与请求
    PermissionStatus status;
    if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
      status = PermissionStatus.granted;
    } else {
      // 这里的提示符合用户要求：没有就提示，统一了就直接保存
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      try {
        // 增加延时确保UI渲染完成
        await Future.delayed(const Duration(milliseconds: 100));
        
        final Uint8List? image = await _screenshotController.capture(
          pixelRatio: 2.0, // 提高清晰度
        );
        
        if (image != null) {
          final result = await SaverGallery.saveImage(
            image,
            name: "GPTesting_${DateTime.now().millisecondsSinceEpoch}.png",
            androidRelativePath: "Pictures/GPTesting",
            androidExistNotSave: false,
          );
          
          if (mounted) {
            if (result.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 报告已成功保存到相册'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ 保存失败，请重试'), backgroundColor: Colors.red),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存出错: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('需要存储权限'),
            content: const Text('由于您之前拒绝了权限，请前往系统设置手动开启存储权限以保存报告。'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('分享报告', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.blue, size: 28),
            onPressed: _saveToGallery,
            tooltip: '保存到相册',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部：仅保留年月日
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GPTesting Report',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(
                          todayStr,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blue),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, thickness: 1.5),
                    ),
                    
                    // 统计卡片
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('测试应用', '${state.testingApps.length}', Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('今日已测', '${state.testingApps.where((a) => a.isCheckInToday).length}', Colors.green)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('打卡详情清单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    
                    if (state.testingApps.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text('暂无测试数据', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 64, // 增加高度确保文字图标不被遮挡
                        ),
                        itemCount: state.testingApps.length,
                        itemBuilder: (context, index) {
                          final app = state.testingApps[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: app.icon != null 
                                    ? Image.memory(app.icon!, width: 32, height: 32, fit: BoxFit.cover)
                                    : const Icon(Icons.android, color: Colors.green, size: 24),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        app.name,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        app.isCheckInToday ? '已测' : '待测',
                                        style: TextStyle(
                                          fontSize: 11, 
                                          color: app.isCheckInToday ? Colors.green[700] : Colors.red[700],
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 32),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '提示：保存后的图片将存放在相册的 GPTesting 文件夹中。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
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
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
