// 独立运行：flutter run -t "lib/demos/Flutter标志装饰/FlutterLogoDecoration.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'Flutter标志装饰');

// 公共测试器路径

// FlutterLogoDecoration 是一个特殊的装饰类，用于显示 Flutter 的 logo
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(MyApp(), title: 'FlutterLogoDecoration Demo'),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DecoratedBox(
        decoration: FlutterLogoDecoration(),
        child: SizedBox(width: 200, height: 200),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'FlutterLogoDecoration',
);
