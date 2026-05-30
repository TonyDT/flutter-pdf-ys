import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../models/test_app.dart';
import '../../core/widgets/day_progress_bar.dart';

class TestTab extends ConsumerWidget {
  const TestTab({super.key});

  void _showActionMenu(BuildContext context, WidgetRef ref, TestApp app) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('查看商店'),
              onTap: () async {
                final url = Uri.parse('https://play.google.com/store/apps/details?id=${app.packageName}');
                if (await canLaunchUrl(url)) await launchUrl(url);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop, color: Colors.red),
              title: const Text('停止测试', style: TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(appProvider.notifier).removeApp(app.packageName);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAppTap(BuildContext context, WidgetRef ref, TestApp app) async {
    final notifier = ref.read(appProvider.notifier);

    // 显示检查中的状态
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 判断是否已经上线
    final isOnline = await notifier.checkIfAppIsOnline(app.packageName);
    
    if (context.mounted) Navigator.pop(context); // 关闭加载

    if (isOnline) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提示'),
            content: Text('检测到应用“${app.name}”已上线，请停止打卡。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('知道了'),
              ),
              TextButton(
                onPressed: () {
                  notifier.removeApp(app.packageName);
                  Navigator.pop(context);
                },
                child: const Text('立即停止', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    } else {
      // 未上线，正常打卡
      await InstalledApps.startApp(app.packageName);
      await notifier.checkIn(app);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('测试中心', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                '${state.testingApps.length}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: state.testingApps.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bug_report_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无测试应用', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.testingApps.length,
              itemBuilder: (context, index) {
                final app = state.testingApps[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => _handleAppTap(context, ref, app),
                    onLongPress: () => _showActionMenu(context, ref, app),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[100],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: app.icon != null 
                                    ? Image.memory(app.icon!, fit: BoxFit.cover)
                                    : const Icon(Icons.android, color: Colors.green, size: 28),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(app.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('已测: ${app.testDays} 天', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                              ),
                              if (app.isCheckInToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('已测', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                )
                              else
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DayProgressBar(days: app.testDays),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
