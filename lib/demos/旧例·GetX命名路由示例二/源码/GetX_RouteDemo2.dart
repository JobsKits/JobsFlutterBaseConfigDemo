import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 定义了如何注入HomeController
// 利用GetX做路由管理
void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        title: 'Navigation Demo',
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const HomeScreen()),
          GetPage(name: '/details', page: () => const DetailsScreen()),
        ],
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            legacyToNamed('/details');
          },
          child: const LegacyText('Go to Details'),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Details')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            legacyBack(); // 返回上一个页面
          },
          child: const LegacyText('Go back'),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·GetX命名路由示例二');
