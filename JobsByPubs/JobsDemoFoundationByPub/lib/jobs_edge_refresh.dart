import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/demo_app.dart';
import 'src/refresh_feedback.dart';

export 'src/refresh_feedback.dart';

enum JobsRefreshEdge { leading, trailing }

enum JobsEdgeRefreshPhase { idle, pulling, ready, running, finishing }

enum JobsEdgeRefreshOutcome { none, success, failure, noMore }

/// 同一状态机驱动四边；leading/trailing始终指滚动坐标的首尾。
class JobsEdgeRefreshController extends ChangeNotifier {
  JobsEdgeRefreshController({
    required this.onTrigger,
    this.threshold = 64,
    this.historyKey,
    this.refreshEdge = JobsRefreshEdge.leading,
    this.completionDuration = Duration.zero,
    DateTime Function()? now,
  }) : assert(threshold > 0),
       now = now ?? DateTime.now {
    historyReady = restoreHistory();
  }

  final Future<void> Function(JobsRefreshEdge edge) onTrigger;
  final double threshold;
  final String? historyKey;
  final Duration completionDuration;
  final DateTime Function() now;
  JobsRefreshEdge refreshEdge;
  AxisDirection? axisDirection;
  late final Future<void> historyReady;
  double distance = 0;
  JobsRefreshEdge edge = JobsRefreshEdge.leading;
  JobsEdgeRefreshPhase phase = JobsEdgeRefreshPhase.idle;
  JobsEdgeRefreshOutcome outcome = JobsEdgeRefreshOutcome.none;
  Object? error;
  DateTime? lastRefreshedAt;
  DateTime? lastLoadedAt;
  bool hasMore = true;
  bool disposed = false;
  int _revision = 0;
  int feedbackRevision = 0;
  JobsRefreshFeedbackEvent? feedbackEvent;
  bool get busy =>
      phase == JobsEdgeRefreshPhase.running ||
      phase == JobsEdgeRefreshPhase.finishing;
  bool get isRefresh => edge == refreshEdge;
  double get progress => (distance / threshold).clamp(0, 1);
  DateTime? get lastCompletedAt => isRefresh ? lastRefreshedAt : lastLoadedAt;

  Future<void> restoreHistory() async {
    if (historyKey == null) return;
    final revision = _revision;
    try {
      final preferences = await SharedPreferences.getInstance();
      if (disposed || revision != _revision) return;
      DateTime? read(String role) {
        final value = preferences.getInt('jobs_refresh.$historyKey.$role');
        return value == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(value);
      }

      lastRefreshedAt = read('refresh');
      lastLoadedAt = read('load');
      notifyListeners();
    } on Exception {
      // 无持久化通道的嵌入环境仍可用内存时间。
    }
  }

  void setHasMore(bool value) {
    if (disposed || value == hasMore) return;
    hasMore = value;
    if (value && outcome == JobsEdgeRefreshOutcome.noMore) {
      outcome = JobsEdgeRefreshOutcome.none;
    }
    notifyListeners();
  }

  void setExtent(double extent) {
    if (disposed || busy) return;
    final nextEdge = extent == 0
        ? edge
        : extent < 0
        ? JobsRefreshEdge.leading
        : JobsRefreshEdge.trailing;
    final nextDistance = extent.abs().clamp(0, threshold * 1.875).toDouble();
    final nextPhase = nextDistance == 0
        ? JobsEdgeRefreshPhase.idle
        : nextDistance >= threshold
        ? JobsEdgeRefreshPhase.ready
        : JobsEdgeRefreshPhase.pulling;
    if (edge == nextEdge && distance == nextDistance && phase == nextPhase)
      return;
    edge = nextEdge;
    distance = nextDistance;
    phase = nextPhase;
    if (nextDistance > 0) outcome = JobsEdgeRefreshOutcome.none;
    notifyListeners();
  }

  void pull(double overscroll) {
    if (disposed || busy || overscroll == 0) return;
    final nextEdge = overscroll < 0
        ? JobsRefreshEdge.leading
        : JobsRefreshEdge.trailing;
    final previous = edge == nextEdge ? distance : 0;
    setExtent((previous + overscroll.abs()) * (overscroll < 0 ? -1 : 1));
  }

  Future<void> release() async {
    if (disposed || busy) return;
    if (phase == JobsEdgeRefreshPhase.ready) {
      await run(edge, userInitiated: true);
    } else {
      setExtent(0);
    }
  }

  void _feedback(JobsRefreshFeedbackEvent event, bool userInitiated) {
    if (!userInitiated || disposed) return;
    feedbackEvent = event;
    feedbackRevision++;
  }

  Future<bool> run(JobsRefreshEdge value, {bool userInitiated = false}) async {
    if (disposed || busy) return false;
    edge = value;
    final refresh = isRefresh;
    if (!refresh && !hasMore) {
      outcome = JobsEdgeRefreshOutcome.noMore;
      distance = 0;
      phase = JobsEdgeRefreshPhase.idle;
      notifyListeners();
      return false;
    }
    phase = JobsEdgeRefreshPhase.running;
    outcome = JobsEdgeRefreshOutcome.none;
    error = null;
    distance = threshold;
    _feedback(JobsRefreshFeedbackEvent.started, userInitiated);
    notifyListeners();
    var success = false;
    try {
      await onTrigger(value);
      if (disposed) return false;
      final time = now();
      if (refresh) {
        lastRefreshedAt = time;
      } else {
        lastLoadedAt = time;
      }
      _revision++;
      outcome = !refresh && !hasMore
          ? JobsEdgeRefreshOutcome.noMore
          : JobsEdgeRefreshOutcome.success;
      _feedback(JobsRefreshFeedbackEvent.succeeded, userInitiated);
      success = true;
      if (historyKey != null) {
        try {
          final preferences = await SharedPreferences.getInstance();
          if (!disposed) {
            await preferences.setInt(
              'jobs_refresh.$historyKey.${refresh ? 'refresh' : 'load'}',
              time.millisecondsSinceEpoch,
            );
          }
        } on Exception {
          // 保存失败不把已经完成的数据操作改报业务失败。
        }
      }
    } catch (exception) {
      if (disposed) return false;
      error = exception;
      outcome = JobsEdgeRefreshOutcome.failure;
      _feedback(JobsRefreshFeedbackEvent.failed, userInitiated);
    }
    if (disposed) return false;
    phase = JobsEdgeRefreshPhase.finishing;
    notifyListeners();
    if (completionDuration > Duration.zero) {
      await Future<void>.delayed(completionDuration);
    }
    if (!disposed) {
      distance = 0;
      phase = JobsEdgeRefreshPhase.idle;
      notifyListeners();
    }
    return success;
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class JobsEdgeRefreshView extends StatefulWidget {
  const JobsEdgeRefreshView({
    super.key,
    required this.axis,
    required this.controller,
    required this.child,
    required this.indicatorBuilder,
    this.leadingEnabled = true,
    this.trailingEnabled = true,
    this.onFeedback,
    this.indicatorExtent,
  });
  final Axis axis;
  final JobsEdgeRefreshController controller;
  final Widget child;
  final bool leadingEnabled;
  final bool trailingEnabled;
  final double? indicatorExtent;
  final void Function(JobsRefreshFeedbackEvent event)? onFeedback;
  final Widget Function(BuildContext, JobsEdgeRefreshController)
  indicatorBuilder;

  @override
  State<JobsEdgeRefreshView> createState() => _JobsEdgeRefreshViewState();
}

class _JobsEdgeRefreshViewState extends State<JobsEdgeRefreshView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController hold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  final feedback = JobsRefreshFeedback();
  int feedbackRevision = 0;
  double actualExtent = 0;
  double lastPullExtent = 0;
  bool wasBusy = false;
  AxisDirection? direction;
  bool touching = false;
  bool foreground = true;

  @override
  void initState() {
    super.initState();
    foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    feedbackRevision = widget.controller.feedbackRevision;
    widget.controller.addListener(changed);
  }

  @override
  void didUpdateWidget(JobsEdgeRefreshView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(changed);
      widget.controller.addListener(changed);
      feedbackRevision = widget.controller.feedbackRevision;
      actualExtent = 0;
      hold.value = 0;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (!foreground) unawaited(feedback.stop());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!(JobsDemoScope.maybeOf(context)?.refreshSound ?? true) ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      unawaited(feedback.stop());
    }
  }

  void changed() {
    if (!mounted) return;
    final state = widget.controller;
    if (!state.busy) lastPullExtent = state.distance;
    if (state.busy && !wasBusy && lastPullExtent > 0) {
      final base =
          widget.indicatorExtent ??
          (widget.axis == Axis.vertical ? 76.0 : 112.0);
      hold.value = (lastPullExtent / base).clamp(0.0, 1.0);
    }
    wasBusy = state.busy;
    final goal = state.busy ? 1.0 : 0.0;
    if (hold.value != goal) {
      if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
        hold.value = goal;
      } else {
        hold.animateTo(goal, curve: Curves.easeOutCubic);
      }
    }
    if (state.feedbackRevision != feedbackRevision) {
      feedbackRevision = state.feedbackRevision;
      final event = state.feedbackEvent;
      final settings = JobsDemoScope.maybeOf(context);
      final haptics = settings?.refreshHaptics ?? true;
      final sound = settings?.refreshSound ?? true;
      if (event != null &&
          (haptics || sound) &&
          foreground &&
          (ModalRoute.of(context)?.isCurrent ?? true)) {
        if (widget.onFeedback != null) {
          widget.onFeedback!(event);
        } else {
          unawaited(feedback.play(event, haptics: haptics, sound: sound));
        }
      }
    }
  }

  bool enabled(JobsRefreshEdge edge) => edge == JobsRefreshEdge.leading
      ? widget.leadingEnabled
      : widget.trailingEnabled;

  bool notification(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != widget.axis)
      return false;
    final metrics = notification.metrics;
    widget.controller.axisDirection = metrics.axisDirection;
    final extent = metrics.pixels < metrics.minScrollExtent
        ? metrics.pixels - metrics.minScrollExtent
        : metrics.pixels > metrics.maxScrollExtent
        ? metrics.pixels - metrics.maxScrollExtent
        : 0.0;
    if (direction != metrics.axisDirection || actualExtent != extent.abs()) {
      setState(() {
        direction = metrics.axisDirection;
        actualExtent = extent.abs();
      });
    }
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      widget.controller.setExtent(0);
    }
    if (notification is OverscrollNotification &&
        notification.dragDetails != null) {
      final edge = notification.overscroll < 0
          ? JobsRefreshEdge.leading
          : JobsRefreshEdge.trailing;
      if (enabled(edge)) widget.controller.pull(notification.overscroll);
    }
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      final edge = extent < 0
          ? JobsRefreshEdge.leading
          : JobsRefreshEdge.trailing;
      if (extent != 0 && enabled(edge)) {
        widget.controller.setExtent(extent);
      } else if (extent == 0 && notification.scrollDelta != null) {
        widget.controller.setExtent(0);
      }
    }
    if (notification is ScrollEndNotification && !touching) {
      unawaited(widget.controller.release());
    }
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(changed);
    hold.dispose();
    unawaited(feedback.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, hold]),
    builder: (context, _) {
      final state = widget.controller;
      final axisDirection =
          direction ??
          (widget.axis == Axis.vertical
              ? AxisDirection.down
              : Directionality.of(context) == TextDirection.rtl
              ? AxisDirection.left
              : AxisDirection.right);
      final forward =
          axisDirection == AxisDirection.down ||
          axisDirection == AxisDirection.right;
      final sign =
          (forward ? 1.0 : -1.0) *
          (state.edge == JobsRefreshEdge.leading ? 1 : -1);
      final scale = MediaQuery.textScalerOf(context).scale(13) / 13;
      final restingExtent =
          widget.indicatorExtent ??
          (widget.axis == Axis.vertical ? 76.0 : 112.0) * scale;
      final held = restingExtent.clamp(state.threshold, 120.0) * hold.value;
      final pulling =
          state.phase == JobsEdgeRefreshPhase.pulling ||
          state.phase == JobsEdgeRefreshPhase.ready;
      final presented = math.max(held, pulling ? state.distance : 0.0);
      final shift = math.max(0.0, presented - actualExtent) * sign;
      final extent = math.max(actualExtent, presented).clamp(0.0, 160.0);
      // 横向达到阈值后按已腾出的空间换行，避免历史文字伸到首张卡片下。
      final indicatorWidth = math.min(
        restingExtent.clamp(state.threshold, 120.0),
        math.max(state.threshold, extent),
      );
      final alignment = widget.axis == Axis.vertical
          ? (sign > 0 ? Alignment.topCenter : Alignment.bottomCenter)
          : (sign > 0 ? Alignment.centerLeft : Alignment.centerRight);
      return ClipRect(
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Transform.translate(
              offset: widget.axis == Axis.vertical
                  ? Offset(0, shift)
                  : Offset(shift, 0),
              child: Listener(
                onPointerDown: (_) => touching = true,
                onPointerUp: (_) {
                  touching = false;
                  unawaited(state.release());
                },
                onPointerCancel: (_) {
                  touching = false;
                  state.setExtent(0);
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: notification,
                  child: widget.child,
                ),
              ),
            ),
            if ((state.phase != JobsEdgeRefreshPhase.idle ||
                    hold.value > .001 ||
                    state.outcome == JobsEdgeRefreshOutcome.noMore &&
                        actualExtent > .5) &&
                enabled(state.edge))
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: alignment,
                    child: ClipRect(
                      child: SizedBox(
                        height: widget.axis == Axis.vertical ? extent : null,
                        width: widget.axis == Axis.horizontal ? extent : null,
                        child: OverflowBox(
                          alignment: alignment,
                          minHeight: widget.axis == Axis.vertical
                              ? restingExtent.clamp(state.threshold, 120.0)
                              : null,
                          maxHeight: widget.axis == Axis.vertical
                              ? restingExtent.clamp(state.threshold, 120.0)
                              : null,
                          minWidth: widget.axis == Axis.horizontal
                              ? indicatorWidth
                              : null,
                          maxWidth: widget.axis == Axis.horizontal
                              ? indicatorWidth
                              : null,
                          child: Center(
                            child: widget.indicatorBuilder(context, state),
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
