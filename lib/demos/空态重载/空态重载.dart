import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: EmptyStateDemo()));

class EmptyStateDemo extends StatefulWidget {
  const EmptyStateDemo({super.key});
  @override
  State<EmptyStateDemo> createState() => _EmptyStateDemoState();
}

class _EmptyStateDemoState extends State<EmptyStateDemo> {
  List<int> _items = [];
  bool _loading = false;
  Future<void> _reload() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) {
      setState(() {
        _items = List.generate(12, (i) => i + 1);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr(context, '空态重载')),
      actions: [
        IconButton(
          tooltip: tr(context, '清空列表'),
          onPressed: () => setState(_items.clear),
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _items.isEmpty
        ? JobsEmptyState(
            title: '暂无数据',
            message: '点击重新加载恢复列表',
            onReload: _reload,
          )
        : RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, i) => ListTile(
                title: Text('${tr(context, '条目')} ${_items[i]}'),
                trailing: IconButton(
                  tooltip: tr(context, '删除'),
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _items.removeAt(i)),
                ),
              ),
            ),
          ),
  );
}
