import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum JobsMarqueeMode { continuous, interval, paging }

/// 持有每个实例自己的交互状态；循环副本重新构造按钮，避免复用同一个手势对象。
class JobsMarqueeView extends StatefulWidget {
  const JobsMarqueeView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemExtent,
    this.direction = AxisDirection.left,
    this.mode = JobsMarqueeMode.continuous,
    this.speed = 40,
    this.interval = const Duration(seconds: 2),
    this.paused = false,
    this.onItemChanged,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemExtent, speed;
  final AxisDirection direction;
  final JobsMarqueeMode mode;
  final Duration interval;
  final bool paused;
  final ValueChanged<int>? onItemChanged;
  @override
  State<JobsMarqueeView> createState() => _JobsMarqueeState();
}

class _JobsMarqueeState extends State<JobsMarqueeView>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  Duration? last;
  double distance = 0, elapsed = 0, manualPause = 0;
  int index = 0, lastVisible = -1;
  bool get horizontal =>
      widget.direction == AxisDirection.left ||
      widget.direction == AxisDirection.right;
  bool get reversed =>
      widget.direction == AxisDirection.right ||
      widget.direction == AxisDirection.down;
  double get extent => widget.itemExtent.isFinite && widget.itemExtent > 0
      ? widget.itemExtent
      : 1;
  @override
  void initState() {
    super.initState();
    ticker = createTicker(tick)..start();
  }

  @override
  void didUpdateWidget(JobsMarqueeView old) {
    super.didUpdateWidget(old);
    if (old.itemCount != widget.itemCount ||
        old.mode != widget.mode ||
        old.direction != widget.direction ||
        old.itemExtent != widget.itemExtent) {
      distance = 0;
      elapsed = 0;
      index = 0;
      lastVisible = -1;
    }
  }

  void tick(Duration now) {
    final seconds = last == null
        ? 0.0
        : (now - last!).inMicroseconds / Duration.microsecondsPerSecond;
    last = now;
    if (!mounted ||
        widget.paused ||
        widget.itemCount <= 1 ||
        MediaQuery.disableAnimationsOf(context))
      return;
    final dt = seconds.clamp(0, .1).toDouble();
    if (manualPause > 0) {
      manualPause -= dt;
      return;
    }
    setState(() {
      if (widget.mode == JobsMarqueeMode.continuous) {
        distance =
            (distance + widget.speed.clamp(1, 500) * dt) %
            (extent * widget.itemCount);
      } else {
        elapsed += dt;
        final wait = widget.interval.inMilliseconds / 1000;
        final fraction = ((elapsed - wait) / .35).clamp(0, 1).toDouble();
        distance = (index + Curves.easeInOutCubic.transform(fraction)) * extent;
        if (elapsed >= wait + .35) {
          index = (index + 1) % widget.itemCount;
          elapsed = 0;
          distance = index * extent;
        }
      }
    });
    final current =
        ((reversed ? -distance : distance) / extent).floor() % widget.itemCount;
    if (current != lastVisible) {
      lastVisible = current;
      widget.onItemChanged?.call(current);
    }
  }

  void drag(DragUpdateDetails details) {
    if (widget.itemCount < 2) return;
    final delta = horizontal ? details.delta.dx : details.delta.dy;
    setState(() {
      distance =
          (distance + (reversed ? delta : -delta)) %
          (extent * widget.itemCount);
      index = (distance / extent).floor();
      elapsed = 0;
      manualPause = 1;
    });
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) return const SizedBox.shrink();
    final period = extent * widget.itemCount;
    final offset = reversed ? (period - distance) % period : distance % period;
    final children = [
      for (var i = 0; i < widget.itemCount * 2; i++)
        SizedBox(
          key: ValueKey('marquee-copy-$i'),
          width: horizontal ? extent : null,
          height: horizontal ? null : extent,
          child: widget.itemBuilder(context, i % widget.itemCount),
        ),
    ];
    return GestureDetector(
      onPanUpdate: drag,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxWidth: horizontal ? double.infinity : null,
          maxHeight: horizontal ? null : double.infinity,
          child: Transform.translate(
            key: const ValueKey('marquee-motion'),
            offset: horizontal ? Offset(-offset, 0) : Offset(0, -offset),
            child: horizontal
                ? Row(mainAxisSize: MainAxisSize.min, children: children)
                : Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }
}
