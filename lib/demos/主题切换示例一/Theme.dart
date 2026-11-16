// 独立运行：flutter run -t "lib/demos/主题切换示例一/Theme.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '主题切换示例一');

// 公共测试器路径

// 在 Flutter 中，主题（Theme）是一个用于定义应用程序整体视觉外观和感觉的工具。
// 通过主题，你可以定义应用程序的颜色、字体、图标样式等。
// 使用主题可以使你的应用程序在不同页面和组件之间保持一致的视觉风格。
void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(MyApp(), title: 'Home Screen'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LegacyText(
            'Hello, World!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const LegacyText('Press Me')),
          const SizedBox(height: 20),
          LegacyText(
            'Secondary Text',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Theme');
