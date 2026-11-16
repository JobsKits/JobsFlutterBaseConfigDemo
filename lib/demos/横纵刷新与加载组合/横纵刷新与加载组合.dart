// 独立运行：flutter run -t "lib/demos/横纵刷新与加载组合/横纵刷新与加载组合.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_demo_foundation/jobs_edge_refresh.dart';
import 'package:lottie/lottie.dart';

import '../../demo_hub/legacy_strings.dart';

void main() {
  registerLegacyTranslations();
  runApp(
    const JobsDemoApp(title: '横纵刷新与加载组合', home: EdgeRefreshCombinationDemo()),
  );
}

Widget buildLegacyDemo(BuildContext context) =>
    const EdgeRefreshCombinationDemo();

class EdgeRefreshCombinationDemo extends StatefulWidget {
  const EdgeRefreshCombinationDemo({super.key, this.transport});
  final http.Client? transport;
  @override
  State<EdgeRefreshCombinationDemo> createState() =>
      _EdgeRefreshCombinationDemoState();
}

class _EdgeRefreshCombinationDemoState
    extends State<EdgeRefreshCombinationDemo> {
  late final client = widget.transport ?? http.Client();
  late final horizontal = JobsEdgeRefreshController(
    historyKey: 'edge-combination.horizontal',
    completionDuration: const Duration(milliseconds: 350),
    onTrigger: (edge) => request(Axis.horizontal, edge),
  );
  late final vertical = JobsEdgeRefreshController(
    historyKey: 'edge-combination.vertical',
    completionDuration: const Duration(milliseconds: 350),
    onTrigger: (edge) => request(Axis.vertical, edge),
  );
  final horizontalItems = [for (var i = 1; i <= 7; i++) '$i'],
      verticalItems = [for (var i = 1; i <= 8; i++) '$i'];
  final counts = <String, int>{};
  int style = 0;
  static const styles = ['头条', '抖音', '单图', '多图', 'GIF', 'Lottie', '菊花'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) vertical.run(JobsRefreshEdge.leading);
    });
  }

  Future<void> request(Axis axis, JobsRefreshEdge edge) async {
    final items = axis == Axis.horizontal ? horizontalItems : verticalItems;
    final key = '${axis.name}.${edge.name}';
    final serial = (counts[key] ?? 0) + 1;
    List<String>? server;
    try {
      final base = Uri.parse(
        const String.fromEnvironment(
          'JOBS_DEMO_API_BASE',
          defaultValue: 'http://127.0.0.1:18080',
        ),
      );
      final response = await client
          .post(
            base.resolve('/api/demo/edge-refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'axis': axis.name,
              'edge': edge.name,
              'page': serial,
            }),
          )
          .timeout(
            const Duration(
              milliseconds: int.fromEnvironment(
                'JOBS_DEMO_API_TIMEOUT_MS',
                defaultValue: 900,
              ),
            ),
          );
      final value = jsonDecode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          value is Map &&
          value['items'] is List) {
        server = (value['items'] as List).map((e) => '$e').toList();
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      counts[key] = serial;
      final next =
          server ??
          [
            for (var i = 1; i <= (edge == JobsRefreshEdge.leading ? 8 : 4); i++)
              '${edge == JobsRefreshEdge.leading ? serial : items.length + i}',
          ];
      if (edge == JobsRefreshEdge.leading) {
        items
          ..clear()
          ..addAll(next);
      } else {
        items.addAll(next);
      }
    });
  }

  @override
  void dispose() {
    if (widget.transport == null) client.close();
    horizontal.dispose();
    vertical.dispose();
    super.dispose();
  }

  Widget indicator(
    BuildContext context,
    JobsEdgeRefreshController controller,
  ) => JobsRefreshIndicator(
    controller: controller,
    axis: identical(controller, horizontal) ? Axis.horizontal : Axis.vertical,
    animation: SizedBox(
      width: 28,
      height: 28,
      child: _RefreshAnimation(
        style: style,
        running: controller.phase == JobsEdgeRefreshPhase.running,
        progress: controller.progress,
      ),
    ),
  );
  Widget controls(JobsEdgeRefreshController controller, String title) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    children: [
      LegacyText(title, style: Theme.of(context).textTheme.titleMedium),
      TextButton(
        key: ValueKey('${title}refresh'),
        onPressed: () =>
            controller.run(JobsRefreshEdge.leading, userInitiated: true),
        child: const LegacyText('刷新'),
      ),
      TextButton(
        key: ValueKey('${title}load'),
        onPressed: () =>
            controller.run(JobsRefreshEdge.trailing, userInitiated: true),
        child: const LegacyText('加载更多'),
      ),
    ],
  );
  Widget tile(String value, {bool horizontal = false}) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: SizedBox(
      width: horizontal ? 140 : null,
      height: horizontal ? 100 : 56,
      child: Center(child: LegacyText('Item $value')),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: const LegacyText('横纵刷新与加载组合'),
      actions: [
        IconButton(
          tooltip: legacyUiText(context, '清空'),
          onPressed: () => setState(() {
            horizontalItems.clear();
            verticalItems.clear();
          }),
          icon: const Icon(Icons.clear_all),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (var i = 0; i < styles.length; i++)
                ChoiceChip(
                  label: LegacyText(styles[i]),
                  selected: style == i,
                  onSelected: (_) => setState(() => style = i),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const LegacyText('两端拖动触发，按钮可直接启动；横向与纵向独立计数。'),
          controls(horizontal, '横向'),
          SizedBox(
            height: 120,
            child: horizontalItems.isEmpty
                ? JobsEmptyState(
                    title: legacyUiText(context, '无数据'),
                    onReload: () => horizontal.run(JobsRefreshEdge.leading),
                  )
                : JobsEdgeRefreshView(
                    axis: Axis.horizontal,
                    controller: horizontal,
                    indicatorBuilder: indicator,
                    child: ListView.builder(
                      key: const ValueKey('refresh-horizontal'),
                      scrollDirection: Axis.horizontal,
                      physics: const JobsRefreshScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: horizontalItems.length,
                      itemBuilder: (_, i) =>
                          tile(horizontalItems[i], horizontal: true),
                    ),
                  ),
          ),
          controls(vertical, '纵向'),
          Expanded(
            child: verticalItems.isEmpty
                ? JobsEmptyState(
                    title: legacyUiText(context, '无数据'),
                    onReload: () => vertical.run(JobsRefreshEdge.leading),
                  )
                : JobsEdgeRefreshView(
                    axis: Axis.vertical,
                    controller: vertical,
                    indicatorBuilder: indicator,
                    child: ListView.builder(
                      key: const ValueKey('refresh-vertical'),
                      physics: const JobsRefreshScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: verticalItems.length,
                      itemBuilder: (_, i) => tile(verticalItems[i]),
                    ),
                  ),
          ),
          LegacyText(
            '横向刷新 ${counts['horizontal.leading'] ?? 0} / 加载 ${counts['horizontal.trailing'] ?? 0}',
          ),
          LegacyText(
            '纵向刷新 ${counts['vertical.leading'] ?? 0} / 加载 ${counts['vertical.trailing'] ?? 0}',
          ),
        ],
      ),
    ),
  );
}

class _RefreshAnimation extends StatefulWidget {
  const _RefreshAnimation({
    required this.style,
    required this.running,
    required this.progress,
  });
  final int style;
  final bool running;
  final double progress;
  @override
  State<_RefreshAnimation> createState() => _RefreshAnimationState();
}

class _RefreshAnimationState extends State<_RefreshAnimation>
    with SingleTickerProviderStateMixin {
  late final animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  void syncAnimation() {
    if (widget.running && !MediaQuery.disableAnimationsOf(context)) {
      if (!animation.isAnimating) animation.repeat();
    } else {
      animation.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncAnimation();
  }

  @override
  void didUpdateWidget(_RefreshAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncAnimation();
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
      final value = widget.running ? animation.value : widget.progress;
      return switch (widget.style) {
        0 => Transform.rotate(
          angle: value * math.pi * 2,
          child: Icon(Icons.sync, color: Theme.of(context).colorScheme.primary),
        ),
        1 => Stack(
          children: [
            for (var i = 0; i < 2; i++)
              Positioned(
                left: 10 + math.sin(value * math.pi * 2 + i * math.pi) * 8,
                top: 10,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0 ? Colors.cyan : Colors.pink,
                  ),
                ),
              ),
          ],
        ),
        2 => Transform.rotate(
          angle: value * math.pi * 2,
          child: Image.asset('assets/Images/flower.png'),
        ),
        3 => Image.asset(
          'assets/Images/CarouselAssets/slide${(value * 4).floor() % 2 + 1}.png',
          fit: BoxFit.cover,
        ),
        4 => Image.asset(
          'assets/Images/AppLaunchAssets/appLaunch_welcome.gif',
          fit: BoxFit.contain,
        ),
        5 => Lottie.asset(
          'assets/Lottie/JobsSignatureSlogan.json',
          repeat: true,
          animate: widget.running,
        ),
        _ => CircularProgressIndicator(
          value: widget.running ? null : widget.progress,
        ),
      };
    },
  );
}
