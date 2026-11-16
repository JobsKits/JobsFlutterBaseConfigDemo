import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../jobs_edge_refresh.dart';
import 'demo_app.dart';
import 'demo_strings.dart';
import 'refresh_strings.dart';

/// 保留原生阻尼与弹簧回弹，同时限制边缘空白的最大高度。
class JobsRefreshScrollPhysics extends BouncingScrollPhysics {
  const JobsRefreshScrollPhysics({super.parent, this.maxOverscroll = 120})
    : assert(maxOverscroll > 0);

  final double maxOverscroll;

  @override
  JobsRefreshScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      JobsRefreshScrollPhysics(
        parent: buildParent(ancestor),
        maxOverscroll: maxOverscroll,
      );

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final leading = position.minScrollExtent - maxOverscroll;
    final trailing = position.maxScrollExtent + maxOverscroll;
    if (value < leading && value < position.pixels) {
      return value - math.min(position.pixels, leading);
    }
    if (value > trailing && value > position.pixels) {
      return value - math.max(position.pixels, trailing);
    }
    return 0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final simulation = super.createBallisticSimulation(
      position,
      position.outOfRange ? 0 : velocity,
    );
    if (simulation == null) return null;
    return _BoundedRefreshSimulation(
      simulation,
      position.minScrollExtent - maxOverscroll,
      position.maxScrollExtent + maxOverscroll,
    );
  }
}

// 在惯性滚动触及上限时保留原弹簧演算，避免边界截断使列表停在空白处。
class _BoundedRefreshSimulation extends Simulation {
  _BoundedRefreshSimulation(this.source, this.leading, this.trailing);
  final Simulation source;
  final double leading;
  final double trailing;

  @override
  double x(double time) => source.x(time).clamp(leading, trailing);

  @override
  double dx(double time) {
    final value = source.x(time);
    return value < leading || value > trailing ? 0 : source.dx(time);
  }

  @override
  bool isDone(double time) => source.isDone(time);
}

/// 普通列表共用设置、四边状态和成功时间；教学页可注入自己的指示器。
class JobsAdaptiveRefresh extends StatefulWidget {
  const JobsAdaptiveRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.onLoadMore,
    this.axis = Axis.vertical,
    this.hasMore = true,
    this.reverseRoles = false,
    this.historyKey,
    this.controller,
    this.indicatorBuilder,
    this.color,
  });
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final Axis axis;
  final bool hasMore;
  final bool reverseRoles;
  final String? historyKey;
  final JobsEdgeRefreshController? controller;
  final Widget child;
  final Color? color;
  final Widget Function(BuildContext, JobsEdgeRefreshController)?
  indicatorBuilder;

  @override
  State<JobsAdaptiveRefresh> createState() => _JobsAdaptiveRefreshState();
}

class _JobsAdaptiveRefreshState extends State<JobsAdaptiveRefresh> {
  final contentKey = GlobalKey();
  JobsEdgeRefreshController? owned;
  JobsEdgeRefreshController get controller => widget.controller ?? owned!;
  JobsRefreshEdge get refreshEdge =>
      widget.reverseRoles ? JobsRefreshEdge.trailing : JobsRefreshEdge.leading;

  JobsEdgeRefreshController createController() => JobsEdgeRefreshController(
    historyKey: widget.historyKey,
    refreshEdge: refreshEdge,
    completionDuration: const Duration(milliseconds: 350),
    onTrigger: (edge) =>
        edge == refreshEdge ? widget.onRefresh() : widget.onLoadMore!(),
  );

  @override
  void initState() {
    super.initState();
    JobsDemoStrings.registerTranslations(jobsRefreshTranslations);
    if (widget.controller == null) owned = createController();
  }

  @override
  void didUpdateWidget(JobsAdaptiveRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.historyKey != widget.historyKey) {
      owned?.dispose();
      owned = widget.controller == null ? createController() : null;
    }
  }

  @override
  void dispose() {
    owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style =
        JobsDemoScope.maybeOf(context)?.refreshStyle ??
        JobsRefreshStyle.flutter;
    controller.refreshEdge = refreshEdge;
    controller.hasMore = widget.hasMore;
    final content = KeyedSubtree(
      key: contentKey,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const JobsRefreshScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        ),
        child: widget.child,
      ),
    );
    final useMaterial =
        style == JobsRefreshStyle.flutter &&
        widget.axis == Axis.vertical &&
        !widget.reverseRoles;
    Widget edgeView({required bool leading}) => JobsEdgeRefreshView(
      axis: widget.axis,
      controller: controller,
      leadingEnabled:
          leading &&
          (refreshEdge == JobsRefreshEdge.leading || widget.onLoadMore != null),
      trailingEnabled:
          refreshEdge == JobsRefreshEdge.trailing || widget.onLoadMore != null,
      indicatorBuilder:
          widget.indicatorBuilder ??
          (context, state) =>
              JobsRefreshIndicator(controller: state, axis: widget.axis),
      child: content,
    );
    if (useMaterial) {
      return RefreshIndicator(
        color: widget.color,
        onRefresh: () async {
          await controller.run(JobsRefreshEdge.leading, userInitiated: true);
        },
        child: widget.onLoadMore == null ? content : edgeView(leading: false),
      );
    }
    return edgeView(leading: true);
  }
}

String jobsRefreshHistoryText(
  BuildContext context, {
  required bool refresh,
  required DateTime? time,
}) {
  JobsDemoStrings.registerTranslations(jobsRefreshTranslations);
  if (time == null) {
    return tr(context, refresh ? '暂无刷新记录' : '暂无加载记录');
  }
  final local = time.toLocal();
  final clock =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}';
  final date = DateUtils.isSameDay(local, DateTime.now())
      ? tr(context, '今天')
      : MaterialLocalizations.of(context).formatMediumDate(local);
  return '${tr(context, refresh ? '上次刷新' : '上次加载')} $date $clock';
}

/// 刷新区随内容露出；状态与最近完成时间分层显示，横向使用紧凑列布局。
class JobsRefreshIndicator extends StatelessWidget {
  const JobsRefreshIndicator({
    super.key,
    required this.controller,
    this.axis = Axis.vertical,
    this.animation,
  });
  final JobsEdgeRefreshController controller;
  final Axis axis;
  final Widget? animation;

  double pullSign(BuildContext context) {
    final direction =
        controller.axisDirection ??
        (axis == Axis.vertical
            ? AxisDirection.down
            : Directionality.of(context) == TextDirection.rtl
            ? AxisDirection.left
            : AxisDirection.right);
    return (direction == AxisDirection.down || direction == AxisDirection.right
            ? 1.0
            : -1.0) *
        (controller.edge == JobsRefreshEdge.leading ? 1.0 : -1.0);
  }

  String label(BuildContext context) {
    if (controller.outcome == JobsEdgeRefreshOutcome.noMore) {
      return tr(context, '没有更多了');
    }
    if (controller.phase == JobsEdgeRefreshPhase.finishing) {
      return tr(
        context,
        controller.outcome == JobsEdgeRefreshOutcome.failure
            ? (controller.isRefresh ? '刷新失败' : '加载失败')
            : (controller.isRefresh ? '刷新完成' : '加载完成'),
      );
    }
    if (controller.phase == JobsEdgeRefreshPhase.running) {
      return tr(context, controller.isRefresh ? '正在刷新' : '正在加载');
    }
    if (controller.phase == JobsEdgeRefreshPhase.ready) {
      return tr(context, controller.isRefresh ? '松开刷新' : '松开加载');
    }
    if (axis == Axis.vertical) {
      return tr(
        context,
        pullSign(context) > 0
            ? (controller.isRefresh ? '下拉刷新' : '下拉加载')
            : (controller.isRefresh ? '上拉刷新' : '上拉加载'),
      );
    }
    return tr(
      context,
      pullSign(context) > 0
          ? (controller.isRefresh ? '向右拉刷新' : '向右拉加载')
          : (controller.isRefresh ? '向左拉刷新' : '向左拉加载'),
    );
  }

  String history(BuildContext context) {
    return jobsRefreshHistoryText(
      context,
      refresh: controller.isRefresh,
      time: controller.lastCompletedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    JobsDemoStrings.registerTranslations(jobsRefreshTranslations);
    final colors = Theme.of(context).colorScheme;
    final text = label(context);
    final last = history(context);
    final running = controller.phase == JobsEdgeRefreshPhase.running;
    final failed = controller.outcome == JobsEdgeRefreshOutcome.failure;
    final done = controller.phase == JobsEdgeRefreshPhase.finishing && !failed;
    final directionTurns = axis == Axis.horizontal
        ? (pullSign(context) > 0 ? -.25 : .25)
        : (pullSign(context) > 0 ? 0.0 : .5);
    final icon =
        animation ??
        SizedBox(
          width: 20,
          height: 20,
          child: running
              ? const _JobsRefreshActivity()
              : AnimatedRotation(
                  turns: (done || failed)
                      ? 0
                      : directionTurns +
                            (controller.phase == JobsEdgeRefreshPhase.ready
                                ? .5
                                : 0),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  child: Icon(
                    failed
                        ? Icons.error_outline
                        : done
                        ? Icons.check
                        : Icons.expand_more,
                    size: 20,
                    color: failed ? colors.error : colors.primary,
                  ),
                ),
        );
    final statusText = Text(
      text,
      textAlign: axis == Axis.horizontal ? TextAlign.center : null,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      maxLines: axis == Axis.vertical ? 2 : null,
      overflow: axis == Axis.vertical
          ? TextOverflow.ellipsis
          : TextOverflow.clip,
    );
    final historyText = Text(
      last,
      textAlign: axis == Axis.horizontal ? TextAlign.center : null,
      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
      maxLines: axis == Axis.vertical ? 3 : null,
      overflow: axis == Axis.vertical
          ? TextOverflow.ellipsis
          : TextOverflow.clip,
    );
    final words = Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: axis == Axis.horizontal
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Flexible(child: statusText),
          const SizedBox(height: 3),
          Flexible(child: historyText),
        ],
      ),
    );
    return Semantics(
      label: '$text, $last',
      liveRegion: running || controller.phase == JobsEdgeRefreshPhase.finishing,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: axis == Axis.vertical
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon, const SizedBox(width: 10), words],
                )
              : LayoutBuilder(
                  builder: (context, constraints) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      // 窄横条先完整排字，再按可用高度缩放，保留历史的时分秒。
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon,
                          const SizedBox(height: 6),
                          statusText,
                          const SizedBox(height: 3),
                          historyText,
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _JobsRefreshActivity extends StatefulWidget {
  const _JobsRefreshActivity();
  @override
  State<_JobsRefreshActivity> createState() => _JobsRefreshActivityState();
}

class _JobsRefreshActivityState extends State<_JobsRefreshActivity>
    with SingleTickerProviderStateMixin {
  late final animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      animation.stop();
    } else if (!animation.isAnimating) {
      animation.repeat();
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final colors = Theme.of(context).colorScheme;
      return Stack(
        children: [
          for (var index = 0; index < 2; index++)
            Positioned(
              left:
                  7 +
                  math.sin(animation.value * math.pi * 2 + index * math.pi) * 6,
              top: 7,
              child: Transform.scale(
                scale:
                    1 +
                    math.cos(animation.value * math.pi * 2 + index * math.pi) *
                        .15,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0 ? colors.primary : colors.tertiary,
                  ),
                  child: const SizedBox.square(dimension: 7),
                ),
              ),
            ),
        ],
      );
    },
  );
}
