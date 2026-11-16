// 独立运行：flutter run -t "lib/demos/雪花编号/snowflake_demo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: SnowflakeDemo()));

class SnowflakeDemo extends StatefulWidget {
  const SnowflakeDemo({super.key});

  @override
  State<SnowflakeDemo> createState() => _SnowflakeDemoState();
}

class _SnowflakeDemoState extends State<SnowflakeDemo> {
  int _node = 1;
  final _generators = <int, JobsSnowflake>{};
  JobsSnowflake get _generator =>
      _generators.putIfAbsent(_node, () => JobsSnowflake(node: _node));
  final _ids = <BigInt>[];
  bool _busy = false;
  String? _error;
  int _lastCount = 0;

  Future<void> _generate(int count) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final values = await Future.wait(
        List.generate(count, (_) => _generator.next()),
      );
      if (!mounted) return;
      setState(() {
        _lastCount = values.toSet().length;
        _ids.insertAll(0, values.reversed.take(12));
        if (_ids.length > 12) _ids.removeRange(12, _ids.length);
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rollback() async {
    final clock = DateTime.now().millisecondsSinceEpoch;
    var now = clock;
    final generator = JobsSnowflake(node: 1, clock: () => now);
    await generator.next();
    now -= 100;
    try {
      await generator.next();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr(context, '时间回退'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(tr(context, '雪花ID'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SelectableText(
          '41 bit timestamp + 10 bit node + 12 bit sequence\nBigInt · 4096 IDs / ms / node',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text('${tr(context, '节点')} · $_node'),
            Expanded(
              child: Slider(
                value: _node.toDouble(),
                min: 0,
                max: 1023,
                divisions: 1023,
                label: '$_node',
                onChanged: _busy
                    ? null
                    : (value) => setState(() {
                        _node = value.round();

                        _ids.clear();
                      }),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _busy ? null : () => _generate(1),
              child: Text(tr(context, '生成')),
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _generate(5000),
              child: Text('${tr(context, '批量生成')} · 5000'),
            ),
            OutlinedButton(
              onPressed: _busy ? null : _rollback,
              child: Text(tr(context, '时间回退')),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          SelectableText(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (_lastCount > 0) Text('${tr(context, '成功')} · $_lastCount'),
        const SizedBox(height: 12),
        if (_ids.isEmpty)
          JobsEmptyState(title: '无数据', onReload: () => _generate(1))
        else
          ..._ids.map(
            (id) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      id.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'node: ${(id >> 12) & BigInt.from(1023)}  ·  seq: ${id & BigInt.from(4095)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
