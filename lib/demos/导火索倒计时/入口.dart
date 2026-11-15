import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class FuseCountdownDemo extends StatefulWidget {
  const FuseCountdownDemo({super.key});
  @override
  State<FuseCountdownDemo> createState() => _FuseState();
}

class _FuseState extends State<FuseCountdownDemo> {
  final watch = Stopwatch();
  Timer? timer;
  double duration = 10;
  double elapsed = 0;
  void tick() {
    if (!mounted) return;
    setState(() => elapsed = watch.elapsedMilliseconds / 1000);
    if (elapsed >= duration) {
      timer?.cancel();
      watch.stop();
    }
  }

  void start() {
    if (elapsed >= duration) {
      watch.reset();
      elapsed = 0;
    }
    watch.start();
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) => tick());
    setState(() {});
  }

  void reset() {
    timer?.cancel();
    watch.stop();
    watch.reset();
    setState(() => elapsed = 0);
  }

  @override
  void dispose() {
    timer?.cancel();
    watch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '导火索倒计时'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _FusePainter(
              (elapsed / duration).clamp(0, 1),
              Theme.of(context).colorScheme,
            ),
            child: Center(
              child: Text(
                '${(duration - elapsed).clamp(0, duration).toStringAsFixed(1)} s',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ),
        Slider(
          value: duration,
          min: 1,
          max: 60,
          divisions: 59,
          onChanged: watch.isRunning
              ? null
              : (v) {
                  reset();
                  setState(() => duration = v);
                },
        ),
        LinearProgressIndicator(value: (elapsed / duration).clamp(0, 1)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: start, child: Text(uiTr(context, '开始'))),
            OutlinedButton(
              onPressed: () {
                watch.stop();
                timer?.cancel();
                setState(() {});
              },
              child: Text(uiTr(context, '暂停')),
            ),
            TextButton(onPressed: reset, child: Text(uiTr(context, '重置'))),
          ],
        ),
      ],
    ),
  );
}

class _FusePainter extends CustomPainter {
  _FusePainter(this.progress, this.colors);
  final double progress;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(22)),
      );
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      path,
      Paint()
        ..color = colors.surfaceContainerHighest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    canvas.drawPath(
      metric.extractPath(metric.length * progress, metric.length),
      Paint()
        ..color = colors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    final t = metric.getTangentForOffset(metric.length * progress);
    if (t != null)
      canvas.drawCircle(t.position, 9, Paint()..color = colors.tertiary);
  }

  @override
  bool shouldRepaint(_FusePainter old) =>
      old.progress != progress || old.colors != colors;
}

void main() =>
    runApp(const JobsDemoApp(home: FuseCountdownDemo(), title: '导火索倒计时'));
