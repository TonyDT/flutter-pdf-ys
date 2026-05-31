import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import 'tabs/apps_tab.dart';
import 'tabs/test_tab.dart';
import 'tabs/settings_tab.dart';
import 'share_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const AppsTab(),
    const TestTab(),
    const SettingsTab(),
    const ShareScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primary.withOpacity(0.1),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            unselectedIconTheme: const IconThemeData(color: AppColors.textTertiary),
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedLabelTextStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold),
            selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.apps_rounded),
                label: Text(l10n.translate('apps')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.bug_report_rounded),
                label: Text(l10n.translate('test')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_suggest_rounded),
                label: Text(l10n.translate('settings')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.analytics_rounded),
                label: Text(l10n.translate('report')),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: _tabs[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
