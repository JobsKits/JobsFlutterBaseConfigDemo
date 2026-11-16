// 独立运行：flutter run -t "lib/demos/球形点选/球形点选.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/extra_support.dart';

void main() => runApp(const JobsDemoApp(home: SphereLabDemo()));

class SphereLabDemo extends StatefulWidget {
  const SphereLabDemo({super.key});
  @override
  State<SphereLabDemo> createState() => _State();
}

class _State extends State<SphereLabDemo> {
  bool rotate = true;
  int? selected;
  @override
  Widget build(BuildContext context) => ExtraFrame(
    title: '球形点选',
    children: [
      SwitchListTile(
        title: Text(extraTr(context, '自动旋转')),
        value: rotate,
        onChanged: (v) => setState(() => rotate = v),
      ),
      SizedBox(
        height: 360,
        child: JobsPointSphere(
          labels: List.generate(36, (i) => '${i + 1}'),
          autoRotate: rotate,
          onSelected: (i) => setState(() => selected = i),
        ),
      ),
      Text(
        '${extraTr(context, '选中项目')}：${selected == null ? '—' : selected! + 1}',
      ),
    ],
  );
}
