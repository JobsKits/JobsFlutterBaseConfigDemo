// 独立运行：flutter run -t "lib/demos/马赛克涂抹/马赛克涂抹.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

import 'dart:ui' as ui;

import 'package:flutter/services.dart';

void main() =>
    runApp(const JobsDemoApp(home: MosaicBrushDemo(), title: '马赛克涂抹'));

class MosaicBrushDemo extends StatefulWidget {
  const MosaicBrushDemo({super.key});
  @override
  State<MosaicBrushDemo> createState() => _MosaicState();
}

class _MosaicState extends State<MosaicBrushDemo> {
  ui.Image? image;
  ByteData? pixels;
  final points = <Offset>[];
  double block = 18;
  bool whole = false, enabled = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final bytes = await rootBundle.load('assets/Images/flower.png');
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: 800,
    );
    final frame = await codec.getNextFrame();
    codec.dispose();
    final data = await frame.image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() {
      image = frame.image;
      pixels = data;
    });
  }

  void mark(Offset position, BoxConstraints constraints) {
    if (!enabled || whole) return;
    setState(
      () => points.add(
        Offset(
          (position.dx / constraints.maxWidth).clamp(0, 1).toDouble(),
          (position.dy / constraints.maxHeight).clamp(0, 1).toDouble(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, '马赛克涂抹')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '清空'),
          onPressed: () => setState(points.clear),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Column(
      children: [
        SwitchListTile(
          title: Text(uiTr(context, '整图马赛克')),
          value: whole,
          onChanged: (value) => setState(() => whole = value),
        ),
        SwitchListTile(
          title: Text(uiTr(context, '启用')),
          value: enabled,
          onChanged: (value) => setState(() => enabled = value),
        ),
        Text('${uiTr(context, '块大小')}: ${block.round()}'),
        Slider(
          value: block,
          min: 6,
          max: 50,
          onChanged: (v) => setState(() => block = v),
        ),
        Expanded(
          child: image == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, c) => GestureDetector(
                    onPanDown: (event) => mark(event.localPosition, c),
                    onPanUpdate: (event) => mark(event.localPosition, c),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _MosaicPainter(
                        image!,
                        pixels!,
                        points,
                        block,
                        whole,
                        enabled,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}

class _MosaicPainter extends CustomPainter {
  _MosaicPainter(
    this.image,
    this.bytes,
    this.points,
    this.block,
    this.whole,
    this.enabled,
  );
  final bool whole, enabled;
  final ui.Image image;
  final ByteData bytes;
  final List<Offset> points;
  final double block;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(image, src, Offset.zero & size, Paint());
    if (!enabled) {
      canvas.restore();
      return;
    }
    final cells = <Offset>{};
    if (whole) {
      for (var x = 0; x < size.width / block; x++) {
        for (var y = 0; y < size.height / block; y++) {
          cells.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }
    for (final p in points) {
      final cx = (p.dx * size.width / block).floor();
      final cy = (p.dy * size.height / block).floor();
      for (var x = cx - 1; x <= cx + 1; x++)
        for (var y = cy - 1; y <= cy + 1; y++)
          cells.add(Offset(x.toDouble(), y.toDouble()));
    }
    for (final cell in cells) {
      final x = ((cell.dx + .5) * block / size.width * image.width)
          .toInt()
          .clamp(0, image.width - 1);
      final y = ((cell.dy + .5) * block / size.height * image.height)
          .toInt()
          .clamp(0, image.height - 1);
      final i = (y * image.width + x) * 4;
      final paint = Paint()
        ..color = Color.fromARGB(
          255,
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      canvas.drawRect(
        Rect.fromLTWH(cell.dx * block, cell.dy * block, block + .5, block + .5),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MosaicPainter old) => true;
}
