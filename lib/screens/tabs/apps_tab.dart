import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_provider.dart';

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

    final filteredApps = state.installedApps.where((app) =>
        app.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('应用库', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.scanApps(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '快速搜索本地应用...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.installedApps.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('尚未扫描应用'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => notifier.scanApps(),
                      child: const Text('扫描手机应用'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 140, // 增加总高度
                ),
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  final isTesting = state.testingApps.any((a) => a.packageName == app.packageName);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: app.icon != null 
                            ? Image.memory(app.icon!, fit: BoxFit.cover)
                            : const Icon(Icons.android, color: Colors.green, size: 32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        app.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, height: 1.2),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: TextButton(
                          onPressed: isTesting ? null : () => notifier.addToTest(app),
                          style: TextButton.styleFrom(
                            backgroundColor: isTesting ? Colors.grey[200] : Colors.blue.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            isTesting ? '已测' : '测试',
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              color: isTesting ? Colors.grey : Colors.blue[700],
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
