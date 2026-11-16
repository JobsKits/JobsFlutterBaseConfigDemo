import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'geometry_models.dart';

/// 每次恢复从新帧计算 delta，后台与不可见路由不消耗帧；手动控制不受影响。
class JobsGeometryClock extends StatefulWidget {
  const JobsGeometryClock({
    super.key,
    required this.builder,
    this.onTick,
    this.paused = false,
  });
  final Widget Function(BuildContext, double elapsed) builder;
  final ValueChanged<double>? onTick;
  final bool paused;
  @override
  State<JobsGeometryClock> createState() => _ClockState();
}

class _ClockState extends State<JobsGeometryClock>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker ticker;
  Duration? previous;
  double elapsed = 0;
  bool resumed = true;
  @override
  void initState() {
    super.initState();
    resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    ticker = createTicker((stamp) {
      final dt = previous == null
          ? 0.0
          : ((stamp - previous!).inMicroseconds / 1e6).clamp(0, .05).toDouble();
      previous = stamp;
      elapsed += dt;
      widget.onTick?.call(dt);
      setState(() {});
    });
  }

  void sync() {
    final active =
        resumed &&
        !widget.paused &&
        TickerMode.valuesOf(context).enabled &&
        !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);
    if (active && !ticker.isActive) {
      previous = null;
      ticker.start();
    }
    if (!active && ticker.isActive) {
      ticker.stop();
      previous = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sync();
  }

  @override
  void didUpdateWidget(covariant JobsGeometryClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    resumed = state == AppLifecycleState.resumed;
    sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, elapsed);
}

KeyEventResult _adjust(
  KeyEvent event,
  double value,
  ValueChanged<double> change,
) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return KeyEventResult.ignored;
  }
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.arrowDown) {
    change((value - .02).clamp(0, 1));
  } else if (key == LogicalKeyboardKey.arrowRight ||
      key == LogicalKeyboardKey.arrowUp) {
    change((value + .02).clamp(0, 1));
  } else if (key == LogicalKeyboardKey.home) {
    change(0);
  } else if (key == LogicalKeyboardKey.end) {
    change(1);
  } else {
    return KeyEventResult.ignored;
  }
  return KeyEventResult.handled;
}

class JobsArcSlider extends StatefulWidget {
  const JobsArcSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.geometry = const ArcGeometry(),
  });
  final double value;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final ArcGeometry geometry;
  @override
  State<JobsArcSlider> createState() => _ArcSliderState();
}

class _ArcSliderState extends State<JobsArcSlider> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Focus(
      onFocusChange: (v) => setState(() => focused = v),
      onKeyEvent: (_, event) => _adjust(event, widget.value, widget.onChanged),
      child: Semantics(
        label: widget.semanticLabel,
        value: '${(widget.value * 100).round()}%',
        increasedValue: '${((widget.value + .02).clamp(0, 1) * 100).round()}%',
        decreasedValue: '${((widget.value - .02).clamp(0, 1) * 100).round()}%',
        slider: true,
        onIncrease: () => widget.onChanged((widget.value + .02).clamp(0, 1)),
        onDecrease: () => widget.onChanged((widget.value - .02).clamp(0, 1)),
        child: LayoutBuilder(
          builder: (context, c) {
            final side = math.min(c.maxWidth, c.maxHeight);
            final size = Size.square(side);
            final radius = math.max(1.0, side / 2 - 24);
            void update(Offset point) => widget.onChanged(
              widget.geometry.valueAt(point, size.center(Offset.zero)),
            );
            return Center(
              child: SizedBox.square(
                dimension: side,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (event) => update(event.localPosition),
                  onPanStart: (event) => update(event.localPosition),
                  onPanUpdate: (event) => update(event.localPosition),
                  child: CustomPaint(
                    painter: _ArcPainter(
                      widget.value,
                      widget.geometry,
                      radius,
                      colors,
                      focused,
                    ),
                    child: Center(
                      child: Text(
                        '${(widget.value * 100).round()}%',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(
    this.value,
    this.geometry,
    this.radius,
    this.colors,
    this.focused,
  );
  final double value, radius;
  final ArcGeometry geometry;
  final ColorScheme colors;
  final bool focused;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero),
        bounds = Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: radius,
        );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = colors.surfaceContainerHighest;
    canvas.drawArc(bounds, geometry.start, geometry.sweep, false, track);
    track.color = colors.primary;
    canvas.drawArc(
      bounds,
      geometry.start,
      geometry.sweep * value.clamp(0, 1),
      false,
      track,
    );
    final thumb = geometry.pointAt(value, center, radius);
    canvas.drawCircle(thumb, 13, Paint()..color = colors.primary);
    canvas.drawCircle(thumb, 6, Paint()..color = colors.onPrimary);
    if (focused) {
      canvas.drawCircle(
        center,
        radius + 20,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = colors.primary,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.value != value ||
      old.geometry != geometry ||
      old.colors != colors ||
      old.focused != focused;
}

class JobsNeonSlider extends StatefulWidget {
  const JobsNeonSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.flash = 0,
  });
  final double value, flash;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  @override
  State<JobsNeonSlider> createState() => _NeonState();
}

class _NeonState extends State<JobsNeonSlider> {
  bool focused = false;
  @override
  Widget build(BuildContext context) => Focus(
    onFocusChange: (value) => setState(() => focused = value),
    onKeyEvent: (_, event) => _adjust(event, widget.value, widget.onChanged),
    child: Semantics(
      label: widget.semanticLabel,
      slider: true,
      value: '${(widget.value * 100).round()}%',
      increasedValue: '${((widget.value + .02).clamp(0, 1) * 100).round()}%',
      decreasedValue: '${((widget.value - .02).clamp(0, 1) * 100).round()}%',
      onIncrease: () => widget.onChanged((widget.value + .02).clamp(0, 1)),
      onDecrease: () => widget.onChanged((widget.value - .02).clamp(0, 1)),
      child: LayoutBuilder(
        builder: (context, c) {
          void update(Offset p) =>
              widget.onChanged((p.dx / c.maxWidth).clamp(0, 1));
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (e) => update(e.localPosition),
            onHorizontalDragUpdate: (e) => update(e.localPosition),
            child: SizedBox(
              width: double.infinity,
              height: 72,
              child: CustomPaint(
                painter: _NeonPainter(
                  widget.value,
                  widget.flash,
                  Theme.of(context).colorScheme,
                  focused,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _NeonPainter extends CustomPainter {
  _NeonPainter(this.value, this.flash, this.colors, this.focused);
  final double value, flash;
  final ColorScheme colors;
  final bool focused;
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(4, 16, math.max(0, size.width - 8), 40);
    final track = RRect.fromRectAndRadius(bounds, const Radius.circular(20));
    canvas.drawRRect(track, Paint()..color = colors.surfaceContainerHighest);
    final progress = Rect.fromLTWH(
      bounds.left,
      bounds.top,
      bounds.width * value.clamp(0, 1),
      bounds.height,
    );
    canvas.save();
    canvas.clipRRect(track);
    if (progress.width > 0) {
      canvas.drawRect(
        progress,
        Paint()
          ..shader = LinearGradient(colors: [colors.primary, colors.tertiary])
              .createShader(bounds),
      );
    }
    if (flash > 0) {
      canvas.drawRect(
        bounds,
        Paint()
          ..color = colors.onSurface.withValues(alpha: flash.clamp(0, 1) * .28),
      );
    }
    canvas.restore();
    canvas.drawRRect(
      track,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = focused ? 3 : 1
        ..color = focused ? colors.primary : colors.outline,
    );
    final x = bounds.left + bounds.width * value.clamp(0, 1);
    canvas.drawCircle(
      Offset(x, bounds.center.dy),
      7,
      Paint()..color = colors.onSurface,
    );
    if (flash > 0) {
      canvas.drawRRect(
        track.inflate(flash * 5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + flash * 4
          ..color = colors.primary.withValues(alpha: flash.clamp(0, 1)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonPainter old) =>
      old.value != value ||
      old.flash != flash ||
      old.colors != colors ||
      old.focused != focused;
}

class JobsGeometryCanvas extends StatelessWidget {
  const JobsGeometryCanvas({
    super.key,
    required this.painter,
    this.onPan,
    this.onTap,
    this.onHover,
    this.semanticLabel = '',
  });
  final CustomPainter painter;
  final ValueChanged<Offset>? onPan, onTap, onHover;
  final String semanticLabel;
  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: MouseRegion(
      onHover: (event) => onHover?.call(event.localPosition),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (event) => onPan?.call(event.delta),
        onTapDown: (event) => onTap?.call(event.localPosition),
        child: CustomPaint(painter: painter, size: Size.infinite),
      ),
    ),
  );
}

class JobsGeometryLabLayout extends StatelessWidget {
  const JobsGeometryLabLayout({
    super.key,
    required this.canvas,
    required this.controls,
  });
  final Widget canvas;
  final List<Widget> controls;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, c) {
        final panel = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final control in controls)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: control,
                ),
            ],
          ),
        );
        Widget scene(double height) => Container(
          height: height,
          margin: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: canvas,
        );
        if (c.maxWidth >= 850) {
          return Row(
            children: [
              Expanded(flex: 3, child: scene(c.maxHeight - 24)),
              Expanded(flex: 2, child: SingleChildScrollView(child: panel)),
            ],
          );
        }
        return ListView(
          children: [
            scene(math.min(420, math.max(250, c.maxWidth * .85))),
            panel,
          ],
        );
      },
    ),
  );
}

class JobsGeometryParameter extends StatelessWidget {
  const JobsGeometryParameter({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.valueLabel,
  });
  final String label;
  final double value, min, max;
  final int? divisions;
  final String? valueLabel;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label · ${valueLabel ?? value.toStringAsFixed(2)}'),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: valueLabel ?? value.toStringAsFixed(2),
        onChanged: onChanged,
        semanticFormatterCallback: (v) => '$label ${v.toStringAsFixed(2)}',
      ),
    ],
  );
}
