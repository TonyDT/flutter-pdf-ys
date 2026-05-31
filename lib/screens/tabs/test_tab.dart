import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import '../../providers/app_provider.dart';
import '../../models/test_app.dart';
import '../../core/widgets/day_progress_bar.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class TestTab extends ConsumerWidget {
  const TestTab({super.key});

  void _showActionMenu(BuildContext context, WidgetRef ref, TestApp app) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.store_rounded, color: AppColors.primary),
              title: Text(l10n.translate('view_store'), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                // Implementation for url_launcher hidden in app_provider or similar
                ref.read(appProvider.notifier).openStore(app.packageName);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop_circle_rounded, color: AppColors.error),
              title: Text(l10n.translate('stop_test'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              onTap: () {
                ref.read(appProvider.notifier).removeApp(app.packageName);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAppTap(BuildContext context, WidgetRef ref, TestApp app) async {
    final notifier = ref.read(appProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
    );

    final isOnline = await notifier.checkIfAppIsOnline(app.packageName);
    if (context.mounted) Navigator.pop(context);

    if (isOnline) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('提示', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(l10n.translateWithParam('online_alert', {'name': app.name})),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('知道了')),
              ElevatedButton(
                onPressed: () {
                  notifier.removeApp(app.packageName);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                child: Text(l10n.translate('stop_test')),
              ),
            ],
          ),
        );
      }
    } else {
      await InstalledApps.startApp(app.packageName);
      await notifier.checkIn(app);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.translate('test_center'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${state.testingApps.length}',
              style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      body: state.testingApps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bug_report_outlined, size: 64, color: AppColors.textTertiary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.translate('no_test_apps'), style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.testingApps.length,
              itemBuilder: (context, index) {
                final app = state.testingApps[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: AppStyles.cardDecoration(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _handleAppTap(context, ref, app),
                    onLongPress: () => _showActionMenu(context, ref, app),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: app.icon != null 
                                    ? Image.memory(app.icon!, fit: BoxFit.cover)
                                    : const Icon(Icons.android, color: AppColors.success, size: 30),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(app.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.translateWithParam('days_progress', {'days': app.testDays.toString()}),
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              if (app.isCheckInToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text(l10n.translate('tested_tag'), style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w900)),
                                )
                              else
                                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiary),
                            ],
                          ),
                          const SizedBox(height: 20),
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
