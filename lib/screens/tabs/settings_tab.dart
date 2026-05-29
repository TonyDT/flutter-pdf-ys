import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../share_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  void _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text('版本信息'),
            trailing: Text(_version),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('隐私政策'),
            onTap: () async {
              final url = Uri.parse('https://your-privacy-policy-url.com');
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('检查更新'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('当前已是最新版本')),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'GPTesting - 专为 Google Play 12+14 天互测设计。',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
