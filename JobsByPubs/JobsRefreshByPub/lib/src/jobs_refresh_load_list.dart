import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import 'jobs_refresh_load_controller.dart';

/// 普通分页列表接全局样式；横纵两端、短列表与空态使用同一刷新机制。
class JobsRefreshLoadList<T> extends StatefulWidget {
  const JobsRefreshLoadList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.physics,
    this.refreshColor,
    this.zebra = false,
    this.zebraOddColor,
    this.zebraEvenColor,
    this.emptyBuilder,
    this.loadingBuilder,
    this.footerLoadingBuilder,
    this.footerNoMoreBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.horizontalItemExtent = 220,
    this.autoLoadMore = false,
  }) : assert(horizontalItemExtent > 0);
  final JobsRefreshLoadController<T> controller;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? Function(BuildContext, int)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Color? refreshColor;
  final bool zebra;
  final Color? zebraOddColor;
  final Color? zebraEvenColor;
  final Widget Function(BuildContext)? emptyBuilder;
  final Widget Function(BuildContext)? loadingBuilder;
  final Widget Function(BuildContext)? footerLoadingBuilder;
  final Widget Function(BuildContext)? footerNoMoreBuilder;
  final Axis scrollDirection;
  final bool reverse;
  final double horizontalItemExtent;
  final bool autoLoadMore;

  @override
  State<JobsRefreshLoadList<T>> createState() => _JobsRefreshLoadListState<T>();
}

class _JobsRefreshLoadListState<T> extends State<JobsRefreshLoadList<T>> {
  final scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(changed);
    scroll.addListener(scrolled);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.controller.refresh(userInitiated: false));
    });
  }

  @override
  void didUpdateWidget(JobsRefreshLoadList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(changed);
      widget.controller.addListener(changed);
    }
  }

  void changed() {
    if (mounted) setState(() {});
  }

  void scrolled() {
    final c = widget.controller;
    if (widget.autoLoadMore &&
        c.hasMore &&
        !c.isLoadingMore &&
        !c.isRefreshing &&
        scroll.hasClients &&
        scroll.position.extentAfter <= 200) {
      unawaited(c.loadMore(userInitiated: false));
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(changed);
    scroll.dispose();
    super.dispose();
  }

  Widget footer(BuildContext context) {
    final c = widget.controller;
    if (c.isLoadingMore && widget.footerLoadingBuilder != null) {
      return widget.footerLoadingBuilder!(context);
    }
    if (!c.hasMore && widget.footerNoMoreBuilder != null) {
      return widget.footerNoMoreBuilder!(context);
    }
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr(
              context,
              !c.hasMore
                  ? '没有更多了'
                  : c.isLoadingMore
                      ? '正在加载'
                      : widget.scrollDirection == Axis.horizontal
                          ? '侧拉加载'
                          : '上拉加载')),
          const SizedBox(height: 4),
          Text(
              jobsRefreshHistoryText(context,
                  refresh: false, time: c.lastLoadedAt),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final horizontal = widget.scrollDirection == Axis.horizontal;
    return LayoutBuilder(
        builder: (context, bounds) => JobsAdaptiveRefresh(
              onRefresh: c.refresh,
              onLoadMore: c.loadMore,
              controller: c.edgeController,
              color: widget.refreshColor,
              hasMore: c.hasMore,
              axis: widget.scrollDirection,
              child: ListView.separated(
                controller: scroll,
                scrollDirection: widget.scrollDirection,
                reverse: widget.reverse,
                physics: widget.physics ??
                    const JobsRefreshScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                padding: widget.padding,
                itemCount: c.items.isEmpty ? 1 : c.items.length + 1,
                separatorBuilder: (context, index) =>
                    widget.separatorBuilder?.call(context, index) ??
                    const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  if (c.items.isEmpty) {
                    final body = c.isRefreshing && widget.loadingBuilder != null
                        ? widget.loadingBuilder!(context)
                        : widget.emptyBuilder?.call(context) ??
                            JobsEmptyState(
                              title: tr(context, '无数据'),
                              onReload: c.refresh,
                            );
                    return SizedBox(
                      width: horizontal ? bounds.maxWidth : null,
                      height: horizontal ? null : bounds.maxHeight,
                      child: body,
                    );
                  }
                  if (index == c.items.length) {
                    return SizedBox(
                      width: horizontal ? widget.horizontalItemExtent : null,
                      child: footer(context),
                    );
                  }
                  Widget item =
                      widget.itemBuilder(context, c.items[index], index);
                  if (widget.zebra) {
                    final colors = Theme.of(context).colorScheme;
                    item = ColoredBox(
                      color: index.isOdd
                          ? widget.zebraOddColor ?? colors.surfaceContainer
                          : widget.zebraEvenColor ?? colors.surface,
                      child: item,
                    );
                  }
                  return horizontal
                      ? SizedBox(
                          width: widget.horizontalItemExtent, child: item)
                      : item;
                },
              ),
            ));
  }
}
