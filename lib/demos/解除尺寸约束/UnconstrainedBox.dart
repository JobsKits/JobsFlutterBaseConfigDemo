// 独立运行：flutter run -t "lib/demos/解除尺寸约束/UnconstrainedBox.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '解除尺寸约束');

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(MyApp(), title: '📐 UnconstrainedBox 示例'),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        color: Colors.grey[300],
        child: SingleChildScrollView(
          // ✅ 添加滚动防止溢出
          scrollDirection: Axis.horizontal,
          child: UnconstrainedBox(
            child: Container(
              width: 300,
              height: 100,
              color: Colors.blue,
              child: const Center(
                child: LegacyText(
                  '突破父容器但不溢出',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('解除尺寸约束')),
    body: SafeArea(child: const MyApp()),
  ),
);
