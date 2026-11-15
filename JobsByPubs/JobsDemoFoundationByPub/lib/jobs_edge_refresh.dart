import 'package:flutter/widgets.dart';

enum JobsRefreshEdge { leading, trailing }

enum JobsEdgeRefreshPhase { idle, pulling, ready, running }

/// 同一协议驱动横纵双向边缘，具体请求与动效由业务注入。
class JobsEdgeRefreshController extends ChangeNotifier {
  JobsEdgeRefreshController({required this.onTrigger, this.threshold = 64});
  final Future<void> Function(JobsRefreshEdge edge) onTrigger;
  final double threshold;
  double distance = 0;
  JobsRefreshEdge edge = JobsRefreshEdge.leading;
  JobsEdgeRefreshPhase phase = JobsEdgeRefreshPhase.idle;
  bool disposed = false;
  double get progress => (distance / threshold).clamp(0, 1);
  void pull(double overscroll) {
    if (disposed || phase == JobsEdgeRefreshPhase.running) return;
    edge = overscroll < 0 ? JobsRefreshEdge.leading : JobsRefreshEdge.trailing;
    distance = (distance + overscroll.abs()).clamp(0, threshold * 1.5);
    phase = distance >= threshold
        ? JobsEdgeRefreshPhase.ready
        : JobsEdgeRefreshPhase.pulling;
    notifyListeners();
  }

  Future<void> release() async {
    if (phase == JobsEdgeRefreshPhase.ready) {
      await run(edge);
    } else if (phase != JobsEdgeRefreshPhase.running) {
      distance = 0;
      phase = JobsEdgeRefreshPhase.idle;
      if (!disposed) notifyListeners();
    }
  }

  Future<void> run(JobsRefreshEdge value) async {
    if (disposed || phase == JobsEdgeRefreshPhase.running) return;
    edge = value;
    phase = JobsEdgeRefreshPhase.running;
    distance = threshold;
    notifyListeners();
    try {
      await onTrigger(value);
    } finally {
      distance = 0;
      phase = JobsEdgeRefreshPhase.idle;
      if (!disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class JobsEdgeRefreshView extends StatelessWidget {
  const JobsEdgeRefreshView({
    super.key,
    required this.axis,
    required this.controller,
    required this.child,
    required this.indicatorBuilder,
  });
  final Axis axis;
  final JobsEdgeRefreshController controller;
  final Widget child;
  final Widget Function(BuildContext, JobsEdgeRefreshController)
  indicatorBuilder;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth != 0 || notification.metrics.axis != axis)
              return false;
            if (notification is OverscrollNotification &&
                notification.dragDetails != null)
              controller.pull(notification.overscroll);
            // BouncingScrollPhysics reports extent outside the content rather than OverscrollNotification.
            if (notification is ScrollUpdateNotification &&
                notification.dragDetails != null) {
              final m = notification.metrics;
              if (m.pixels < m.minScrollExtent)
                controller.pull(-(notification.scrollDelta ?? 0).abs());
              if (m.pixels > m.maxScrollExtent)
                controller.pull((notification.scrollDelta ?? 0).abs());
            }
            if (notification is ScrollEndNotification) controller.release();
            return false;
          },
          child: child,
        ),
        if (controller.phase != JobsEdgeRefreshPhase.idle)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: axis == Axis.vertical
                    ? controller.edge == JobsRefreshEdge.leading
                          ? Alignment.topCenter
                          : Alignment.bottomCenter
                    : controller.edge == JobsRefreshEdge.leading
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: indicatorBuilder(context, controller),
              ),
            ),
          ),
      ],
    ),
  );
}
