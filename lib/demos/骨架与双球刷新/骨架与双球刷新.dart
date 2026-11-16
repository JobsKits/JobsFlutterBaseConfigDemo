// 独立运行：flutter run -t "lib/demos/骨架与双球刷新/骨架与双球刷新.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() => runApp(const JobsDemoApp(home: SkeletonRefreshDemo()));

class SkeletonRefreshDemo extends StatefulWidget {
  const SkeletonRefreshDemo({super.key});
  @override
  State<SkeletonRefreshDemo> createState() => _SkeletonState();
}

class _SkeletonState extends State<SkeletonRefreshDemo>
    with SingleTickerProviderStateMixin {
  late final animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();
  bool loading = true;
  List<String> items = ['Flutter', 'Dart', 'Jobs'];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final values = await UiDemoStore.read('skeleton', items);
    if (!mounted) return;
    setState(() {
      if (values is List) items = values.cast<String>();
      loading = false;
    });
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  Widget balls() => AnimatedBuilder(
    animation: animation,
    builder: (context, _) => Center(
      child: SizedBox(
        width: 90,
        height: 40,
        child: Stack(
          children: List.generate(2, (i) {
            final angle = animation.value * math.pi * 2 + i * math.pi;
            return Positioned(
              left: 30 + math.sin(angle) * 26,
              top: 10,
              child: Transform.scale(
                scale: 1 + math.cos(angle) * .2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 20, height: 20),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
  Widget skeleton() => AnimatedBuilder(
    animation: animation,
    builder: (context, _) => ListView(
      children: List.generate(
        6,
        (i) => Opacity(
          opacity:
              .35 + .5 * (.5 + .5 * math.sin(animation.value * math.pi * 2)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
            ),
            title: Container(
              height: 18,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 10),
              height: 12,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, '骨架与双球刷新')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '刷新'),
          onPressed: load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Column(
      children: [
        SizedBox(height: 70, child: balls()),
        Expanded(
          child: loading
              ? skeleton()
              : items.isEmpty
              ? uiEmpty(context, load)
              : JobsAdaptiveRefresh(
                  historyKey: 'demo.skeleton-refresh',
                  onRefresh: load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      for (final item in items)
                        ListTile(
                          title: Text(item),
                          leading: const Icon(Icons.widgets_outlined),
                        ),
                      TextButton(
                        onPressed: () => setState(() => loading = true),
                        child: Text(uiTr(context, '骨架与双球刷新')),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    ),
  );
}
