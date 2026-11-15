import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class CutoutMaskDemo extends StatefulWidget {
  const CutoutMaskDemo({super.key});
  @override
  State<CutoutMaskDemo> createState() => _CutoutState();
}

class _CutoutState extends State<CutoutMaskDemo> {
  Offset position = const Offset(.5, .5);
  double radius = 70;
  bool circle = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '镂空遮罩'))),
    body: Column(
      children: [
        Slider(
          value: radius,
          min: 20,
          max: 140,
          onChanged: (v) => setState(() => radius = v),
        ),
        SwitchListTile(
          title: Text(uiTr(context, '角度')),
          value: circle,
          onChanged: (v) => setState(() => circle = v),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => GestureDetector(
              onPanDown: (e) => setState(
                () => position = Offset(
                  e.localPosition.dx / c.maxWidth,
                  e.localPosition.dy / c.maxHeight,
                ),
              ),
              onPanUpdate: (e) => setState(
                () => position = Offset(
                  e.localPosition.dx / c.maxWidth,
                  e.localPosition.dy / c.maxHeight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/Images/flower.png', fit: BoxFit.cover),
                  CustomPaint(
                    painter: _MaskPainter(
                      position,
                      radius,
                      circle,
                      Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _MaskPainter extends CustomPainter {
  _MaskPainter(this.position, this.radius, this.circle, this.color);
  final Offset position;
  final double radius;
  final bool circle;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(position.dx * size.width, position.dy * size.height);
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    if (circle) {
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    } else {
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * 1.4,
          ),
          const Radius.circular(16),
        ),
      );
    }
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: .94));
  }

  @override
  bool shouldRepaint(_MaskPainter old) => true;
}

void main() => runApp(const JobsDemoApp(home: CutoutMaskDemo(), title: '镂空遮罩'));
