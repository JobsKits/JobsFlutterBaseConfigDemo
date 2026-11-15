import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const JobsDemoApp(home: SearchHistoryDemo()));

class SearchHistoryDemo extends StatefulWidget {
  const SearchHistoryDemo({super.key});
  @override
  State<SearchHistoryDemo> createState() => _SearchHistoryDemoState();
}

class _SearchHistoryDemoState extends State<SearchHistoryDemo> {
  final _input = TextEditingController();
  static const _features = [
    '侧滑菜单',
    '悬浮时钟',
    '搜索历史',
    '空态重载',
    '弹出菜单',
    '环形进度',
    '验证码输入',
  ];
  List<String> _history = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _history = prefs.getStringList('jobs_search_demo_history') ?? [],
      );
    }
  }

  Future<void> _save([String? query]) async {
    if (query != null && query.trim().isNotEmpty) {
      setState(
        () => _history = [
          query.trim(),
          ..._history.where((item) => item != query.trim()),
        ].take(20).toList(),
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('jobs_search_demo_history', _history);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _input.text.trim().toLowerCase();
    final results = _features
        .where(
          (item) => '$item ${tr(context, item)}'.toLowerCase().contains(query),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, '搜索历史'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _input,
            decoration: InputDecoration(
              labelText: tr(context, '搜索功能'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: tr(context, '清空搜索'),
                onPressed: () => setState(_input.clear),
                icon: const Icon(Icons.close),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: _save,
          ),
          const SizedBox(height: 16),
          if (query.isEmpty) ...[
            Wrap(
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  tr(context, '搜索历史'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(_history.clear);
                    _save();
                  },
                  child: Text(tr(context, '清空历史')),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _history
                  .map(
                    (item) => InputChip(
                      label: Text(item),
                      onPressed: () => setState(() => _input.text = item),
                      onDeleted: () {
                        setState(() => _history.remove(item));
                        _save();
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              tr(context, '推荐'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          if (results.isEmpty)
            JobsEmptyState(
              title: '没有匹配的功能',
              onReload: () => setState(_input.clear),
            ),
          for (final result in results)
            ListTile(
              title: Text(tr(context, result)),
              leading: const Icon(Icons.search),
              onTap: () {
                _save(_input.text.isEmpty ? tr(context, result) : _input.text);
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(tr(context, result)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(tr(context, '确认')),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
