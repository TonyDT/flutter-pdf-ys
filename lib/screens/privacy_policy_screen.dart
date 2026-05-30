import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GPTesting 隐私政策',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '生效日期：${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. 我们收集的信息'),
            _buildSectionContent(
              'GPTesting 是一款纯本地运行的工具软件。我们不会收集您的任何个人身份信息。'
              '\n• 应用列表：为了帮助您进行 Google Play 测试，我们需要获取您设备上安装的应用列表。此数据仅用于在应用内展示并协助您打卡，绝不会上传至任何服务器。'
              '\n• 打卡记录：您的测试打卡时间记录存储在您手机本地的数据库中。',
            ),
            _buildSectionTitle('2. 权限使用说明'),
            _buildSectionContent(
              '为了实现核心功能，我们需要以下权限：'
              '\n• QUERY_ALL_PACKAGES（查询所有包）：用于扫描您手机上安装的测试应用。'
              '\n• 存储/照片权限：用于将生成的测试报告图片保存到您的手机相册中。'
              '\n• 联网权限：仅用于检查应用是否在 Google Play 商店上线，不会上传您的个人数据。',
            ),
            _buildSectionTitle('3. 数据存储与安全'),
            _buildSectionContent(
              '所有数据（应用图标、打卡时间等）均存储在您设备的本地存储中。当您卸载本应用时，所有相关数据将随之删除。我们没有中央服务器来存储您的数据。',
            ),
            _buildSectionTitle('4. 第三方服务'),
            _buildSectionContent(
              '本应用可能包含指向 Google Play 商店的链接。这些第三方网站有其独立的隐私政策，请在使用时予以注意。',
            ),
            _buildSectionTitle('5. 政策更新'),
            _buildSectionContent(
              '我们可能会不时更新隐私政策。建议您定期查看此页面。',
            ),
            _buildSectionTitle('6. 联系我们'),
            _buildSectionContent(
              '如果您对本隐私政策有任何疑问，请通过以下方式联系我们：\n邮箱：support@gptesting.com',
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'GPTesting 团队 敬上',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
    );
  }
}
