// 独立运行：flutter run -t "lib/demos/手势解锁/手势解锁.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: PatternUnlockDemo()));

class PatternUnlockDemo extends StatefulWidget {
  const PatternUnlockDemo({super.key});
  @override
  State<PatternUnlockDemo> createState() => _PatternUnlockDemoState();
}

class _PatternUnlockDemoState extends State<PatternUnlockDemo> {
  final List<int> _path = [];
  List<int>? _saved;
  Offset? _pointer;
  String _status = '连接至少四个点';
  Offset _point(int index, double side) =>
      Offset((index % 3 + .5) * side / 3, (index ~/ 3 + .5) * side / 3);
  void _move(Offset point, double side) {
    setState(() {
      _pointer = point;
      for (int i = 0; i < 9; i++) {
        if ((point - _point(i, side)).distance > side / 10 ||
            _path.contains(i)) {
          continue;
        }
        if (_path.isNotEmpty) {
          final last = _path.last;
          final dx = i % 3 - last % 3;
          final dy = i ~/ 3 - last ~/ 3;
          if (dx.abs() % 2 == 0 && dy.abs() % 2 == 0) {
            final middle = (i + last) ~/ 2;
            if (!_path.contains(middle)) _path.add(middle);
          }
        }
        _path.add(i);
      }
    });
  }

  void _finish() {
    setState(() {
      _pointer = null;
      if (_path.length < 4) {
        _status = '连接至少四个点';
        _path.clear();
        return;
      }
      if (_saved == null) {
        _saved = List.of(_path);
        _status = '再次绘制图案';
      } else {
        _status = _path.join(',') == _saved!.join(',') ? '已解锁' : '图案不匹配';
      }
      _path.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(tr(context, '手势解锁'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          tr(context, _status),
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final side = min(constraints.maxWidth, 360.0);
            return Center(
              child: Semantics(
                label: tr(context, '手势解锁'),
                child: GestureDetector(
                  onPanDown: (event) {
                    _path.clear();
                    _move(event.localPosition, side);
                  },
                  onPanUpdate: (event) => _move(event.localPosition, side),
                  onPanEnd: (_) => _finish(),
                  onPanCancel: () => setState(() {
                    _pointer = null;
                    _path.clear();
                  }),
                  child: CustomPaint(
                    key: const ValueKey('pattern-canvas'),
                    size: Size.square(side),
                    painter: _PatternPainter(
                      List.of(_path),
                      _pointer,
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => setState(() {
            _path.clear();
            _saved = null;
            _status = '连接至少四个点';
          }),
          child: Text(tr(context, '恢复默认')),
        ),
      ],
    ),
  );
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter(this.path, this.pointer, this.active, this.inactive);
  final List<int> path;
  final Offset? pointer;
  final Color active;
  final Color inactive;
  Offset _point(int index, Size size) => Offset(
    (index % 3 + .5) * size.width / 3,
    (index ~/ 3 + .5) * size.height / 3,
  );
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = active
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i < path.length; i++) {
      canvas.drawLine(_point(path[i - 1], size), _point(path[i], size), line);
    }
    if (path.isNotEmpty && pointer != null) {
      canvas.drawLine(_point(path.last, size), pointer!, line);
    }
    for (int i = 0; i < 9; i++) {
      canvas.drawCircle(
        _point(i, size),
        13,
        Paint()..color = path.contains(i) ? active : inactive,
      );
      if (path.contains(i)) {
        canvas.drawCircle(
          _point(i, size),
          25,
          Paint()..color = active.withValues(alpha: .15),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => true;
}
