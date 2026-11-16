import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 自绘的九幅风景，作为取景和纹理实验的真实内容，不依赖网络素材。
class CuratedScenePainter extends CustomPainter {
  const CuratedScenePainter({required this.scene, required this.brightness});
  final int scene;
  final Brightness brightness;

  static const colors = <Color>[
    Color(0xFF427F91),
    Color(0xFFC47D58),
    Color(0xFF59708B),
    Color(0xFF879568),
    Color(0xFF81709C),
    Color(0xFF5F8B8A),
    Color(0xFFAF6D69),
    Color(0xFF6B8AAB),
    Color(0xFF778B68),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final base = colors[scene.abs() % colors.length];
    final dark = brightness == Brightness.dark;
    final sky = Color.lerp(
      base,
      dark ? const Color(0xFF172332) : Colors.white,
      dark ? .65 : .7,
    )!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky, Color.lerp(sky, base, .28)!],
        ).createShader(Offset.zero & size),
    );
    final sun = Offset(
      size.width * (.25 + (scene % 3) * .24),
      size.height * .24,
    );
    canvas.drawCircle(
      sun,
      size.shortestSide * .095,
      Paint()..color = dark ? const Color(0xFFE4D9B9) : const Color(0xFFFFE7AE),
    );
    if (dark) {
      final random = math.Random(scene + 24);
      for (var i = 0; i < 28; i++) {
        canvas.drawCircle(
          Offset(
            random.nextDouble() * size.width,
            random.nextDouble() * size.height * .48,
          ),
          .5 + random.nextDouble(),
          Paint()..color = Colors.white.withValues(alpha: .6),
        );
      }
    }
    for (var layer = 0; layer < 4; layer++) {
      final path = Path()..moveTo(0, size.height);
      final horizon = .39 + layer * .13;
      path.lineTo(0, size.height * horizon);
      for (var i = 0; i <= 8; i++) {
        final x = size.width * i / 8;
        final y =
            size.height * (horizon - .08 * math.sin(i * 1.8 + scene + layer));
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            base,
            dark ? const Color(0xFF0F202B) : const Color(0xFF253F4A),
            layer * .18 + .07,
          )!,
      );
    }
    final river = Path()
      ..moveTo(size.width * .53, size.height * .64)
      ..cubicTo(
        size.width * .15,
        size.height * .74,
        size.width * .88,
        size.height * .84,
        size.width * .31,
        size.height,
      )
      ..lineTo(size.width * .57, size.height)
      ..cubicTo(
        size.width * .97,
        size.height * .83,
        size.width * .36,
        size.height * .76,
        size.width * .57,
        size.height * .64,
      )
      ..close();
    canvas.drawPath(river, Paint()..color = Color.lerp(base, sky, .73)!);
    final contour = Paint()
      ..color = sky.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (.78 + i * .044);
      canvas.drawPath(
        Path()
          ..moveTo(0, y)
          ..quadraticBezierTo(
            size.width * .15,
            y - 14,
            size.width * .28,
            y + 5,
          ),
        contour,
      );
    }
    for (var i = 0; i < 6; i++) {
      final x = size.width * (.73 + i * .043);
      final h = size.height * (.09 + (i % 3) * .022);
      final y = size.height * .92;
      final tree = Path()
        ..moveTo(x, y - h)
        ..lineTo(x - h * .29, y)
        ..lineTo(x + h * .29, y)
        ..close();
      canvas.drawPath(
        tree,
        Paint()..color = Color.lerp(base, const Color(0xFF142B2D), .8)!,
      );
    }
  }

  @override
  bool shouldRepaint(CuratedScenePainter oldDelegate) =>
      scene != oldDelegate.scene || brightness != oldDelegate.brightness;
}

Future<ui.Image> createCuratedTexture(Brightness brightness) async {
  final recorder = ui.PictureRecorder();
  const size = Size(768, 512);
  CuratedScenePainter(
    scene: 4,
    brightness: brightness,
  ).paint(Canvas(recorder), size);
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  } finally {
    picture.dispose();
  }
}
