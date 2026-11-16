// 独立运行：flutter run -t "lib/demos/折叠分组/折叠分组.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: CollapsibleGroupsDemo()));

class CollapsibleGroupsDemo extends StatefulWidget {
  const CollapsibleGroupsDemo({super.key});
  @override
  State<CollapsibleGroupsDemo> createState() => _CollapsibleGroupsDemoState();
}

class _CollapsibleGroupsDemoState extends State<CollapsibleGroupsDemo> {
  final Set<String> _selected = {};
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(tr(context, '折叠分组'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final group in ['基础与布局', '交互与动画', '数据与状态'])
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              key: PageStorageKey(group),
              initiallyExpanded: group == '基础与布局',
              title: Text(tr(context, group)),
              children: List.generate(4, (i) {
                final id = '$group$i';
                return CheckboxListTile(
                  title: Text('${tr(context, '条目')} ${i + 1}'),
                  value: _selected.contains(id),
                  onChanged: (value) => setState(
                    () => value! ? _selected.add(id) : _selected.remove(id),
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => setState(_selected.clear),
          child: Text(tr(context, '恢复默认')),
        ),
      ],
    ),
  );
}
