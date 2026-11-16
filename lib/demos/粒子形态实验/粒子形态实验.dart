// 独立运行：flutter run -t "lib/demos/粒子形态实验/粒子形态实验.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

import '../../demo_hub/geometry_strings.dart';

void main() {
  registerGeometryTranslations();
  runApp(const JobsDemoApp(home: ParticleShapesPage()));
}

class ParticleShapesPage extends StatefulWidget {
  const ParticleShapesPage({super.key});
  @override
  State<ParticleShapesPage> createState() => _ParticleState();
}

class _ParticleState extends State<ParticleShapesPage> {
  ParticleMode mode = ParticleMode.torus;
  GeometryQuality quality = GeometryQuality.medium;
  int seed = 42;
  bool ordered = true, paused = false;
  double morph = 1, speed = .4, phase = 0;
  late ParticleSystem system = ParticleSystem(
    mode: mode,
    quality: quality,
    seed: seed,
    ordered: ordered,
  );
  void rebuild() => system = ParticleSystem(
    mode: mode,
    quality: quality,
    seed: seed,
    ordered: ordered,
  );
  String modeName(BuildContext c, ParticleMode m) => switch (m) {
    ParticleMode.sphere => geometryTr(c, '球体'),
    ParticleMode.cube => geometryTr(c, '立方体'),
    ParticleMode.torus => geometryTr(c, '圆环'),
    ParticleMode.heart => geometryTr(c, '心形'),
    ParticleMode.fibonacci => 'Fibonacci',
    ParticleMode.lorenz => 'Lorenz',
    ParticleMode.aizawa => 'Aizawa',
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(geometryTr(context, '粒子形态实验'))),
    body: JobsGeometryLabLayout(
      canvas: JobsGeometryClock(
        paused: paused || speed == 0,
        onTick: (dt) {
          phase += dt * speed;
          system.step(dt * speed);
        },
        builder: (context, elapsed) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlesPainter(
                  system.displayPoints(morph: morph),
                  phase,
                  Theme.of(context).colorScheme,
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Text(
                '${system.count} · ${system.attractor || !ordered ? '${geometryTr(context, '随机种子')} $seed' : geometryTr(context, '有序分布')}${system.attractor ? ' · ${geometryTr(context, '发散重置')} ${system.divergenceResets}' : ''}',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      controls: [
        if (MediaQuery.disableAnimationsOf(context))
          Text(geometryTr(context, '系统已减弱动画，请使用单步')),
        DropdownButtonFormField<ParticleMode>(
          key: ValueKey(mode),
          initialValue: mode,
          decoration: InputDecoration(labelText: geometryTr(context, '形态')),
          items: [
            for (final m in ParticleMode.values)
              DropdownMenuItem(value: m, child: Text(modeName(context, m))),
          ],
          onChanged: (v) {
            if (v != null) {
              setState(() {
                mode = v;
                if (mode == ParticleMode.fibonacci) {
                  ordered = true;
                }
                rebuild();
              });
            }
          },
        ),
        Text(geometryTr(context, '质量档')),
        Wrap(
          spacing: 8,
          children: [
            for (final q in GeometryQuality.values)
              ChoiceChip(
                label: Text(
                  '${geometryTr(context, ['低', '中', '高'][q.index])} ${q.count}',
                ),
                selected: quality == q,
                onSelected: (_) => setState(() {
                  quality = q;
                  rebuild();
                }),
              ),
          ],
        ),
        if (mode == ParticleMode.cube ||
            mode == ParticleMode.torus ||
            mode == ParticleMode.heart)
          JobsGeometryParameter(
            label: geometryTr(context, '变形进度'),
            value: morph,
            onChanged: (v) => setState(() => morph = v),
          ),
        JobsGeometryParameter(
          label: geometryTr(context, '速度'),
          value: speed,
          min: 0,
          max: 1.5,
          onChanged: (v) => setState(() => speed = v),
        ),
        if (!system.attractor && mode != ParticleMode.fibonacci)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(geometryTr(context, '有序分布')),
            value: ordered,
            onChanged: (v) => setState(() {
              ordered = v;
              rebuild();
            }),
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
              onPressed: () => setState(() {
                system.step(1 / 60);
                phase += .03;
              }),
              child: Text(geometryTr(context, '单步')),
            ),
            if (!ordered || system.attractor)
              OutlinedButton(
                onPressed: () => setState(() {
                  seed++;
                  rebuild();
                }),
                child: Text(geometryTr(context, '随机种子')),
              ),
            TextButton(
              onPressed: () => setState(() {
                seed = 42;
                mode = ParticleMode.torus;
                quality = GeometryQuality.medium;
                ordered = true;
                paused = false;
                speed = .4;
                phase = 0;
                morph = 1;
                rebuild();
              }),
              child: Text(geometryTr(context, '重置')),
            ),
          ],
        ),
        Text(
          mode == ParticleMode.lorenz
              ? 'σ=10, ρ=28, β=8/3; dt ≤ 0.005'
              : mode == ParticleMode.aizawa
              ? 'a=.95, b=.7, c=.6, d=3.5, e=.25, f=.1; dt ≤ 0.005'
              : mode == ParticleMode.sphere || mode == ParticleMode.fibonacci
              ? modeName(context, mode)
              : '${geometryTr(context, '球体')} → ${modeName(context, mode)}',
        ),
      ],
    ),
  );
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter(this.points, this.angle, this.colors);
  final List<Point3> points;
  final double angle;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    const projection = Projection3();
    final batches = List.generate(3, (_) => <Offset>[]);
    for (final point in points) {
      final rotated = point.rotateY(angle).rotateX(.25);
      if (!rotated.finite) continue;
      final p = projection.project(rotated, size);
      if (p.dx >= 0 && p.dx <= size.width && p.dy >= 0 && p.dy <= size.height) {
        batches[((rotated.z + 1.5) / 3 * 3).floor().clamp(0, 2)].add(p);
      }
    }
    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = Color.lerp(colors.secondary, colors.primary, i / 2)!
        ..strokeWidth = 1.5 + i * .6
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(ui.PointMode.points, batches[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter old) => true;
}
