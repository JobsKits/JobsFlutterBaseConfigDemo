// 独立运行：flutter run -t "lib/demos/迟滞霓虹滑块/迟滞霓虹滑块.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

import '../../demo_hub/geometry_strings.dart';

void main() {
  registerGeometryTranslations();
  runApp(const JobsDemoApp(home: HysteresisSliderPage()));
}

class HysteresisSliderPage extends StatefulWidget {
  const HysteresisSliderPage({super.key});
  @override
  State<HysteresisSliderPage> createState() => _HysteresisState();
}

class _HysteresisState extends State<HysteresisSliderPage> {
  final gate = HysteresisGate();
  double value = .34, flash = 0;
  void change(double v) => setState(() {
    value = v;
    if (gate.update(v)) {
      flash = MediaQuery.disableAnimationsOf(context) ? 0 : 1;
    }
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(geometryTr(context, '迟滞霓虹滑块'))),
    body: JobsGeometryLabLayout(
      canvas: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            JobsGeometryClock(
              paused: flash <= 0,
              onTick: (dt) {
                if (flash > 0) {
                  flash = (flash - dt / .7).clamp(0, 1);
                  if (flash == 0 && mounted) setState(() {});
                }
              },
              builder: (context, elapsed) => JobsNeonSlider(
                value: value,
                onChanged: change,
                flash: MediaQuery.disableAnimationsOf(context) ? 0 : flash,
                semanticLabel: geometryTr(context, '数值'),
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Text(
                '${geometryTr(context, '触发次数')}: ${gate.count} · ${geometryTr(context, gate.armed ? '已就绪' : '等待复位')}',
              ),
            ),
          ],
        ),
      ),
      controls: [
        Text(geometryTr(context, '达到99%触发，低于90%重新就绪')),
        JobsGeometryParameter(
          label: geometryTr(context, '数值'),
          value: value,
          valueLabel: '${(value * 100).round()}%',
          onChanged: change,
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final v in [.89, .95, .99, 1.0])
              OutlinedButton(
                onPressed: () => change(v),
                child: Text('${(v * 100).round()}%'),
              ),
            TextButton(
              onPressed: () => setState(() {
                gate.reset();
                value = .34;
                flash = 0;
              }),
              child: Text(geometryTr(context, '重置')),
            ),
          ],
        ),
        Text(geometryTr(context, '拖动画布或使用控件；方向键可调节聚焦滑块')),
      ],
    ),
  );
}
