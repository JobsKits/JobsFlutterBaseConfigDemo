// 独立运行：flutter run -t "lib/demos/Cupertino风格分页/Cupertino.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: 'Cupertino风格分页');

void legacyOriginalMain() => legacyCaptureApp(
  JobsCupertinoRunner(MyCupertinoTabPage(), title: 'Cupertino Tab 示例'.tr),
);

class MyCupertinoTabPage extends StatefulWidget {
  const MyCupertinoTabPage({super.key});

  @override
  State<MyCupertinoTabPage> createState() => _MyCupertinoTabPageState();
}

class _MyCupertinoTabPageState extends State<MyCupertinoTabPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    Center(child: LegacyText('首页'.tr)),
    Center(child: LegacyText('搜索'.tr)),
    Center(child: LegacyText('我的'.tr)),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '首页'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: '搜索'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: '我的'.tr,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (_) => _tabs[index]);
      },
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Cupertino');
