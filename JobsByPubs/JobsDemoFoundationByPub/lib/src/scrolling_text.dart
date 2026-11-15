import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 文字未溢出时静止；溢出时按逻辑像素／秒循环或往返，响应系统减少动态效果。
class JobsScrollingText extends StatefulWidget {
  const JobsScrollingText({
    super.key,
    required this.text,
    this.style,
    this.speed = 36,
    this.spacing = 36,
    this.pingPong = false,
    this.paused = false,
  });
  final String text;
  final TextStyle? style;
  final double speed, spacing;
  final bool pingPong, paused;
  @override
  State<JobsScrollingText> createState() => _JobsScrollingTextState();
}

class _JobsScrollingTextState extends State<JobsScrollingText>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  Duration? previous;
  double offset = 0, extent = 0, period = 0, pause = 0;
  bool forward = true;
  @override
  void initState() {
    super.initState();
    ticker = createTicker(tick)..start();
  }

  @override
  void didUpdateWidget(JobsScrollingText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text || old.pingPong != widget.pingPong) {
      offset = 0;
      forward = true;
      pause = 0;
    }
  }

  void tick(Duration elapsed) {
    final delta = previous == null
        ? 0.0
        : (elapsed - previous!).inMicroseconds / Duration.microsecondsPerSecond;
    previous = elapsed;
    if (!mounted ||
        widget.paused ||
        MediaQuery.disableAnimationsOf(context) ||
        extent <= 0)
      return;
    final seconds = delta.clamp(0, .1);
    if (pause > 0) {
      pause -= seconds;
      return;
    }
    setState(() {
      final step = widget.speed.clamp(1, 500) * seconds;
      if (widget.pingPong) {
        offset += (forward ? step : -step);
        if (offset >= extent) {
          offset = extent;
          forward = false;
          pause = .6;
        }
        if (offset <= 0) {
          offset = 0;
          forward = true;
          pause = .6;
        }
      } else if (period > 0) {
        offset = (offset + step) % period;
      }
    });
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = DefaultTextStyle.of(context).style.merge(widget.style);
      final direction = Directionality.of(context);
      final scaler = MediaQuery.textScalerOf(context);
      final painter = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        textDirection: direction,
        maxLines: 1,
        textScaler: scaler,
      )..layout();
      final width = painter.width, height = painter.height;
      painter.dispose();
      final available = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : width;
      extent = math.max(0, width - available);
      period = width + widget.spacing.clamp(0, 1000);
      final reduce = MediaQuery.disableAnimationsOf(context);
      final translated = extent == 0 || reduce
          ? 0.0
          : widget.pingPong
          ? offset.clamp(0, extent).toDouble()
          : offset % period;
      Widget text() => Text(
        widget.text,
        maxLines: 1,
        softWrap: false,
        style: style,
        textScaler: scaler,
        textDirection: direction,
      );
      return Semantics(
        label: widget.text,
        child: ExcludeSemantics(
          child: ClipRect(
            child: SizedBox(
              width: available,
              height: height,
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                maxWidth: double.infinity,
                child: Transform.translate(
                  offset: Offset(
                    direction == TextDirection.ltr ? -translated : translated,
                    0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      text(),
                      if (extent > 0 && !widget.pingPong && !reduce) ...[
                        SizedBox(
                          width: widget.spacing.clamp(0, 1000).toDouble(),
                        ),
                        text(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
