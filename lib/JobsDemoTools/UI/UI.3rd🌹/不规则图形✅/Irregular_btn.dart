import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:vibration/vibration.dart';
import 'dart:math'; // 导入 dart:math 库

void main() => runApp(JobsMaterialRunner(
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CustomShapeButton(
          shape: Shape.triangle,
          onPressed: () {
            debugPrint('我是三角形按钮');
            Vibration.vibrate(duration: 200);
          },
        ),
        const SizedBox(height: 20),
        CustomShapeButton(
          shape: Shape.star,
          onPressed: () {
            debugPrint('我是五角星按钮');
            Vibration.vibrate(duration: 200);
          },
        ),
        const SizedBox(height: 20),
        CustomShapeButton(
          shape: Shape.parallelogram,
          onPressed: () {
            debugPrint('我是平行四边形按钮');
            Vibration.vibrate(duration: 200);
          },
        ),
      ],
    ),
    title: 'Custom Shape Buttons'));

enum Shape { triangle, star, parallelogram }

class CustomShapeButton extends StatefulWidget {
  final Shape shape;
  final VoidCallback onPressed;

  const CustomShapeButton(
      {super.key, required this.shape, required this.onPressed});

  @override
  _CustomShapeButtonState createState() => _CustomShapeButtonState();
}

class _CustomShapeButtonState extends State<CustomShapeButton> {
  bool _isPressed = false;

  void _handleTap() {
    setState(() {
      _isPressed = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isPressed = false;
      });
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isPressed ? 120 : 100,
        height: _isPressed ? 120 : 100,
        child: CustomPaint(
          painter: ShapePainter(widget.shape),
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Shape shape;

  ShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    switch (shape) {
      case Shape.triangle:
        drawTriangle(canvas, size, paint);
        break;
      case Shape.star:
        drawStar(canvas, size, paint);
        break;
      case Shape.parallelogram:
        drawParallelogram(canvas, size, paint);
        break;
    }
  }

  void drawTriangle(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  void drawStar(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;
    const angle = 72 * pi / 180;

    for (int i = 0; i < 5; i++) {
      final outerPoint = Offset(
        size.width / 2 + outerRadius * cos(i * 2 * angle),
        size.height / 2 - outerRadius * sin(i * 2 * angle),
      );
      final innerPoint = Offset(
        size.width / 2 + innerRadius * cos((i * 2 + 1) * angle),
        size.height / 2 - innerRadius * sin((i * 2 + 1) * angle),
      );
      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void drawParallelogram(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
