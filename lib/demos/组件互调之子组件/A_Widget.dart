// 独立运行：flutter run -t "lib/demos/组件互调之子组件/A_Widget.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '组件互调之子组件');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    A_Widget(),
    title: 'Betting Casino My Bet List View',
  ),
);

// ignore: camel_case_types
class A_Widget extends StatelessWidget {
  const A_Widget({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: buildTextWidget());
  }

  Widget buildTextWidget() {
    return const LegacyText(
      'Hello from A_Widget!',
      style: TextStyle(fontSize: 20, color: Colors.blue),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'A_Widget');
