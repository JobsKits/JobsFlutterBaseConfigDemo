// 独立运行：flutter run -t "lib/demos/多子组件布局代理/CustomMultiChildLayout.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '多子组件布局代理');

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    CustomLayoutApp(),
    title: '📐 CustomMultiChildLayout 示例',
  ),
);

class CustomLayoutApp extends StatelessWidget {
  const CustomLayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomMultiChildLayout(
        delegate: MyCustomLayoutDelegate(),
        children: [
          LayoutId(id: 'topLeft', child: box(Colors.red, '左上')),
          LayoutId(id: 'topRight', child: box(Colors.green, '右上')),
          LayoutId(id: 'bottomCenter', child: box(Colors.blue, '下中')),
        ],
      ),
    );
  }

  static Widget box(Color color, String label) {
    return Container(
      width: 80,
      height: 50,
      color: color,
      alignment: Alignment.center,
      child: LegacyText(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

/// 具体的布局逻辑
class MyCustomLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    if (hasChild('topLeft')) {
      layoutChild(
        'topLeft',
        const BoxConstraints.tightFor(width: 80, height: 50),
      );
      positionChild('topLeft', const Offset(0, 0));
    }

    if (hasChild('topRight')) {
      layoutChild(
        'topRight',
        const BoxConstraints.tightFor(width: 80, height: 50),
      );
      positionChild('topRight', Offset(size.width - 80, 0));
    }

    if (hasChild('bottomCenter')) {
      layoutChild(
        'bottomCenter',
        const BoxConstraints.tightFor(width: 100, height: 60),
      );
      positionChild(
        'bottomCenter',
        Offset((size.width - 100) / 2, size.height - 60),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('多子组件布局代理'),
    ),
    body: SafeArea(child: const CustomLayoutApp()),
  ),
);
