import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class BoundedDockDemo extends StatefulWidget {
  const BoundedDockDemo({super.key});
  @override
  State<BoundedDockDemo> createState() => _DockState();
}

class _DockState extends State<BoundedDockDemo> {
  double top = .15, bottom = .85;
  Offset point = const Offset(20, 80);
  bool dragging = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '区间拖动吸边'))),
    body: Column(
      children: [
        Text(
          '${uiTr(context, '范围')}: ${(top * 100).round()}–${(bottom * 100).round()}%',
        ),
        RangeSlider(
          values: RangeValues(top, bottom),
          min: 0,
          max: 1,
          divisions: 20,
          onChanged: (v) => setState(() {
            top = v.start;
            bottom = math.max(v.end, v.start + .05).clamp(0, 1);
          }),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              const extent = 56.0;
              final minY = top * math.max(0, c.maxHeight - extent),
                  maxY = bottom * math.max(0, c.maxHeight - extent);
              final current = Offset(
                point.dx.clamp(0, math.max(0, c.maxWidth - extent)),
                point.dy.clamp(minY, maxY),
              );
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: minY,
                    height: math.max(1, maxY - minY + extent),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: dragging
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    left: current.dx,
                    top: current.dy,
                    child: GestureDetector(
                      onPanStart: (_) => setState(() => dragging = true),
                      onPanUpdate: (e) => setState(
                        () => point = Offset(
                          (current.dx + e.delta.dx).clamp(
                            0,
                            math.max(0, c.maxWidth - extent),
                          ),
                          (current.dy + e.delta.dy).clamp(minY, maxY),
                        ),
                      ),
                      onPanEnd: (_) => setState(() {
                        dragging = false;
                        point = Offset(
                          current.dx < c.maxWidth / 2 ? 0 : c.maxWidth - extent,
                          current.dy,
                        );
                      }),
                      child: Container(
                        width: extent,
                        height: extent,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Icon(
                          Icons.open_with,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: BoundedDockDemo(), title: '区间拖动吸边'));
