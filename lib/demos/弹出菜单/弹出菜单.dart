import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: PopupMenuDemo()));

class PopupMenuDemo extends StatefulWidget {
  const PopupMenuDemo({super.key});
  @override
  State<PopupMenuDemo> createState() => _PopupMenuDemoState();
}

class _PopupMenuDemoState extends State<PopupMenuDemo> {
  List<int> _items = [1, 2, 3];
  final Set<int> _favorites = {};
  Future<void> _action(String action, int item) async {
    if (action == '删除') {
      setState(() {
        _items.remove(item);
        _favorites.remove(item);
      });
      return;
    }
    if (action == '收藏') {
      setState(
        () => _favorites.contains(item)
            ? _favorites.remove(item)
            : _favorites.add(item),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: 'Jobs Demo $item'));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr(context, '已复制'))));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '弹出菜单'))),
    body: _items.isEmpty
        ? JobsEmptyState(
            title: '暂无数据',
            onReload: () => setState(() => _items = [1, 2, 3]),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: _items
                .map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text('Jobs Demo $item'),
                      leading: Icon(
                        _favorites.contains(item)
                            ? Icons.favorite
                            : Icons.favorite_outline,
                      ),
                      subtitle: Text(tr(context, '弹出菜单')),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) => _action(action, item),
                        itemBuilder: (_) => ['复制', '收藏', '删除']
                            .map(
                              (key) => PopupMenuItem(
                                value: key,
                                child: Text(tr(context, key)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
  );
}
