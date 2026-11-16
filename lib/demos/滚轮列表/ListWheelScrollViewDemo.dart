// 独立运行：flutter run -t "lib/demos/滚轮列表/ListWheelScrollViewDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '滚轮列表');

// 公共测试器路径

// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    ListWheelScrollViewDemo(),
    title: 'ListWheelScrollView Demo',
  ),
);

class ListWheelScrollViewDemo extends StatelessWidget {
  const ListWheelScrollViewDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView(
      itemExtent: 50,
      children: List.generate(
        20,
        (index) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(itemIndex: index),
              ),
            );
          },
          child: Container(
            color: Colors.teal[100 * (index % 9)],
            child: Center(child: LegacyText('Item $index')),
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final int itemIndex;

  const DetailPage({super.key, required this.itemIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(
        title: LegacyText('Detail Page - Item $itemIndex'),
      ),
      body: Center(child: LegacyText('Detail Page - Item $itemIndex')),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('滚轮列表')),
    body: SafeArea(child: const ListWheelScrollViewDemo()),
  ),
);
