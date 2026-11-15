import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: FloatingClockDemo()));

class FloatingClockDemo extends StatefulWidget {
  const FloatingClockDemo({super.key});
  @override
  State<FloatingClockDemo> createState() => _FloatingClockDemoState();
}

class _FloatingClockDemoState extends State<FloatingClockDemo> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  Offset _position = const Offset(24, 180);
  bool _visible = true;
  bool _dragging = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Offset _clamp(Offset value, Size size) => Offset(
    value.dx.clamp(0, (size.width - 150).clamp(0, double.infinity)),
    value.dy.clamp(0, (size.height - 72).clamp(0, double.infinity)),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '悬浮时钟'))),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final position = _clamp(_position, size);
        final time = [
          _now.hour,
          _now.minute,
          _now.second,
        ].map((value) => value.toString().padLeft(2, '0')).join(':');
        return Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    tr(context, '拖动时钟，松手吸附边缘'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton.tonal(
                        onPressed: () => setState(() => _visible = !_visible),
                        child: Text(tr(context, _visible ? '隐藏' : '显示')),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          _position = const Offset(24, 180);
                          _visible = true;
                        }),
                        child: Text(tr(context, '恢复默认')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_visible)
              AnimatedPositioned(
                duration: _dragging
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                left: position.dx,
                top: _clamp(_position, size).dy,
                child: GestureDetector(
                  onPanStart: (_) => setState(() {
                    _dragging = true;
                    _position = _clamp(_position, size);
                  }),
                  onPanCancel: () => setState(() => _dragging = false),
                  onPanUpdate: (event) => setState(
                    () => _position = _clamp(_position + event.delta, size),
                  ),
                  onPanEnd: (_) => setState(() {
                    _dragging = false;
                    _position = Offset(
                      _position.dx + 75 < size.width / 2
                          ? 0
                          : (size.width - 150).clamp(0, double.infinity),
                      _clamp(_position, size).dy,
                    );
                  }),
                  child: Semantics(
                    key: const ValueKey('floating-clock'),
                    label: tr(context, '悬浮时钟'),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(22),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: SizedBox(
                        width: 150,
                        height: 72,
                        child: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
