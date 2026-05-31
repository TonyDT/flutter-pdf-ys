import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class AppsTab extends ConsumerStatefulWidget {
  const AppsTab({super.key});

  @override
  ConsumerState<AppsTab> createState() => _AppsTabState();
}

class _AppsTabState extends ConsumerState<AppsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final filteredApps = state.installedApps.where((app) =>
        app.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.translate('apps'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: () => notifier.scanApps(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: AppStyles.inputDecoration(
                hintText: l10n.translate('search_hint'),
                prefixIcon: Icons.search_rounded,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 3)))
          else if (state.installedApps.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
                      child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.translate('no_apps'), style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => notifier.scanApps(),
                      style: AppStyles.primaryButton,
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: Text(l10n.translate('scan_button')),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 140,
                ),
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  final isTesting = state.testingApps.any((a) => a.packageName == app.packageName);

                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: app.icon != null 
                                ? Image.memory(app.icon!, fit: BoxFit.cover)
                                : const Icon(Icons.android, color: AppColors.success, size: 32),
                            ),
                          ),
                          if (isTesting)
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.2, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: TextButton(
                          onPressed: isTesting ? null : () => notifier.addToTest(app),
                          style: TextButton.styleFrom(
                            backgroundColor: isTesting ? Colors.grey[100] : AppColors.primary.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isTesting ? l10n.translate('tested_button') : l10n.translate('test_button'),
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.w900,
                              color: isTesting ? AppColors.textTertiary : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
