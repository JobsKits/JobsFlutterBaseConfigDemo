// 独立运行：flutter run -t "lib/demos/单子组件布局代理/CustomSingleChildLayout.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '单子组件布局代理');

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    CustomSingleLayoutApp(),
    title: '📐 CustomSingleChildLayout 示例',
  ),
);

class CustomSingleLayoutApp extends StatelessWidget {
  const CustomSingleLayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      color: Colors.grey.shade300,
      child: CustomSingleChildLayout(
        delegate: MySingleChildDelegate(),
        child: Container(
          width: 100,
          height: 60,
          color: Colors.blue,
          alignment: Alignment.center,
          child: const LegacyText(
            'Hello',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class MySingleChildDelegate extends SingleChildLayoutDelegate {
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // 子组件放在底部中间
    return Offset(
      (size.width - childSize.width) / 2,
      size.height - childSize.height,
    );
  }

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => false;
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('单子组件布局代理'),
    ),
    body: SafeArea(child: const Center(child: CustomSingleLayoutApp())),
  ),
);
