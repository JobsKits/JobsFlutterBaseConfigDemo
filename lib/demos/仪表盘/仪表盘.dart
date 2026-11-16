// 独立运行：flutter run -t "lib/demos/仪表盘/仪表盘.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

void main() =>
    runApp(const JobsDemoApp(home: GaugeDashboardDemo(), title: '仪表盘'));

class GaugeDashboardDemo extends StatefulWidget {
  const GaugeDashboardDemo({super.key});
  @override
  State<GaugeDashboardDemo> createState() => _GaugeState();
}

class _GaugeState extends State<GaugeDashboardDemo> {
  double value = 42;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '仪表盘'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AspectRatio(
          aspectRatio: 1.25,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: value),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, _) => CustomPaint(
              painter: _GaugePainter(value, Theme.of(context).colorScheme),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (v) => setState(() => value = v),
        ),
        LinearProgressIndicator(value: value / 100, minHeight: 12),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          children: [
            FilledButton(
              onPressed: () =>
                  setState(() => value = math.Random().nextDouble() * 100),
              child: Text(uiTr(context, '生成')),
            ),
            OutlinedButton(
              onPressed: () => setState(() => value = 0),
              child: Text(uiTr(context, '重置')),
            ),
          ],
        ),
      ],
    ),
  );
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.colors);
  final double value;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .65);
    final r = math.min(size.width * .42, size.height * .58);
    final rect = Rect.fromCircle(center: center, radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawArc(
      rect,
      math.pi * .8,
      math.pi * 1.4,
      false,
      paint..color = colors.surfaceContainerHighest,
    );
    canvas.drawArc(
      rect,
      math.pi * .8,
      math.pi * 1.4 * value / 100,
      false,
      paint..color = colors.primary,
    );
    for (var i = 0; i <= 10; i++) {
      final a = math.pi * .8 + math.pi * 1.4 * i / 10;
      canvas.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * (r - 20),
        center + Offset(math.cos(a), math.sin(a)) * (r - 29),
        Paint()
          ..color = colors.onSurface
          ..strokeWidth = 2,
      );
    }
    final a = math.pi * .8 + math.pi * 1.4 * value / 100;
    canvas.drawLine(
      center,
      center + Offset(math.cos(a), math.sin(a)) * (r - 35),
      Paint()
        ..color = colors.tertiary
        ..strokeWidth = 5,
    );
    canvas.drawCircle(center, 8, Paint()..color = colors.primary);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.colors != colors;
}
