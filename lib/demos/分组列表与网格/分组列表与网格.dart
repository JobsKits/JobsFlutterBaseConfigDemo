// 独立运行：flutter run -t "lib/demos/分组列表与网格/分组列表与网格.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: GroupedCollectionDemo(), title: '分组列表与网格'));

class GroupedCollectionDemo extends StatefulWidget {
  const GroupedCollectionDemo({super.key});
  @override
  State<GroupedCollectionDemo> createState() => _GroupedCollectionState();
}

class _GroupedCollectionState extends State<GroupedCollectionDemo> {
  bool grid = false;
  double radius = 16, margin = 12;
  List<String> items = List.generate(12, (i) => 'Flutter ${i + 1}');
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final value = await UiDemoStore.read('collections', items);
    if (mounted && value is List) setState(() => items = value.cast<String>());
  }

  Widget cell(String value) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    margin: EdgeInsets.all(margin),
    child: InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: () => uiNotice(context, '已选择'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.widgets_outlined),
            const SizedBox(width: 12),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, '分组列表与网格')),
      actions: [
        IconButton(
          onPressed: () => setState(() => items = []),
          tooltip: uiTr(context, '清空列表'),
          icon: const Icon(Icons.clear_all),
        ),
        IconButton(
          onPressed: () => setState(() => grid = !grid),
          tooltip: uiTr(context, '分组列表与网格'),
          icon: Icon(grid ? Icons.list : Icons.grid_view),
        ),
      ],
    ),
    body: Column(
      children: [
        Slider(
          value: radius,
          min: 0,
          max: 40,
          onChanged: (v) => setState(() => radius = v),
        ),
        Slider(
          value: margin,
          min: 0,
          max: 24,
          onChanged: (v) => setState(() => margin = v),
        ),
        Expanded(
          child: items.isEmpty
              ? uiEmpty(context, () {
                  setState(
                    () => items = List.generate(12, (i) => 'Flutter ${i + 1}'),
                  );
                  reload();
                })
              : JobsAdaptiveRefresh(
                  historyKey: 'demo.grouped-list-grid',
                  onRefresh: reload,
                  child: grid
                      ? GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                mainAxisExtent: 110,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => cell(items[i]),
                        )
                      : ListView(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (i % 4 == 0)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        '${uiTr(context, '折叠分组')} ${i ~/ 4 + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                  cell(items[i]),
                                ],
                              ),
                          ],
                        ),
                ),
        ),
      ],
    ),
  );
}
