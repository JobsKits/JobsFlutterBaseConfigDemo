// 独立运行：flutter run -t "lib/demos/透视螺旋列表/透视螺旋列表.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

import '../../demo_hub/geometry_strings.dart';

void main() {
  registerGeometryTranslations();
  runApp(const JobsDemoApp(home: PerspectiveSpiralPage()));
}

class PerspectiveSpiralPage extends StatefulWidget {
  const PerspectiveSpiralPage({super.key});
  @override
  State<PerspectiveSpiralPage> createState() => _SpiralState();
}

class _SpiralState extends State<PerspectiveSpiralPage> {
  double offset = 14, radius = 100, pitch = 90, twist = .7;
  int? selected;
  SpiralGeometry get geometry =>
      SpiralGeometry(radius: radius, pitch: pitch, twist: twist);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(geometryTr(context, '透视螺旋列表'))),
    body: JobsGeometryLabLayout(
      canvas: LayoutBuilder(
        builder: (context, c) {
          final tiles = geometry.layout(c.biggest, offset);
          return JobsGeometryCanvas(
            semanticLabel: geometryTr(context, '透视螺旋列表'),
            onPan: (delta) => setState(
              () => offset = (offset - delta.dy / pitch).clamp(0, 29),
            ),
            onTap: (point) =>
                setState(() => selected = geometry.hitTest(tiles, point)),
            painter: _SpiralPainter(
              tiles,
              selected,
              Theme.of(context).colorScheme,
            ),
          );
        },
      ),
      controls: [
        Text(
          '${geometryTr(context, '选中项目')}: ${selected == null ? '—' : selected! + 1}',
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '位置'),
          value: offset,
          min: 0,
          max: 29,
          onChanged: (v) => setState(() => offset = v),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '半径'),
          value: radius,
          min: 0,
          max: 160,
          onChanged: (v) => setState(() => radius = v),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '间距'),
          value: pitch,
          min: 45,
          max: 150,
          onChanged: (v) => setState(() => pitch = v),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '扭曲度'),
          value: twist,
          min: 0,
          max: 1.2,
          onChanged: (v) => setState(() => twist = v),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: () => setState(() {
                offset = (offset - 1).clamp(0, 29);
                selected = offset.round();
              }),
              child: Text(geometryTr(context, '前一项')),
            ),
            FilledButton(
              onPressed: () => setState(() {
                offset = (offset + 1).clamp(0, 29);
                selected = offset.round();
              }),
              child: Text(geometryTr(context, '后一项')),
            ),
            TextButton(
              onPressed: () => setState(() {
                offset = 14;
                radius = 100;
                pitch = 90;
                twist = .7;
                selected = null;
              }),
              child: Text(geometryTr(context, '重置')),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SpiralPainter extends CustomPainter {
  _SpiralPainter(this.tiles, this.selected, this.colors);
  final List<SpiralTile> tiles;
  final int? selected;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    for (final tile in tiles) {
      final chosen = tile.index == selected;
      canvas.drawPath(
        tile.path,
        Paint()
          ..color = chosen
              ? colors.primary
              : Color.lerp(
                  colors.secondaryContainer,
                  colors.primaryContainer,
                  ((tile.depth + 200) / 400).clamp(0, 1),
                )!,
      );
      canvas.drawPath(
        tile.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = chosen ? 3 : 1
          ..color = chosen ? colors.onPrimary : colors.outline,
      );
      final text = TextPainter(
        text: TextSpan(
          text: '${tile.index + 1}',
          style: TextStyle(
            color: chosen ? colors.onPrimary : colors.onPrimaryContainer,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        tile.bounds.center - Offset(text.width / 2, text.height / 2),
      );
      text.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _SpiralPainter old) => true;
}
