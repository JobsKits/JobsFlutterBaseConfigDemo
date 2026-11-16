import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

void main() {
  test('圆弧反解覆盖跨越零角度、缺口和端点', () {
    const center = Offset(213, 147);
    for (final gap in [0.1, math.pi / 3, math.pi, math.pi * 1.7]) {
      for (final rotation in [-7.0, -1.0, 0.0, 2.0, 9.0]) {
        final arc = ArcGeometry(gap: gap, rotation: rotation);
        for (var i = 0; i <= 100; i++) {
          final value = i / 100;
          expect(
            arc.valueAt(arc.pointAt(value, center, 110), center),
            closeTo(value, 1e-9),
          );
        }
        final inGap = arc.start + arc.sweep + gap / 4;
        expect(
          arc.valueAt(
            center + Offset(math.cos(inGap), math.sin(inGap)),
            center,
          ),
          1,
        );
      }
    }
    expect(const ArcGeometry().valueAt(center, center), 0);
  });

  test('迟滞门限保持一次触发，必须严格低于复位点才重新就绪', () {
    final gate = HysteresisGate();
    for (final value in [.99, 1.0, .995, .95, .90, .99]) {
      gate.update(value);
    }
    expect(gate.count, 1);
    expect(gate.armed, isFalse);
    expect(gate.update(double.nan), isFalse);
    gate.update(.8999);
    expect(gate.armed, isTrue);
    expect(gate.update(.99), isTrue);
    expect(gate.count, 2);
    gate.reset();
    expect(gate.count, 0);
    expect(gate.armed, isTrue);
  });

  test('矩阵与逆矩阵对任意旋转缩放平移保持局部坐标', () {
    for (final scale in [.35, 1.0, 2.0]) {
      for (final angle in [-math.pi, -.7, 0.0, math.pi / 2]) {
        final transform = CanvasTransform(
          translation: const Offset(93, -71),
          scale: scale,
          rotation: angle,
        );
        for (final point in const [
          Offset.zero,
          Offset(-170, 75),
          Offset(30, -140),
        ]) {
          final back = transform.inversePoint(
            transform.toScreen(point, const Offset(160, 250)),
            const Offset(160, 250),
          );
          expect(back, isNotNull);
          expect((back! - point).distance, lessThan(1e-8));
        }
      }
    }
    expect(
      const CanvasTransform(scale: 0).inversePoint(Offset.zero, Offset.zero),
      isNull,
    );
    expect(
      const CanvasTransform(scale: double.infinity)
          .inversePoint(Offset.zero, Offset.zero),
      isNull,
    );
  });

  test('螺旋按深度绘制并以投影四边形从前向后命中', () {
    const geometry = SpiralGeometry(radius: 160, pitch: 40, twist: 1.2);
    final tiles = geometry.layout(const Size(600, 800), 14);
    expect(tiles, isNotEmpty);
    for (var i = 0; i < tiles.length; i++) {
      expect(tiles[i].corners.length, 4);
      expect(
        tiles[i].corners.every((p) => p.dx.isFinite && p.dy.isFinite),
        isTrue,
      );
      if (i > 0) {
        expect(tiles[i].depth, greaterThanOrEqualTo(tiles[i - 1].depth));
      }
    }
    const square = [
      Offset.zero,
      Offset(100, 0),
      Offset(100, 100),
      Offset(0, 100),
    ];
    final overlapping = [SpiralTile(3, -2, square), SpiralTile(8, 5, square)];
    expect(geometry.hitTest(overlapping, const Offset(50, 50)), 8);
    expect(geometry.hitTest(overlapping, const Offset(150, 50)), isNull);
    final straight = const SpiralGeometry(twist: 0)
        .layout(const Size(600, 800), 14);
    for (final tile in straight) {
      expect(tile.bounds.center.dx, closeTo(300, 1e-8));
    }
  });

  test('粒子所有模式和质量档保持数量、有限值与相同种子的复现', () {
    for (final mode in ParticleMode.values) {
      for (final quality in GeometryQuality.values) {
        final a = ParticleSystem(
          mode: mode,
          quality: quality,
          ordered: false,
          seed: 9,
        );
        final b = ParticleSystem(
          mode: mode,
          quality: quality,
          ordered: false,
          seed: 9,
        );
        expect(a.count, quality.count);
        final points = a.displayPoints();
        expect(points.every((p) => p.finite), isTrue);
        final second = b.displayPoints();
        for (var i = 0; i < points.length; i++) {
          expect(
            [points[i].x, points[i].y, points[i].z],
            [second[i].x, second[i].y, second[i].z],
          );
        }
      }
    }
  });

  test('球面与Fibonacci使用不同采样，变形端点确实改变几何形态', () {
    final sphere = ParticleSystem(
      mode: ParticleMode.sphere,
      quality: GeometryQuality.low,
    ).displayPoints();
    final fibonacci = ParticleSystem(
      mode: ParticleMode.fibonacci,
      quality: GeometryQuality.low,
    ).displayPoints();
    expect(sphere.first.y, isNot(closeTo(fibonacci.first.y, 1e-6)));
    final golden = ParticleSystem(
      mode: ParticleMode.fibonacci,
      quality: GeometryQuality.low,
      ordered: false,
      seed: 99,
    ).displayPoints();
    expect(golden.first.y, fibonacci.first.y);
    expect(golden.last.x, fibonacci.last.x);
    final randomA = ParticleSystem(
      mode: ParticleMode.cube,
      ordered: false,
      seed: 1,
    ).displayPoints();
    final randomB = ParticleSystem(
      mode: ParticleMode.cube,
      ordered: false,
      seed: 2,
    ).displayPoints();
    expect(randomA.first.y, isNot(randomB.first.y));
    for (final points in [sphere, fibonacci]) {
      for (final p in points) {
        expect(math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z), closeTo(1, 1e-9));
      }
    }
    final cube = ParticleSystem(
      mode: ParticleMode.cube,
      quality: GeometryQuality.low,
    );
    final start = cube.displayPoints(morph: 0),
        end = cube.displayPoints(morph: 1);
    expect(
      end.every(
        (p) =>
            [p.x.abs(), p.y.abs(), p.z.abs()].any((v) => (v - 1).abs() < 1e-9),
      ),
      isTrue,
    );
    expect(
      List.generate(
        end.length,
        (i) => (start[i].x - end[i].x).abs(),
      ).reduce((a, b) => a + b),
      greaterThan(1),
    );
    final torus = ParticleSystem(
      mode: ParticleMode.torus,
      quality: GeometryQuality.low,
    ).displayPoints();
    for (final p in torus) {
      final radial = math.sqrt(p.x * p.x + p.z * p.z);
      expect(
        (radial - .8) * (radial - .8) + p.y * p.y,
        closeTo(.32 * .32, 1e-9),
      );
    }
  });

  test('Lorenz与Aizawa真实推进，异常delta忽略且大delta按上限细分', () {
    for (final mode in [ParticleMode.lorenz, ParticleMode.aizawa]) {
      final system = ParticleSystem(mode: mode, quality: GeometryQuality.low);
      final before = system.displayPoints().first;
      system.step(double.nan);
      system.step(double.infinity);
      system.step(-1);
      expect(system.displayPoints().first.x, before.x);
      system.step(.03);
      expect(system.displayPoints().first.x, isNot(before.x));
      for (var i = 0; i < 600; i++) {
        system.step(i.isEven ? 100000 : .016);
      }
      expect(
        system.displayPoints().every(
          (p) =>
              p.finite &&
              p.x.abs() < 1000 &&
              p.y.abs() < 1000 &&
              p.z.abs() < 1000,
        ),
        isTrue,
      );
      final huge = ParticleSystem(mode: mode, quality: GeometryQuality.low)
        ..step(100000);
      final capped = ParticleSystem(mode: mode, quality: GeometryQuality.low)
        ..step(.05);
      expect(huge.displayPoints().first.x, capped.displayPoints().first.x);
    }
  });

  test('网格与面片球拓扑索引合法，零扰动为平面和单位球', () {
    for (final resolution in [4, 16, 28]) {
      final grid = SurfaceGeometry.grid(resolution: resolution, strength: 0);
      final sphere = SurfaceGeometry.sphere(
        resolution: resolution,
        strength: 0,
        time: 3,
      );
      expect(grid.vertices.length, (resolution + 1) * (resolution + 1));
      expect(grid.faces.length, resolution * resolution);
      expect(grid.vertices.every((p) => p.z == 0), isTrue);
      expect(sphere.vertices.length, (resolution + 1) * (resolution * 2 + 1));
      expect(sphere.faces.length, resolution * resolution * 2);
      for (final mesh in [grid, sphere]) {
        expect(mesh.vertices.every((p) => p.finite), isTrue);
        expect(
          mesh.faces.every(
            (f) =>
                f.length == 4 &&
                f.every((i) => i >= 0 && i < mesh.vertices.length),
          ),
          isTrue,
        );
      }
      for (final p in sphere.vertices) {
        expect(math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z), closeTo(1, 1e-9));
      }
    }
    final a = SurfaceGeometry.grid(time: 0).vertices;
    final b = SurfaceGeometry.grid(time: .5).vertices;
    expect(a.first.z, isNot(b.first.z));
  });
}
