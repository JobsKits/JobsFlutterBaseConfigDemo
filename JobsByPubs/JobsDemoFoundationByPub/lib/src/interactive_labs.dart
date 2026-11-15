import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'scrolling_text.dart';

/// Fibonacci sphere with perspective depth ordering and real point hit testing.
class JobsPointSphere extends StatefulWidget {
  const JobsPointSphere({
    super.key,
    required this.labels,
    this.onSelected,
    this.autoRotate = true,
  });
  final List<String> labels;
  final ValueChanged<int>? onSelected;
  final bool autoRotate;
  @override
  State<JobsPointSphere> createState() => _SphereState();
}

class _SphereState extends State<JobsPointSphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController ticker =
      AnimationController(vsync: this, duration: const Duration(seconds: 30))
        ..addListener(tick)
        ..repeat();
  double yaw = 0, pitch = 0;
  bool dragging = false;
  int? selected;
  List<(int, Offset, double)> projected(Size size) {
    final radius = math.min(size.width, size.height) * .37;
    return List.generate(widget.labels.length, (i) {
      final y = 1 - 2 * (i + .5) / widget.labels.length;
      final r = math.sqrt(1 - y * y), angle = i * math.pi * (3 - math.sqrt(5));
      final x = r * math.cos(angle), z = r * math.sin(angle);
      final x1 = x * math.cos(yaw) + z * math.sin(yaw);
      final z1 = z * math.cos(yaw) - x * math.sin(yaw);
      final y1 = y * math.cos(pitch) - z1 * math.sin(pitch);
      final depth = y * math.sin(pitch) + z1 * math.cos(pitch);
      final scale = 2.8 / (2.8 - depth);
      return (
        i,
        Offset(
          size.width / 2 + x1 * radius * scale,
          size.height / 2 + y1 * radius * scale,
        ),
        depth,
      );
    })..sort((a, b) => a.$3.compareTo(b.$3));
  }

  void tick() {
    if (widget.autoRotate && !dragging) setState(() => yaw += .0018);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final points = projected(box.biggest),
          color = Theme.of(context).colorScheme;
      return GestureDetector(
        onPanStart: (_) => dragging = true,
        onPanUpdate: (d) => setState(() {
          yaw += d.delta.dx / 90;
          pitch += d.delta.dy / 90;
        }),
        onPanEnd: (_) => dragging = false,
        onTapUp: (tap) {
          for (final point in points.reversed) {
            if ((point.$2 - tap.localPosition).distance < 25) {
              setState(() => selected = point.$1);
              widget.onSelected?.call(point.$1);
              break;
            }
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _SphereGuide(color.outlineVariant)),
            ),
            for (final p in points)
              Positioned(
                left: p.$2.dx - 24,
                top: p.$2.dy - 15,
                child: Semantics(
                  button: true,
                  selected: p.$1 == selected,
                  label: widget.labels[p.$1],
                  onTap: () {
                    setState(() => selected = p.$1);
                    widget.onSelected?.call(p.$1);
                  },
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (.45 + (p.$3 + 1) * .275).clamp(0, 1).toDouble(),
                      child: Container(
                        width: 48,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected == p.$1
                              ? color.tertiaryContainer
                              : color.primaryContainer,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FittedBox(
                          child: Text(
                            widget.labels[p.$1],
                            style: TextStyle(color: color.onPrimaryContainer),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _SphereGuide extends CustomPainter {
  _SphereGuide(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      math.min(size.width, size.height) * .37,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SphereGuide old) => old.color != color;
}

class JobsAnalogClock extends StatelessWidget {
  const JobsAnalogClock({super.key, required this.time});
  final DateTime time;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ClockPainter(time, Theme.of(context).colorScheme));
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.time, this.colors);
  final DateTime time;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero),
        r = math.min(size.width, size.height) * .45;
    canvas.drawCircle(
      center,
      r,
      Paint()..color = colors.surfaceContainerHighest,
    );
    for (var i = 0; i < 60; i++) {
      final angle = i * math.pi / 30 - math.pi / 2;
      final v = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + v * r * (i % 5 == 0 ? .82 : .92),
        center + v * r * .97,
        Paint()
          ..color = colors.onSurface
          ..strokeWidth = i % 5 == 0 ? 3 : 1,
      );
    }
    void hand(double angle, double length, double width, Color color) {
      angle -= math.pi / 2;
      canvas.drawLine(
        center,
        center + Offset(math.cos(angle), math.sin(angle)) * r * length,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    final seconds = time.second + time.millisecond / 1000;
    final minutes = time.minute + seconds / 60;
    hand(
      (time.hour % 12 + minutes / 60) * math.pi / 6,
      .5,
      7,
      colors.onSurface,
    );
    hand(minutes * math.pi / 30, .72, 4, colors.onSurface);
    hand(seconds * math.pi / 30, .83, 2, colors.primary);
    canvas.drawCircle(center, 6, Paint()..color = colors.primary);
  }

  @override
  bool shouldRepaint(_ClockPainter old) =>
      old.time != time || old.colors != colors;
}

/// Uses a shared vertical viewport and synchronized horizontal header/body offsets.
class JobsFrozenTable extends StatefulWidget {
  const JobsFrozenTable({
    super.key,
    required this.headers,
    required this.rows,
    this.frozenColumns = 1,
    this.textMode = 0,
    this.onCellSelected,
  });
  final List<String> headers;
  final List<List<String>> rows;
  final int frozenColumns;

  /// 0 ellipsis, 1 wrap, 2 scale down, 3 horizontal scroll.
  final int textMode;
  final void Function(int row, int column)? onCellSelected;
  @override
  State<JobsFrozenTable> createState() => _FrozenTableState();
}

class _FrozenTableState extends State<JobsFrozenTable> {
  final header = ScrollController(), body = ScrollController();
  @override
  void initState() {
    super.initState();
    body.addListener(sync);
  }

  void sync() {
    if (header.hasClients && header.offset != body.offset)
      header.jumpTo(body.offset.clamp(0, header.position.maxScrollExtent));
  }

  @override
  void dispose() {
    body.removeListener(sync);
    header.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frozen = widget.frozenColumns.clamp(0, widget.headers.length);
    final colors = Theme.of(context).colorScheme;
    final height = widget.textMode == 1 ? 84.0 : 52.0;
    Widget cell(String value, int row, int column) {
      Widget text = Text(
        value,
        maxLines: widget.textMode == 1 ? 3 : 1,
        overflow: TextOverflow.ellipsis,
      );
      if (widget.textMode == 2)
        text = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value),
        );
      if (widget.textMode == 3)
        text = JobsScrollingText(text: value, pingPong: true);
      return InkWell(
        onTap: row < 0 ? null : () => widget.onCellSelected?.call(row, column),
        child: Container(
          width: column < frozen
              ? math.min(
                  124.0,
                  math.max(
                    44.0,
                    (MediaQuery.sizeOf(context).width - 32) *
                        .55 /
                        math.max(1, frozen),
                  ),
                )
              : 124,
          height: height,
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: row < 0
                ? colors.secondaryContainer
                : (column < frozen
                      ? colors.surfaceContainerHigh
                      : colors.surface),
            border: Border.all(color: colors.outlineVariant, width: .5),
          ),
          child: text,
        ),
      );
    }

    Widget columns(int start, int end, bool headings) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = start; c < end; c++)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (headings)
                cell(widget.headers[c], -1, c)
              else
                for (var r = 0; r < widget.rows.length; r++)
                  cell(
                    c < widget.rows[r].length ? widget.rows[r][c] : '—',
                    r,
                    c,
                  ),
            ],
          ),
      ],
    );
    return Column(
      children: [
        Row(
          children: [
            columns(0, frozen, true),
            Expanded(
              child: SingleChildScrollView(
                controller: header,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: columns(frozen, widget.headers.length, true),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                columns(0, frozen, false),
                Expanded(
                  child: SingleChildScrollView(
                    controller: body,
                    scrollDirection: Axis.horizontal,
                    child: columns(frozen, widget.headers.length, false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
