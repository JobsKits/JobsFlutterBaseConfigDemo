// 独立运行：flutter run -t "lib/demos/模拟时钟/模拟时钟.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/extra_support.dart';

void main() => runApp(const JobsDemoApp(home: AnalogClockLabDemo()));

class AnalogClockLabDemo extends StatefulWidget {
  const AnalogClockLabDemo({super.key});
  @override
  State<AnalogClockLabDemo> createState() => _State();
}

class _State extends State<AnalogClockLabDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController ticker =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..addListener(tick)
        ..repeat();
  DateTime time = DateTime.now();
  DateTime last = DateTime.now();
  double speed = 1;
  bool running = true;
  void tick() {
    final now = DateTime.now();
    if (running)
      time = time.add(
        Duration(
          microseconds: ((now.difference(last).inMicroseconds) * speed).round(),
        ),
      );
    last = now;
    setState(() {});
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExtraFrame(
    title: '模拟时钟',
    children: [
      SizedBox(height: 300, child: JobsAnalogClock(time: time)),
      Text(
        time.toIso8601String().split('T').last.split('.').first,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      SwitchListTile(
        title: Text(extraTr(context, '开始暂停')),
        value: running,
        onChanged: (v) => setState(() => running = v),
      ),
      Text('${extraTr(context, '方向与速度')}：${speed.toStringAsFixed(1)}×'),
      Slider(
        min: -6,
        max: 6,
        divisions: 24,
        value: speed,
        onChanged: (v) => setState(() => speed = v),
      ),
      FilledButton(
        onPressed: () => setState(() => time = DateTime.now()),
        child: Text(extraTr(context, '同步系统时间')),
      ),
    ],
  );
}
