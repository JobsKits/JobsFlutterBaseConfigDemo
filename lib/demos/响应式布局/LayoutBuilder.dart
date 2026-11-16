// 独立运行：flutter run -t "lib/demos/响应式布局/LayoutBuilder.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '响应式布局');

// 根据父小部件的大小动态构建布局：
// LayoutBuilder 被用作 Container 的子小部件。
// LayoutBuilder 的 builder 方法提供一个 BuildContext 和 BoxConstraints 对象。
// 根据 BoxConstraints 的 maxWidth 属性，决定显示不同的子小部件：
// 如果 maxWidth 大于 200，显示绿色背景的 Container，并显示文本 "Large Container"。
// 如果 maxWidth 小于或等于 200，显示红色背景的 Container，并显示文本 "Small Container"。
// 外层 Container 设置了宽度和高度为 300，用于测试目的。
// 通过这种方式，您可以根据父小部件的大小动态地构建不同的布局。
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(LayoutBuilderDemo(), title: 'LayoutBuilder Demo'),
);

class LayoutBuilderDemo extends StatelessWidget {
  const LayoutBuilderDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        color: Colors.grey[300],
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 200) {
              return Container(
                color: Colors.green,
                child: const Center(
                  child: LegacyText(
                    'Large Container',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else {
              return Container(
                color: Colors.red,
                child: const Center(
                  child: LegacyText(
                    'Small Container',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('响应式布局')),
    body: SafeArea(child: const LayoutBuilderDemo()),
  ),
);
