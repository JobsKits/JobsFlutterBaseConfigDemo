// 独立运行：flutter run -t "lib/demos/矩阵坐标实验/矩阵坐标实验.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

import '../../demo_hub/geometry_strings.dart';

void main() {
  registerGeometryTranslations();
  runApp(const JobsDemoApp(home: MatrixCoordinatesPage()));
}

class MatrixCoordinatesPage extends StatefulWidget {
  const MatrixCoordinatesPage({super.key});
  @override
  State<MatrixCoordinatesPage> createState() => _MatrixState();
}

class _MatrixState extends State<MatrixCoordinatesPage> {
  double dx = 0, dy = 0, scale = 1, rotation = 0;
  Offset? screen, local;
  int? selected;
  CanvasTransform get transform => CanvasTransform(
    translation: Offset(dx, dy),
    scale: scale,
    rotation: rotation,
  );
  static const shapes = [
    Rect.fromLTWH(-115, -75, 95, 110),
    Rect.fromLTWH(20, -35, 95, 110),
  ];
  String coordinates(Offset? p) => p == null
      ? '—'
      : '(${p.dx.toStringAsFixed(1)}, ${p.dy.toStringAsFixed(1)})';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(geometryTr(context, '矩阵坐标实验'))),
    body: JobsGeometryLabLayout(
      canvas: LayoutBuilder(
        builder: (context, c) => JobsGeometryCanvas(
          semanticLabel: geometryTr(context, '矩阵坐标实验'),
          onPan: (delta) => setState(() {
            dx = (dx + delta.dx).clamp(-180, 180);
            dy = (dy + delta.dy).clamp(-180, 180);
            screen = null;
            local = null;
          }),
          onTap: (point) => setState(() {
            screen = point;
            local = transform.inversePoint(
              point,
              c.biggest.center(Offset.zero),
            );
            selected = null;
            if (local != null) {
              for (var i = 0; i < shapes.length; i++) {
                if (shapes[i].contains(local!)) selected = i;
              }
            }
          }),
          painter: _MatrixPainter(
            transform,
            shapes,
            selected,
            screen,
            Theme.of(context).colorScheme,
          ),
        ),
      ),
      controls: [
        Text(
          '${geometryTr(context, '屏幕坐标')}: ${coordinates(screen)}\n${geometryTr(context, '局部坐标')}: ${coordinates(local)}\n${geometryTr(context, '选中项目')}: ${selected == null ? '—' : selected! + 1}',
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '水平位移'),
          value: dx,
          min: -180,
          max: 180,
          onChanged: (v) => setState(() {
            dx = v;
            screen = null;
            local = null;
          }),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '垂直位移'),
          value: dy,
          min: -180,
          max: 180,
          onChanged: (v) => setState(() {
            dy = v;
            screen = null;
            local = null;
          }),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '缩放'),
          value: scale,
          min: .35,
          max: 2,
          onChanged: (v) => setState(() {
            scale = v;
            screen = null;
            local = null;
          }),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '旋转'),
          value: rotation,
          min: -math.pi,
          max: math.pi,
          valueLabel: '${(rotation * 180 / math.pi).round()}°',
          onChanged: (v) => setState(() {
            rotation = v;
            screen = null;
            local = null;
          }),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < 2; i++)
              OutlinedButton(
                onPressed: () => setState(() {
                  selected = i;
                  local = shapes[i].center;
                  screen = null;
                }),
                child: Text('${geometryTr(context, '选中项目')} ${i + 1}'),
              ),
            TextButton(
              onPressed: () => setState(() {
                dx = 0;
                dy = 0;
                scale = 1;
                rotation = 0;
                selected = null;
                screen = null;
                local = null;
              }),
              child: Text(geometryTr(context, '重置')),
            ),
          ],
        ),
        SelectableText(
          transform.matrix.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _MatrixPainter extends CustomPainter {
  _MatrixPainter(
    this.transform,
    this.shapes,
    this.selected,
    this.pointer,
    this.colors,
  );
  final CanvasTransform transform;
  final List<Rect> shapes;
  final int? selected;
  final Offset? pointer;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final grid = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    grid.color = colors.outline;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), grid);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), grid);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.transform(transform.matrix.storage);
    for (var i = 0; i < shapes.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(shapes[i], const Radius.circular(12)),
        Paint()
          ..color = selected == i ? colors.primary : colors.secondaryContainer,
      );
      final text = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            fontSize: 24,
            color: selected == i
                ? colors.onPrimary
                : colors.onSecondaryContainer,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        shapes[i].center - Offset(text.width / 2, text.height / 2),
      );
      text.dispose();
    }
    canvas.restore();
    if (pointer != null) {
      canvas.drawCircle(pointer!, 6, Paint()..color = colors.error);
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter old) => true;
}
