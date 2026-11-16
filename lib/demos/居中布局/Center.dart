// 独立运行：flutter run -t "lib/demos/居中布局/Center.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '居中布局');

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(CenterDemo(), title: 'Center 属性演示'),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CenterDemo();
  }
}

class CenterDemo extends StatelessWidget {
  const CenterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        widthFactor: 2.0, // 宽度为 child 的 2 倍
        heightFactor: 3.0, // 高度为 child 的 3 倍
        child: Container(
          color: Colors.blue,
          width: 80,
          height: 80,
          child: const Center(
            child: LegacyText('居中', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('居中布局')),
    body: SafeArea(child: const CenterDemo()),
  ),
);
