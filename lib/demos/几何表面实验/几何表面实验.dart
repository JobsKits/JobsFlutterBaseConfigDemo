// 独立运行：flutter run -t "lib/demos/几何表面实验/几何表面实验.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

import '../../demo_hub/geometry_strings.dart';

void main() {
  registerGeometryTranslations();
  runApp(const JobsDemoApp(home: GeometrySurfacesPage()));
}

class GeometrySurfacesPage extends StatefulWidget {
  const GeometrySurfacesPage({super.key});
  @override
  State<GeometrySurfacesPage> createState() => _SurfacesState();
}

class _SurfacesState extends State<GeometrySurfacesPage> {
  bool sphere = false, paused = false;
  int resolution = 16;
  double strength = .5, time = 0;
  Offset focus = Offset.zero;
  void changeFocus(Offset point, Size size) => setState(
    () => focus = Offset(
      (point.dx / size.width * 2 - 1).clamp(-1, 1),
      (point.dy / size.height * 2 - 1).clamp(-1, 1),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(geometryTr(context, '几何表面实验'))),
    body: JobsGeometryLabLayout(
      canvas: LayoutBuilder(
        builder: (context, c) => JobsGeometryClock(
          paused: paused,
          onTick: (dt) => time += dt,
          builder: (context, elapsed) {
            final mesh = sphere
                ? SurfaceGeometry.sphere(
                    resolution: resolution,
                    time: time,
                    focus: focus,
                    strength: strength,
                  )
                : SurfaceGeometry.grid(
                    resolution: resolution,
                    time: time,
                    focus: focus,
                    strength: strength,
                  );
            return JobsGeometryCanvas(
              semanticLabel: geometryTr(context, '几何表面实验'),
              onTap: (point) => changeFocus(point, c.biggest),
              onHover: (point) => changeFocus(point, c.biggest),
              onPan: (delta) => setState(
                () => focus = Offset(
                  (focus.dx + delta.dx / c.maxWidth * 2).clamp(-1, 1),
                  (focus.dy + delta.dy / c.maxHeight * 2).clamp(-1, 1),
                ),
              ),
              painter: _MeshPainter(
                mesh,
                sphere,
                Theme.of(context).colorScheme,
              ),
            );
          },
        ),
      ),
      controls: [
        if (MediaQuery.disableAnimationsOf(context))
          Text(geometryTr(context, '系统已减弱动画，请使用单步')),
        Text(geometryTr(context, '模式')),
        Wrap(
          spacing: 12,
          children: [
            ChoiceChip(
              label: Text(geometryTr(context, '网格')),
              selected: !sphere,
              onSelected: (_) => setState(() => sphere = false),
            ),
            ChoiceChip(
              label: Text(geometryTr(context, '面片球')),
              selected: sphere,
              onSelected: (_) => setState(() => sphere = true),
            ),
          ],
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '分辨率'),
          value: resolution.toDouble(),
          min: 4,
          max: 28,
          divisions: 12,
          valueLabel: '$resolution',
          onChanged: (v) => setState(() => resolution = v.round()),
        ),
        JobsGeometryParameter(
          label: geometryTr(context, '扰动强度'),
          value: strength,
          min: 0,
          max: 1,
          onChanged: (v) => setState(() => strength = v),
        ),
        JobsGeometryParameter(
          label: '${geometryTr(context, '位置')} X',
          value: focus.dx,
          min: -1,
          max: 1,
          onChanged: (v) => setState(() => focus = Offset(v, focus.dy)),
        ),
        JobsGeometryParameter(
          label: '${geometryTr(context, '位置')} Y',
          value: focus.dy,
          min: -1,
          max: 1,
          onChanged: (v) => setState(() => focus = Offset(focus.dx, v)),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton(
              onPressed: () => setState(() => paused = !paused),
              child: Text(geometryTr(context, paused ? '播放' : '暂停')),
            ),
            OutlinedButton(
              onPressed: () => setState(() => time += 1 / 30),
              child: Text(geometryTr(context, '单步')),
            ),
            TextButton(
              onPressed: () => setState(() {
                time = 0;
                focus = Offset.zero;
                strength = .5;
                resolution = 16;
                sphere = false;
              }),
              child: Text(geometryTr(context, '重置')),
            ),
          ],
        ),
        Text(geometryTr(context, '拖动画布或使用控件；方向键可调节聚焦滑块')),
      ],
    ),
  );
}

class _MeshPainter extends CustomPainter {
  _MeshPainter(this.mesh, this.sphere, this.colors);
  final SurfaceMesh mesh;
  final bool sphere;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    const projection = Projection3();
    final vertices = mesh.vertices
        .map((v) => sphere ? v : v.rotateX(-.5))
        .toList();
    final faces = List<List<int>>.of(mesh.faces);
    double depth(List<int> face) =>
        face.fold<double>(0, (sum, index) => sum + vertices[index].z) /
        face.length;
    faces.sort((a, b) => depth(a).compareTo(depth(b)));
    for (final face in faces) {
      final path = Path()
        ..addPolygon([
          for (final index in face)
            projection.project(vertices[index], size, scale: .33),
        ], true);
      if (sphere) {
        final amount = ((depth(face) + 1.3) / 2.6).clamp(0, 1).toDouble();
        canvas.drawPath(
          path,
          Paint()
            ..color = Color.lerp(
              colors.surfaceContainerHighest,
              colors.primaryContainer,
              amount,
            )!,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = (sphere ? colors.outline : colors.primary)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (sphere ? .6 : 1.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) => true;
}
