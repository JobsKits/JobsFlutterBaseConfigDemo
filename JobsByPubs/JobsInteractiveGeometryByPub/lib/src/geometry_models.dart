import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

const _tau = math.pi * 2;
double _wrap(double angle) => (angle % _tau + _tau) % _tau;

class ArcGeometry {
  const ArcGeometry({this.gap = math.pi * 2 / 3, this.rotation = math.pi / 2});
  final double gap, rotation;
  double get sweep => _tau - gap.clamp(0, math.pi * 1.8);
  double get start => rotation + (_tau - sweep) / 2;
  Offset pointAt(double value, Offset center, double radius) {
    final angle = start + sweep * value.clamp(0, 1);
    return center + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  double valueAt(Offset point, Offset center) {
    final delta = point - center;
    if (delta.distanceSquared < 1e-8) return 0;
    final relative = _wrap(math.atan2(delta.dy, delta.dx) - start);
    if (relative <= sweep) return relative / sweep;
    return relative - sweep < _tau - relative ? 1 : 0;
  }
}

class HysteresisGate {
  HysteresisGate({this.trigger = .99, this.resetBelow = .90})
    : assert(trigger > resetBelow && trigger <= 1 && resetBelow >= 0);
  final double trigger, resetBelow;
  bool armed = true;
  int count = 0;
  bool update(double value) {
    if (!value.isFinite) return false;
    if (value < resetBelow) armed = true;
    if (value >= trigger && armed) {
      armed = false;
      count++;
      return true;
    }
    return false;
  }

  void reset() {
    armed = true;
    count = 0;
  }
}

class Point3 {
  const Point3(this.x, this.y, this.z);
  final double x, y, z;
  bool get finite => x.isFinite && y.isFinite && z.isFinite;
  Point3 lerp(Point3 other, double t) => Point3(
    x + (other.x - x) * t,
    y + (other.y - y) * t,
    z + (other.z - z) * t,
  );
  Point3 rotateY(double a) => Point3(
    x * math.cos(a) + z * math.sin(a),
    y,
    z * math.cos(a) - x * math.sin(a),
  );
  Point3 rotateX(double a) => Point3(
    x,
    y * math.cos(a) - z * math.sin(a),
    z * math.cos(a) + y * math.sin(a),
  );
}

class Projection3 {
  const Projection3({this.camera = 5});
  final double camera;
  Offset project(Point3 point, Size size, {double scale = .32}) {
    final z = point.z.clamp(-camera * 2, camera - .1);
    final factor = camera / (camera - z);
    final radius = math.min(size.width, size.height) * scale;
    return Offset(
      size.width / 2 + point.x * radius * factor,
      size.height / 2 + point.y * radius * factor,
    );
  }
}

class SpiralTile {
  SpiralTile(this.index, this.depth, this.corners);
  final int index;
  final double depth;
  final List<Offset> corners;
  Path get path => Path()..addPolygon(corners, true);
  Rect get bounds => path.getBounds();
}

class SpiralGeometry {
  const SpiralGeometry({
    this.radius = 100,
    this.pitch = 90,
    this.twist = .7,
    this.perspective = 700,
  });
  final double radius, pitch, twist, perspective;
  List<SpiralTile> layout(Size size, double offset, {int count = 30}) {
    final tiles = <SpiralTile>[];
    final safePitch = pitch.clamp(40, 200).toDouble();
    for (var i = 0; i < count; i++) {
      final relative = i - offset;
      final y = relative * safePitch;
      if (y.abs() > size.height / 2 + 180) continue;
      final angle = relative * .5;
      final x = radius * twist * math.sin(angle),
          z = radius * twist * math.cos(angle);
      final rotation = -angle * twist;
      final corners = <Offset>[];
      for (final p in const [
        Offset(-86, -25),
        Offset(86, -25),
        Offset(86, 25),
        Offset(-86, 25),
      ]) {
        final px = x + p.dx * math.cos(rotation);
        final pz = z - p.dx * math.sin(rotation);
        final factor = perspective / math.max(50, perspective - pz);
        corners.add(
          Offset(
            size.width / 2 + px * factor,
            size.height / 2 + (y + p.dy) * factor,
          ),
        );
      }
      tiles.add(SpiralTile(i, z, corners));
    }
    tiles.sort((a, b) => a.depth.compareTo(b.depth));
    return tiles;
  }

  int? hitTest(List<SpiralTile> tiles, Offset point) {
    for (final tile in tiles.reversed) {
      if (tile.path.contains(point)) return tile.index;
    }
    return null;
  }
}

class CanvasTransform {
  const CanvasTransform({
    this.translation = Offset.zero,
    this.scale = 1,
    this.rotation = 0,
  });
  final Offset translation;
  final double scale, rotation;
  Matrix4 get matrix => Matrix4.identity()
    ..translateByVector3(Vector3(translation.dx, translation.dy, 0))
    ..rotateZ(rotation)
    ..scaleByVector3(Vector3(scale, scale, 1));
  Offset toScreen(Offset local, Offset center) =>
      MatrixUtils.transformPoint(matrix, local) + center;
  Offset? inversePoint(Offset screen, Offset center) {
    if (scale.abs() < 1e-8 || !scale.isFinite) return null;
    final inverse = Matrix4.copy(matrix);
    if (inverse.invert().abs() < 1e-12) return null;
    final result = MatrixUtils.transformPoint(inverse, screen - center);
    return result.dx.isFinite && result.dy.isFinite ? result : null;
  }
}

enum ParticleMode { sphere, cube, torus, heart, fibonacci, lorenz, aizawa }

enum GeometryQuality {
  low(200),
  medium(700),
  high(1600);

  const GeometryQuality(this.count);
  final int count;
}

class ParticleSystem {
  ParticleSystem({
    this.mode = ParticleMode.sphere,
    this.quality = GeometryQuality.medium,
    this.seed = 42,
    this.ordered = true,
  }) {
    _initialize();
  }
  final ParticleMode mode;
  final GeometryQuality quality;
  final int seed;
  final bool ordered;
  late final List<Point3> _base, _points;
  int divergenceResets = 0;
  bool get attractor =>
      mode == ParticleMode.lorenz || mode == ParticleMode.aizawa;
  int get count => _points.length;
  void _initialize() {
    final random = math.Random(seed);
    final n = quality.count;
    final side = math.sqrt(n).ceil();
    _base = List.generate(n, (i) => _sphere(i, n, random));
    _points = List.generate(n, (i) {
      final u = ordered ? (i % side) / side * _tau : random.nextDouble() * _tau;
      switch (mode) {
        case ParticleMode.cube:
          final faceSide = math.sqrt(n / 6).ceil();
          final a = ordered
              ? ((i ~/ 6) % faceSide) / (faceSide - 1) * 2 - 1
              : random.nextDouble() * 2 - 1;
          final b = ordered
              ? ((i ~/ 6) ~/ faceSide) / (faceSide - 1) * 2 - 1
              : random.nextDouble() * 2 - 1;
          return switch (i % 6) {
            0 => Point3(-1, a, b),
            1 => Point3(1, a, b),
            2 => Point3(a, -1, b),
            3 => Point3(a, 1, b),
            4 => Point3(a, b, -1),
            _ => Point3(a, b, 1),
          };
        case ParticleMode.torus:
          final v = ordered
              ? (i ~/ side) / (n / side).ceil() * _tau
              : random.nextDouble() * _tau;
          return Point3(
            (.8 + .32 * math.cos(v)) * math.cos(u),
            .32 * math.sin(v),
            (.8 + .32 * math.cos(v)) * math.sin(u),
          );
        case ParticleMode.heart:
          final angle = ordered ? i / n * _tau : u;
          final x = 16 * math.pow(math.sin(angle), 3) / 18;
          final y =
              -(13 * math.cos(angle) -
                  5 * math.cos(2 * angle) -
                  2 * math.cos(3 * angle) -
                  math.cos(4 * angle)) /
              18;
          return Point3(
            x,
            y,
            ordered
                ? math.sin(angle * 7) * .2
                : (random.nextDouble() - .5) * .5,
          );
        case ParticleMode.lorenz:
          return Point3(
            .1 + random.nextDouble(),
            random.nextDouble(),
            1 + random.nextDouble(),
          );
        case ParticleMode.aizawa:
          return Point3(
            .1 + random.nextDouble() * .1,
            random.nextDouble() * .1,
            random.nextDouble() * .1,
          );
        default:
          return _base[i];
      }
    });
    if (attractor) {
      for (var i = 0; i < 240; i++) {
        _integrate(.005);
      }
    }
  }

  Point3 _sphere(int i, int n, math.Random random) {
    if (ordered && mode != ParticleMode.fibonacci) {
      final columns = math.sqrt(n * 2).ceil();
      final rows = (n / columns).ceil();
      final latitude = ((i ~/ columns) + .5) / rows * math.pi;
      final longitude = (i % columns) / columns * _tau;
      return Point3(
        math.sin(latitude) * math.cos(longitude),
        math.cos(latitude),
        math.sin(latitude) * math.sin(longitude),
      );
    }
    final golden = mode == ParticleMode.fibonacci;
    final y = ordered || golden
        ? 1 - (i + .5) / n * 2
        : random.nextDouble() * 2 - 1;
    final angle = ordered || golden
        ? i * math.pi * (3 - math.sqrt(5))
        : random.nextDouble() * _tau;
    final radius = math.sqrt(math.max(0, 1 - y * y));
    return Point3(math.cos(angle) * radius, y, math.sin(angle) * radius);
  }

  void step(double dt) {
    if (!attractor || !dt.isFinite || dt <= 0) {
      return;
    }
    final time = dt.clamp(0, .05).toDouble();
    final steps = math.max(1, (time / .005).ceil());
    for (var i = 0; i < steps; i++) {
      _integrate(time / steps);
    }
  }

  void _integrate(double dt) {
    for (var i = 0; i < _points.length; i++) {
      final p = _points[i];
      double dx, dy, dz;
      if (mode == ParticleMode.lorenz) {
        dx = 10 * (p.y - p.x);
        dy = p.x * (28 - p.z) - p.y;
        dz = p.x * p.y - 8 / 3 * p.z;
      } else {
        dx = (p.z - .7) * p.x - 3.5 * p.y;
        dy = 3.5 * p.x + (p.z - .7) * p.y;
        dz =
            .6 +
            .95 * p.z -
            math.pow(p.z, 3) / 3 -
            (p.x * p.x + p.y * p.y) * (1 + .25 * p.z) +
            .1 * p.z * math.pow(p.x, 3);
      }
      final next = Point3(p.x + dx * dt, p.y + dy * dt, p.z + dz * dt);
      if (!next.finite ||
          next.x.abs() > 1000 ||
          next.y.abs() > 1000 ||
          next.z.abs() > 1000) {
        _points[i] = Point3(.1 + (i % 20) * .001, .1, .1);
        divergenceResets++;
      } else {
        _points[i] = next;
      }
    }
  }

  List<Point3> displayPoints({double morph = 1}) => List.generate(count, (i) {
    final p = _points[i];
    if (mode == ParticleMode.lorenz) {
      return Point3(p.x / 25, -p.y / 25, (p.z - 25) / 25);
    }
    if (mode == ParticleMode.aizawa) {
      return Point3(p.x / 2, -p.z / 2, p.y / 2);
    }
    return _base[i].lerp(p, morph.clamp(0, 1));
  });
}

class SurfaceMesh {
  const SurfaceMesh(this.vertices, this.faces);
  final List<Point3> vertices;
  final List<List<int>> faces;
}

class SurfaceGeometry {
  static SurfaceMesh grid({
    int resolution = 16,
    double time = 0,
    Offset focus = Offset.zero,
    double strength = .5,
  }) {
    final n = resolution.clamp(4, 32);
    final points = <Point3>[];
    for (var y = 0; y <= n; y++) {
      for (var x = 0; x <= n; x++) {
        final px = x / n * 2 - 1, py = y / n * 2 - 1;
        final d = (Offset(px, py) - focus).distance;
        points.add(
          Point3(px, py, math.sin(d * 7 - time * 2) * math.exp(-d) * strength),
        );
      }
    }
    final faces = <List<int>>[];
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final i = y * (n + 1) + x;
        faces.add([i, i + 1, i + n + 2, i + n + 1]);
      }
    }
    return SurfaceMesh(points, faces);
  }

  static SurfaceMesh sphere({
    int resolution = 16,
    double time = 0,
    Offset focus = Offset.zero,
    double strength = .5,
  }) {
    final n = resolution.clamp(4, 32), columns = n * 2;
    final points = <Point3>[];
    for (var y = 0; y <= n; y++) {
      for (var x = 0; x <= columns; x++) {
        final latitude = y / n * math.pi, longitude = x / columns * _tau;
        final px = math.sin(latitude) * math.cos(longitude),
            py = math.cos(latitude),
            pz = math.sin(latitude) * math.sin(longitude);
        final distance = (Offset(px, py) - focus).distance;
        final radius =
            1 +
            strength *
                .18 *
                math.exp(-distance * distance * 5) *
                math.sin(time * 3 + longitude);
        points.add(
          Point3(px * radius, py * radius, pz * radius).rotateY(time * .3),
        );
      }
    }
    final faces = <List<int>>[];
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < columns; x++) {
        final i = y * (columns + 1) + x;
        faces.add([i, i + 1, i + columns + 2, i + columns + 1]);
      }
    }
    return SurfaceMesh(points, faces);
  }
}
