// 独立运行：flutter run -t "lib/demos/Material风格分页/Material.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: 'Material风格分页');

void legacyOriginalMain() => legacyCaptureApp(
  JobsMaterialRunner.builder(
    title: 'Flutter Tab Demo'.tr,
    builder: (ctx) => MyHomePage(),
  ),
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: LegacyText('首页'.tr)),
    Center(child: LegacyText('发现'.tr)),
    Center(child: LegacyText('我的'.tr)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'.tr),
        ],
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Material');
