import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/extra_support.dart';

class FrozenTableLabDemo extends StatefulWidget {
  const FrozenTableLabDemo({super.key});
  @override
  State<FrozenTableLabDemo> createState() => _State();
}

class _State extends State<FrozenTableLabDemo> {
  int frozen = 1, mode = 0;
  String selection = '—';
  bool empty = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(extraTr(context, '任意冻结列表格'))),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Text('${extraTr(context, '冻结列数')}：$frozen'),
              for (var i = 0; i < 4; i++)
                ChoiceChip(
                  label: Text('$i'),
                  selected: frozen == i,
                  onSelected: (_) => setState(() => frozen = i),
                ),
              for (var i = 0; i < 4; i++)
                ChoiceChip(
                  label: Text(extraTr(context, ['截断', '换行', '缩放', '滚动'][i])),
                  selected: mode == i,
                  onSelected: (_) => setState(() => mode = i),
                ),
              IconButton(
                onPressed: () => setState(() => empty = !empty),
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
              Text(selection),
            ],
          ),
        ),
        Expanded(
          child: empty
              ? JobsEmptyState(
                  title: '暂无数据',
                  onReload: () => setState(() => empty = false),
                )
              : JobsFrozenTable(
                  frozenColumns: frozen,
                  textMode: mode,
                  headers: [
                    '#',
                    extraTr(context, '姓名'),
                    'Plan',
                    'Status',
                    'Price',
                    'Memo',
                  ],
                  rows: List.generate(
                    60,
                    (i) => [
                      '${i + 1}',
                      'Jobs $i',
                      'Professional subscription $i',
                      'Active',
                      '${i * 8}.50',
                      'Flutter cell with a long piece of text $i',
                    ],
                  ),
                  onCellSelected: (r, c) =>
                      setState(() => selection = '${r + 1} × ${c + 1}'),
                ),
        ),
      ],
    ),
  );
}

void main() => runApp(const JobsDemoApp(home: FrozenTableLabDemo()));
