// 独立运行：flutter run -t "lib/demos/横向分页滚动/PageViewDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '横向分页滚动');

// 公共测试器路径

// 水平滚动的时候，一格一格的滚动，滚动距离为设备宽度，高度随内容变化；有弹簧效果
// 垂直滚动的时候，一格一格的滚动，滚动距离为设备高度，宽度随内容变化；有弹簧效果

// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(PageViewDemo(), title: 'PageView Demo'),
);

class PageViewDemo extends StatelessWidget {
  const PageViewDemo({super.key, this.isVertical = true});
  final bool isVertical;
  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
      pageSnapping: true,
      children: List.generate(
        3,
        (index) => Container(
          color: index % 2 == 0 ? Colors.red : Colors.blue,
          child: Center(child: LegacyText('Page ${index + 1}')),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('横向分页滚动')),
    body: SafeArea(child: const PageViewDemo(isVertical: false)),
  ),
);
