import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class LikeRainDemo extends StatefulWidget {
  const LikeRainDemo({super.key});
  @override
  State<LikeRainDemo> createState() => _LikeRainState();
}

class _LikeRainState extends State<LikeRainDemo>
    with SingleTickerProviderStateMixin {
  late final frames = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  final particles = <({double x, double birth, bool rain})>[];
  final clock = Stopwatch()..start();
  Timer? hold;
  int likes = 0;
  int caught = 0;
  void add(bool rain) {
    if (!mounted) return;
    setState(() {
      if (particles.length > 80) particles.removeAt(0);
      particles.add((
        x: math.Random().nextDouble(),
        birth: clock.elapsedMilliseconds / 1000,
        rain: rain,
      ));
      if (!rain) likes++;
    });
  }

  @override
  void dispose() {
    hold?.cancel();
    frames.dispose();
    clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '点赞与红包雨'))),
    body: LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          AnimatedBuilder(
            animation: frames,
            builder: (context, _) => Stack(
              children: [
                for (final p in particles)
                  if (clock.elapsedMilliseconds / 1000 - p.birth < 3)
                    Positioned(
                      left: p.x * (c.maxWidth - 48),
                      top: p.rain
                          ? ((clock.elapsedMilliseconds / 1000 - p.birth) / 3) *
                                (c.maxHeight - 60)
                          : (1 -
                                    (clock.elapsedMilliseconds / 1000 -
                                            p.birth) /
                                        3) *
                                (c.maxHeight - 110),
                      child: Opacity(
                        opacity:
                            (1 -
                                    (clock.elapsedMilliseconds / 1000 -
                                            p.birth) /
                                        3)
                                .clamp(0, 1),
                        child: IconButton(
                          onPressed: p.rain
                              ? () {
                                  setState(() {
                                    particles.remove(p);
                                    caught++;
                                  });
                                }
                              : null,
                          icon: Icon(
                            p.rain ? Icons.redeem : Icons.favorite,
                            size: 36,
                            color: p.rain
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('♥ $likes    ${uiTr(context, '成功')}: $caught'),
                Wrap(
                  spacing: 12,
                  children: [
                    GestureDetector(
                      onLongPressStart: (_) {
                        add(false);
                        hold = Timer.periodic(
                          const Duration(milliseconds: 130),
                          (_) => add(false),
                        );
                      },
                      onLongPressEnd: (_) => hold?.cancel(),
                      onLongPressCancel: () => hold?.cancel(),
                      child: FilledButton(
                        onPressed: () => add(false),
                        child: const Icon(Icons.favorite),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        for (var i = 0; i < 20; i++) add(true);
                      },
                      child: const Icon(Icons.redeem),
                    ),
                    OutlinedButton(
                      onPressed: () => setState(particles.clear),
                      child: Text(uiTr(context, '清空')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void main() => runApp(const JobsDemoApp(home: LikeRainDemo(), title: '点赞与红包雨'));
