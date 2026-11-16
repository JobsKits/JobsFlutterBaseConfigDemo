// 独立运行：flutter run -t "lib/demos/圆弧拖动进度/圆弧拖动进度.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

import '../../demo_hub/geometry_strings.dart';

void main() {
  registerGeometryTranslations();
  runApp(const JobsDemoApp(home: ArcProgressPage()));
}

class ArcProgressPage extends StatefulWidget {
  const ArcProgressPage({super.key});
  @override
  State<ArcProgressPage> createState() => _ArcProgressState();
}

class _ArcProgressState extends State<ArcProgressPage> {
  double value = .35, gap = 120, rotation = 90;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(geometryTr(context, '圆弧拖动进度'))),
    body: JobsGeometryLabLayout(
      canvas: JobsArcSlider(
        value: value,
        onChanged: (v) => setState(() => value = v),
        semanticLabel: geometryTr(context, '数值'),
        geometry: ArcGeometry(
          gap: gap * math.pi / 180,
          rotation: rotation * math.pi / 180,
        ),
      ),
      controls: [
        Text(geometryTr(context, '拖动画布或使用控件；方向键可调节聚焦滑块')),
        JobsGeometryParameter(
          label: geometryTr(context, '数值'),
          value: value,
          valueLabel: '${(value * 100).round()}%',
          onChanged: (v) => setState(() => value = v),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '缺口角度'),
          value: gap,
          min: 30,
          max: 300,
          valueLabel: '${gap.round()}°',
          onChanged: (v) => setState(() => gap = v),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '旋转'),
          value: rotation,
          min: 0,
          max: 360,
          valueLabel: '${rotation.round()}°',
          onChanged: (v) => setState(() => rotation = v),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton(
              onPressed: () =>
                  setState(() => value = (value - .02).clamp(0, 1)),
              child: Text(geometryTr(context, '减少')),
            ),
            FilledButton(
              onPressed: () =>
                  setState(() => value = (value + .02).clamp(0, 1)),
              child: Text(geometryTr(context, '增加')),
            ),
            TextButton(
              onPressed: () => setState(() {
                value = .35;
                gap = 120;
                rotation = 90;
              }),
              child: Text(geometryTr(context, '重置')),
            ),
          ],
        ),
      ],
    ),
  );
}
