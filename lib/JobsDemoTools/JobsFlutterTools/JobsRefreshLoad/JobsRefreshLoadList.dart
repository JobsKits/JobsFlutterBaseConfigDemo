import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRefreshLoad/JobsRefreshLoadController.dart';

/// 通用列表组件
class JobsRefreshLoadList<T> extends StatefulWidget {
  final JobsRefreshLoadController<T> controller;
  final Widget Function(BuildContext ctx, T item, int index) itemBuilder;
  final Widget? Function(BuildContext ctx, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Color? refreshColor;
  final bool zebra; // ✅ 行条纹
  final Color? zebraOddColor;
  final Color? zebraEvenColor;
  final Widget Function(BuildContext ctx)? emptyBuilder;
  final Widget Function(BuildContext ctx)? loadingBuilder;
  final Widget Function(BuildContext ctx)? footerLoadingBuilder;
  final Widget Function(BuildContext ctx)? footerNoMoreBuilder;

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
  });

  @override
  State<JobsRefreshLoadList<T>> createState() => _JobsRefreshLoadListState<T>();
}

class _JobsRefreshLoadListState<T> extends State<JobsRefreshLoadList<T>> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _scrollCtrl.addListener(_onScroll);
    // 首次自动刷新
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.controller.refresh());
  }

  @override
  void didUpdateWidget(covariant JobsRefreshLoadList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});
  void _onScroll() {
    final c = widget.controller;
    if (c.hasMore &&
        !c.isLoadingMore &&
        !c.isRefreshing &&
        _scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200) {
      c.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    // 初次加载中的占位
    if (c.items.isEmpty && (c.isRefreshing || c.isLoadingMore)) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    // 空态
    if (c.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: c.refresh,
        color: widget.refreshColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: widget.emptyBuilder?.call(context) ??
                  const Center(child: Text('暂无数据')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: c.refresh,
      color: widget.refreshColor,
      child: ListView.separated(
        controller: _scrollCtrl,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        itemCount: c.items.length + 1, // +1 footer
        separatorBuilder: (ctx, i) =>
            widget.separatorBuilder?.call(ctx, i) ?? const SizedBox.shrink(),
        itemBuilder: (ctx, i) {
          // footer
          if (i == c.items.length) {
            if (c.isLoadingMore) {
              return widget.footerLoadingBuilder?.call(ctx) ??
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
            }
            if (!c.hasMore) {
              return widget.footerNoMoreBuilder?.call(ctx) ??
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('没有更多了', style: TextStyle(fontSize: 12)),
                    ),
                  );
            }
            return const SizedBox(height: 12);
          }

          final item = c.items[i];
          Widget child = widget.itemBuilder(ctx, item, i);

          // 行条纹
          if (widget.zebra) {
            final odd = widget.zebraOddColor ?? const Color(0xFF262C39);
            final even = widget.zebraEvenColor ?? const Color(0xFF1E232F);
            child = Container(
              color: (i.isEven) ? even : odd,
              child: child,
            );
          }

          return child;
        },
      ),
    );
  }
}
