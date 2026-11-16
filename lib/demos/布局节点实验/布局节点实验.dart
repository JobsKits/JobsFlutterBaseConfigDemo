// 独立运行：flutter run -t "lib/demos/布局节点实验/布局节点实验.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: LayoutNodesDemo(), title: '布局节点实验'));

class LayoutNodesDemo extends StatefulWidget {
  const LayoutNodesDemo({super.key});
  @override
  State<LayoutNodesDemo> createState() => _LayoutNodesState();
}

class _LayoutNodesState extends State<LayoutNodesDemo> {
  static const kinds = [
    'Text',
    'Image',
    'Row',
    'Column',
    'Padding',
    'Background + Overlay',
    'Center',
    'AspectRatio 16:9',
    'Stack',
    'Button',
  ];
  List<Map<String, String>> items = [
    for (var i = 0; i < kinds.length; i++) {'id': 'node-$i', 'kind': kinds[i]},
  ];
  int serial = 10;
  @override
  void initState() {
    super.initState();
    reload();
  }

  List<Map<String, String>> normalize(Object? value) {
    final result = <Map<String, String>>[], seen = <String>{};
    if (value is List) {
      for (final item in value) {
        if (item is Map &&
            item['id'] is String &&
            kinds.contains(item['kind']) &&
            seen.add(item['id'] as String)) {
          result.add({
            'id': item['id'] as String,
            'kind': item['kind'] as String,
          });
        }
      }
    }
    return result;
  }

  Future<void> reload() async {
    final result = await UiDemoStore.read('layout-nodes', items);
    if (mounted) setState(() => items = normalize(result));
  }

  Future<void> save() async {
    final result = await UiDemoStore.write('layout-nodes', items);
    if (mounted && result != null) setState(() => items = normalize(result));
  }

  void append() {
    setState(
      () => items.add({
        'id': 'new-${DateTime.now().microsecondsSinceEpoch}-${serial++}',
        'kind': 'Text',
      }),
    );
    unawaited(save());
  }

  Widget image({double? width, double? height}) => Image.asset(
    'assets/Images/flower.png',
    width: width,
    height: height,
    fit: BoxFit.cover,
  );
  Widget content(String kind) {
    final colors = Theme.of(context).colorScheme;
    return switch (kind) {
      'Text' => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'TextPainter / TextSpan',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: '\n${uiTr(context, '内容')} · Flutter · Jobs'),
          ],
        ),
      ),
      'Image' => Align(
        alignment: AlignmentDirectional.centerStart,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image(width: 120, height: 120),
        ),
      ),
      'Row' => Row(
        children: [
          for (final text in ['A', 'B', 'C'])
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(3),
                color: colors.primaryContainer,
                child: Text(text, textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
      'Column' => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final key in ['上', '中', '下'])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(uiTr(context, key)),
            ),
        ],
      ),
      'Padding' => DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: colors.outline)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(uiTr(context, '内边距')),
        ),
      ),
      'Background + Overlay' => SizedBox(
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image(),
            ColoredBox(color: Colors.black.withValues(alpha: .45)),
            PositionedDirectional(
              start: 8,
              top: 8,
              child: Text(
                'Overlay',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      'Center' => SizedBox(
        height: 80,
        child: Center(child: Text(uiTr(context, '居中'))),
      ),
      'AspectRatio 16:9' => AspectRatio(aspectRatio: 16 / 9, child: image()),
      'Stack' => SizedBox(
        height: 100,
        child: Stack(
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: image(width: 120, height: 80),
              ),
            ),
            PositionedDirectional(
              start: 50,
              top: 35,
              child: Material(
                color: colors.primaryContainer,
                elevation: 4,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Top',
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      _ => FilledButton.tonal(
        key: const ValueKey('layout-node-append'),
        onPressed: append,
        child: Text(uiTr(context, '增加')),
      ),
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, '布局节点实验')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '重新加载'),
          onPressed: reload,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: uiTr(context, '打乱顺序'),
          onPressed: () {
            setState(items.shuffle);
            unawaited(save());
          },
          icon: const Icon(Icons.shuffle),
        ),
        IconButton(
          tooltip: uiTr(context, '增加'),
          onPressed: append,
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    body: items.isEmpty
        ? uiEmpty(context, reload)
        : SingleChildScrollView(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (final item in items)
                    Card(
                      key: ValueKey(item['id']),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              item['kind']!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            content(item['kind']!),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
  );
}
