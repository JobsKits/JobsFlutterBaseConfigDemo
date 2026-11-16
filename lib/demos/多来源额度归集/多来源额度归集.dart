// 独立运行：flutter run -t "lib/demos/多来源额度归集/多来源额度归集.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

// Match the Material API exported by the existing demo foundation.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/workflow_strings.dart';
import '../工作流共用/共用视图.dart';
import '../工作流共用/演示数据.dart';
import '归集模型.dart';

void main() => runApp(const JobsDemoApp(home: MultiSourceCollectionDemo()));

class MultiSourceCollectionDemo extends StatefulWidget {
  const MultiSourceCollectionDemo({super.key, this.store});
  final WorkflowStore? store;
  @override
  State<MultiSourceCollectionDemo> createState() =>
      _MultiSourceCollectionDemoState();
}

class _MultiSourceCollectionDemoState extends State<MultiSourceCollectionDemo> {
  late final _store = widget.store ?? WorkflowStore();
  var _engine = CollectionEngine.sample();
  var _online = false, _busy = false;
  var _request = 0;
  String? _category;
  static const _states = ['待归集', '归集中', '已归集', '失败', '已取消'];
  String _amount(int value) => (value / 100).toStringAsFixed(2);
  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (_engine.running) return;
    final request = ++_request;
    setState(() => _busy = true);
    final result = await _store.load(
      'workflow-collection',
      _engine.toJson(),
      CollectionEngine.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _engine = CollectionEngine.fromJson(result.value);
      _online = result.online;
      _busy = false;
    });
  }

  Future<void> _persist() async {
    final request = ++_request;
    setState(() => _busy = true);
    final result = await _store.save(
      'workflow-collection',
      _engine.toJson(),
      CollectionEngine.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _engine = CollectionEngine.fromJson(result.value);
      _online = result.online;
      _busy = false;
    });
  }

  Future<bool> _collect(CollectionSource source, String token) async {
    final value = {
      'token': token,
      'source': source.id,
      'units': source.units,
      'success': !(source.id == 'docs' && source.attempts == 1),
    };
    bool accepts(Map<String, dynamic> data) =>
        data['token'] == token &&
        data['source'] == source.id &&
        data['units'] == source.units &&
        data['success'] is bool;
    final result = await _store.save(
      'workflow-collection-source-${source.id}',
      value,
      accepts,
    );
    if (mounted && _engine.running) setState(() => _online = result.online);
    return result.value['success'] == true;
  }

  Future<void> _start({bool failuresOnly = false}) async {
    if (_busy || _engine.running) return;
    final candidates = _engine.sources
        .where(
          (s) =>
              !_engine.committed(s.token) &&
              (failuresOnly ? s.status == CollectionStatus.failed : s.selected),
        )
        .toList();
    if (candidates.isEmpty) return;
    setState(() => _busy = true);
    final confirmed = await workflowConfirm(
      context,
      '预览归集',
      '${workflowTr(context, '样例额度，不是真实资金')}\n\n${candidates.map((s) => '${workflowTr(context, s.titleKey)}  ${_amount(s.units)}').join('\n')}\n\n${workflowTr(context, '合计')}  ${_amount(candidates.fold(0, (sum, s) => sum + s.units))}',
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!confirmed) return;
    final engine = _engine;
    await engine.run(_collect, () {
      if (mounted && identical(engine, _engine)) {
        setState(() {});
        unawaited(
          _store
              .checkpoint('workflow-collection', engine.toJson())
              .catchError((Object _) {}),
        );
      }
    }, failuresOnly: failuresOnly);
    if (!mounted || !identical(engine, _engine)) return;
    await _persist();
  }

  void _cancel() {
    _engine.cancel();
    setState(() {});
    // Persist the completed ledger even if an in-flight source responds later.
    unawaited(_persist());
  }

  @override
  void dispose() {
    _request++;
    _engine.cancel();
    if (widget.store == null) _store.close();
    super.dispose();
  }

  Widget _summary() {
    final pending = _engine.sources
        .where((s) => s.selected && !_engine.committed(s.token))
        .fold(0, (sum, s) => sum + s.units);
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              workflowTr(context, '已归集'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _amount(_engine.collected),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text('${workflowTr(context, '待归集')}  ${_amount(pending)}'),
            const SizedBox(height: 16),
            Text(workflowTr(context, '样例额度，不是真实资金')),
            const SizedBox(height: 12),
            Text(workflowTr(context, '已完成项保留，重复执行不会重复累计')),
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('collection-start'),
              onPressed: _busy || _engine.running || pending == 0
                  ? null
                  : _start,
              child: Text(workflowTr(context, '预览归集')),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed:
                  _busy ||
                      _engine.running ||
                      !_engine.sources.any(
                        (s) => s.status == CollectionStatus.failed,
                      )
                  ? null
                  : () => _start(failuresOnly: true),
              child: Text(workflowTr(context, '仅重试失败项')),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _engine.running ? _cancel : null,
              child: Text(workflowTr(context, '取消')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sources() {
    final sources = _engine.sources
        .where((s) => _category == null || s.categoryKey == _category)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in <String?>[null, '工作区', '项目'])
              ChoiceChip(
                label: Text(workflowTr(context, category ?? '全部')),
                selected: _category == category,
                onSelected: (_) => setState(() => _category = category),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          workflowTr(context, '文档来源首次演示失败'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (sources.isEmpty)
          SizedBox(height: 200, child: WorkflowEmpty(onReload: _reload)),
        for (final source in sources)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: source.selected,
                      onChanged:
                          _busy ||
                              _engine.running ||
                              _engine.committed(source.token)
                          ? null
                          : (v) {
                              setState(() => source.selected = v ?? false);
                              _persist();
                            },
                      title: Text(workflowTr(context, source.titleKey)),
                      subtitle: Text(workflowTr(context, source.categoryKey)),
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _amount(source.units),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Chip(
                          avatar: source.status == CollectionStatus.running
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  source.status == CollectionStatus.success
                                      ? Icons.check_circle_outline
                                      : source.status == CollectionStatus.failed
                                      ? Icons.error_outline
                                      : Icons.circle_outlined,
                                  size: 18,
                                ),
                          label: Text(
                            workflowTr(context, _states[source.status.index]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => WorkflowShell(
    title: '多来源额度归集',
    online: _online,
    busy: _busy || _engine.running,
    onRefresh: _busy || _engine.running ? null : _reload,
    body: LayoutBuilder(
      builder: (context, bounds) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (bounds.maxWidth >= 950)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _sources()),
                const SizedBox(width: 20),
                SizedBox(width: 310, child: _summary()),
              ],
            )
          else ...[
            _summary(),
            const SizedBox(height: 20),
            _sources(),
          ],
          const Divider(height: 32),
          Text(
            workflowTr(context, '结果账本'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (_engine.receipts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(workflowTr(context, '选择来源后预览')),
            ),
          for (final receipt in _engine.receipts)
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text('${receipt.sourceId}  +${_amount(receipt.units)}'),
              subtitle: SelectableText(receipt.token),
            ),
        ],
      ),
    ),
  );
}
