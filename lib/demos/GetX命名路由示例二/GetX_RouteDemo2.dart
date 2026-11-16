// 独立运行：flutter run -t "lib/demos/GetX命名路由示例二/GetX_RouteDemo2.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX命名路由示例二');

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
      appBar: JobsDemoAppBar(title: const LegacyText('Home')),
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
      appBar: JobsDemoAppBar(title: const LegacyText('Details')),
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

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetX_RouteDemo2');
