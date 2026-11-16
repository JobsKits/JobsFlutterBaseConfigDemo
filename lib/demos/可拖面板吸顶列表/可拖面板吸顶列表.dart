// 独立运行：flutter run -t "lib/demos/可拖面板吸顶列表/可拖面板吸顶列表.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/interaction_strings.dart';
import '../../demo_hub/interaction_support.dart';

void main() => runApp(
  const JobsDemoApp(home: DraggablePinnedSheetDemo(), title: '可拖面板吸顶列表'),
);

class DraggablePinnedSheetDemo extends StatefulWidget {
  const DraggablePinnedSheetDemo({super.key, this.repository, this.controller});
  final InteractionRepository? repository;
  final DraggableScrollableController? controller;
  @override
  State<DraggablePinnedSheetDemo> createState() => _DraggablePinnedSheetState();
}

class _DraggablePinnedSheetState extends State<DraggablePinnedSheetDemo> {
  late final repository = widget.repository ?? InteractionRepository();
  late final sheet = widget.controller ?? DraggableScrollableController();
  final offset = ValueNotifier<double>(0);
  List<String> rows = List.generate(32, (i) => '${i + 1}');
  int revision = 0;
  int heightRevision = 0;
  bool remote = false;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final token = ++revision;
    if (rows.isEmpty) {
      setState(() => rows = List.generate(32, (i) => '${i + 1}'));
    }
    final value = interactionRows(await repository.read('pinned-sheet'));
    if (mounted && token == revision && value != null) {
      setState(() {
        rows = value;
        remote = true;
      });
    }
  }

  Future<void> _clear() async {
    final token = ++revision;
    setState(() {
      rows = [];
      remote = false;
    });
    final value = interactionRows(await repository.write('pinned-sheet', rows));
    if (mounted && token == revision && value != null) {
      setState(() {
        rows = value;
        remote = true;
      });
    }
  }

  Future<void> _preset(double size) async {
    final token = ++heightRevision;
    if (!sheet.isAttached) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      sheet.jumpTo(size);
    } else {
      await sheet.animateTo(
        size,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted || token != heightRevision) return;
    final value = await repository.write('pinned-sheet-height', size);
    if (!mounted ||
        token != heightRevision ||
        value is! num ||
        !value.isFinite ||
        !sheet.isAttached) {
      return;
    }
    sheet.jumpTo(value.toDouble().clamp(.25, .95));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: JobsDemoAppBar(title: Text(interactionTr(context, '可拖面板吸顶列表'))),
      body: Column(
        children: [
          interactionStatus(
            context,
            remote: remote,
            reload: _reload,
            clear: _clear,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  key: const ValueKey('sheet-collapse'),
                  onPressed: () => _preset(.25),
                  child: Text(interactionTr(context, '收起')),
                ),
                OutlinedButton(
                  onPressed: () => _preset(.55),
                  child: Text(interactionTr(context, '半屏')),
                ),
                FilledButton(
                  key: const ValueKey('sheet-expand'),
                  onPressed: () => _preset(.95),
                  child: Text(interactionTr(context, '展开')),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: sheet,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.all(8),
              child: ValueListenableBuilder(
                valueListenable: offset,
                builder: (context, value, _) => Text(
                  '${interactionTr(context, '面板高度')}: ${((sheet.isAttached ? sheet.size : .55) * 100).toStringAsFixed(0)}% · ${interactionTr(context, '列表偏移')}: ${value.toStringAsFixed(0)} px',
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: colors.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            interactionTr(context, '同一控制器在满高时接力列表'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DraggableScrollableSheet(
                    key: const ValueKey('draggable-sheet'),
                    controller: sheet,
                    initialChildSize: .55,
                    minChildSize: .25,
                    maxChildSize: .95,
                    snap: true,
                    snapSizes: const [.25, .55, .95],
                    builder: (context, sharedScrollController) => Material(
                      color: colors.surface,
                      elevation: 8,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (event) {
                          if (event.depth == 0) {
                            offset.value = event.metrics.pixels;
                          }
                          return false;
                        },
                        child: CustomScrollView(
                          key: const ValueKey('sheet-list'),
                          controller: sharedScrollController,
                          physics: const ClampingScrollPhysics(),
                          slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _PinnedHandle(
                                color: colors.surfaceContainerHighest,
                                foreground: colors.onSurface,
                                label: interactionTr(context, '吸顶拖动手柄'),
                              ),
                            ),
                            if (rows.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: interactionEmpty(context, _reload),
                              )
                            else
                              SliverList.builder(
                                itemCount: rows.length,
                                itemBuilder: (context, index) => ListTile(
                                  key: ValueKey('sheet-record-$index'),
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(
                                    '${interactionTr(context, '记录')} ${rows[index]}',
                                  ),
                                  subtitle: Text(
                                    interactionTr(context, '吸附预设高度'),
                                  ),
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SafeArea(
                                top: false,
                                child: SizedBox(height: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    revision++;
    if (widget.repository == null) repository.dispose();
    if (widget.controller == null) sheet.dispose();
    offset.dispose();
    super.dispose();
  }
}

class _PinnedHandle extends SliverPersistentHeaderDelegate {
  _PinnedHandle({
    required this.color,
    required this.foreground,
    required this.label,
  });
  final Color color;
  final Color foreground;
  final String label;
  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    key: const ValueKey('sheet-pinned-handle'),
    color: color,
    child: Semantics(
      label: label,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: foreground,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground),
            ),
          ],
        ),
      ),
    ),
  );
  @override
  bool shouldRebuild(_PinnedHandle oldDelegate) =>
      color != oldDelegate.color ||
      foreground != oldDelegate.foreground ||
      label != oldDelegate.label;
}
