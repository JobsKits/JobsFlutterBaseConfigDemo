// 独立运行：flutter run -t "lib/demos/评论与回复/评论与回复.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() => runApp(const JobsDemoApp(home: CommentsDemo()));

class CommentsDemo extends StatefulWidget {
  const CommentsDemo({super.key});
  @override
  State<CommentsDemo> createState() => _CommentsState();
}

class _CommentsState extends State<CommentsDemo> {
  List<Map<String, dynamic>> comments = [
    {
      'id': 'root',
      'body': 'Flutter / iOS',
      'name': 'Jobs',
      'likes': 0,
      'children': <Map<String, dynamic>>[],
    },
  ];
  int style = 0;
  @override
  void initState() {
    super.initState();
    reload();
  }

  Map<String, dynamic> normalize(Map data, [int depth = 0]) => {
    'id': '${data['id'] ?? DateTime.now().microsecondsSinceEpoch}',
    'body': '${data['body'] ?? ''}',
    'name': '${data['name'] ?? 'Jobs'}',
    'likes': data['likes'] is num ? (data['likes'] as num).toInt() : 0,
    'children': depth >= 12
        ? <Map<String, dynamic>>[]
        : [
            for (final child in (data['children'] as List? ?? []).take(100))
              if (child is Map) normalize(child, depth + 1),
          ],
  };
  Future<void> reload() async {
    final value = await UiDemoStore.read('comment-tree', comments);
    if (mounted && value is List)
      setState(
        () => comments = [
          for (final e in value)
            if (e is Map) normalize(e),
        ],
      );
  }

  Future<void> save() async {
    final value = await UiDemoStore.write('comment-tree', comments);
    if (mounted && value is List)
      setState(
        () => comments = [
          for (final e in value)
            if (e is Map) normalize(e),
        ],
      );
  }

  Future<void> compose([
    Map<String, dynamic>? parent,
    VoidCallback? refresh,
  ]) async {
    final value = await uiInput(context, '回复');
    if (!mounted || value == null || value.trim().isEmpty) return;
    setState(() {
      final comment = {
        'id': '${DateTime.now().microsecondsSinceEpoch}',
        'body': value.trim(),
        'name': 'Jobs',
        'likes': 0,
        'children': <Map<String, dynamic>>[],
      };
      if (parent == null) {
        comments.add(comment);
      } else {
        (parent['children'] as List).add(comment);
      }
    });
    refresh?.call();
    await save();
  }

  Widget comment(
    Map<String, dynamic> item, {
    int depth = 0,
    VoidCallback? refresh,
  }) {
    final children = (item['children'] as List).cast<Map<String, dynamic>>();
    final visible = style == 1 ? children.take(2) : children;
    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: depth == 0
                ? CircleAvatar(
                    child: Text(
                      '${item['name']}'.isEmpty ? 'J' : '${item['name']}'[0],
                    ),
                  )
                : null,
            title: Text(
              '${item['name']}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: style == 2
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            subtitle: Text('${item['body']}'),
            trailing: IconButton(
              tooltip: '${item['likes']}',
              onPressed: () {
                setState(() => item['likes'] = (item['likes'] as int) + 1);
                refresh?.call();
                save();
              },
              icon: Badge(
                label: Text('${item['likes']}'),
                child: const Icon(Icons.thumb_up_outlined),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => compose(item, refresh),
              child: Text(uiTr(context, '回复')),
            ),
          ),
          if (depth < 3)
            for (final child in visible)
              comment(child, depth: depth + 1, refresh: refresh),
          if (children.isNotEmpty &&
              (depth >= 3 || (style == 1 && children.length > 2)))
            TextButton(
              onPressed: () => showReplies(item),
              child: Text('${uiTr(context, '回复')} (${children.length})'),
            ),
        ],
      ),
    );
  }

  void showReplies(Map<String, dynamic> root) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => StatefulBuilder(
          builder: (context, update) => Scaffold(
            appBar: JobsDemoAppBar(title: Text(uiTr(context, '回复'))),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [comment(root, refresh: () => update(() {}))],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, '评论与回复')),
      actions: [
        PopupMenuButton<int>(
          onSelected: (value) => setState(() => style = value),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 0, child: Text('NetEase')),
            PopupMenuItem(value: 1, child: Text('Toutiao')),
            PopupMenuItem(value: 2, child: Text('Jobs')),
          ],
        ),
      ],
    ),
    body: comments.isEmpty
        ? uiEmpty(context, reload)
        : JobsAdaptiveRefresh(
            historyKey: 'demo.comments',
            onRefresh: reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                for (final item in comments)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: comment(item),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    setState(
                      () => comments.add(
                        normalize({
                          'id': '${DateTime.now().microsecondsSinceEpoch}',
                          'body': 'Flutter ${comments.length + 1}',
                        }),
                      ),
                    );
                    save();
                  },
                  child: Text(uiTr(context, '加载更多')),
                ),
              ],
            ),
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => compose(),
      child: const Icon(Icons.add_comment),
    ),
  );
}
