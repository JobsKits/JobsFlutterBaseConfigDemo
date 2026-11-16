// 独立运行：flutter run -t "lib/demos/实时报价确认/实时报价确认.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

// Match the Material API exported by the existing demo foundation.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/workflow_strings.dart';
import '../工作流共用/共用视图.dart';
import '../工作流共用/演示数据.dart';
import '报价模型.dart';

void main() => runApp(const JobsDemoApp(home: LiveQuoteConfirmationDemo()));

class LiveQuoteConfirmationDemo extends StatefulWidget {
  const LiveQuoteConfirmationDemo({
    super.key,
    this.store,
    this.autoUpdate = true,
  });
  final WorkflowStore? store;
  final bool autoUpdate;
  @override
  State<LiveQuoteConfirmationDemo> createState() =>
      _LiveQuoteConfirmationDemoState();
}

class _LiveQuoteConfirmationDemoState extends State<LiveQuoteConfirmationDemo> {
  late final _store = widget.store ?? WorkflowStore();
  var _book = QuoteBook.sample;
  late bool _auto = widget.autoUpdate;
  var _online = false, _busy = false, _submitting = false;
  var _request = 0;
  String? _message;
  Timer? _timer;
  static const _policies = ['接受任意变化', '仅接受降价', '每次手动确认'];
  String _amount(int cents) => (cents / 100).toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    _reload();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_auto &&
          !_busy &&
          mounted &&
          ModalRoute.of(context)?.isCurrent == true) {
        _change(_book.tick());
      }
    });
  }

  Future<void> _reload() async {
    final request = ++_request;
    setState(() => _busy = true);
    final result = await _store.load(
      'workflow-quotes',
      _book.toJson(),
      QuoteBook.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _book = QuoteBook.fromJson(result.value);
      _online = result.online;
      _busy = false;
    });
  }

  Future<void> _change(QuoteBook next) async {
    if (_busy) return;
    final request = ++_request;
    setState(() {
      _book = next;
      _busy = true;
      _message = null;
    });
    final result = await _store.save(
      'workflow-quotes',
      next.toJson(),
      QuoteBook.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _book = QuoteBook.fromJson(result.value);
      _online = result.online;
      _busy = false;
    });
  }

  Future<void> _submit() async {
    if (!_book.canSubmit || _submitting || _busy) return;
    final fingerprint = _book.fingerprint;
    final snapshot = _book.toJson();
    setState(() => _submitting = true);
    final accepted = await workflowConfirm(
      context,
      '确认样例订单',
      '${workflowTr(context, '样例点数，不涉及支付')}\n\nv${_book.version} · ${workflowTr(context, '合计')} ${_amount(_book.total)}',
    );
    if (!mounted) return;
    if (!accepted) {
      setState(() => _submitting = false);
      return;
    }
    if (fingerprint != _book.fingerprint || !_book.canSubmit) {
      setState(() {
        _submitting = false;
        _message = '确认期间报价已变化，请重试';
      });
      return;
    }
    final result = await _store.save(
      'workflow-quote-order',
      snapshot,
      QuoteBook.accepts,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _online = result.online;
      final returned = QuoteBook.fromJson(result.value);
      final unchanged =
          fingerprint == _book.fingerprint &&
          returned.fingerprint == fingerprint;
      if (result.online && !unchanged) _book = returned;
      _message = unchanged ? '样例订单已记录' : '确认期间报价已变化，请重试';
    });
  }

  @override
  void dispose() {
    _request++;
    _timer?.cancel();
    if (widget.store == null) _store.close();
    super.dispose();
  }

  Widget _item(QuoteItem item) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: item.selected,
            onChanged: _busy
                ? null
                : (value) => _change(
                    _book.edit(item.id, (i) => i.copy(selected: value)),
                  ),
            title: Text(
              workflowTr(context, item.titleKey),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(item.id),
          ),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              Text(
                '${workflowTr(context, '最新报价')}  ${_amount(item.cents)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${workflowTr(context, '已接受报价')}  ${_amount(item.acceptedCents ?? 0)}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${workflowTr(context, '数量')} · ${item.quantity}'),
              IconButton(
                tooltip: '${workflowTr(context, '数量')} −',
                onPressed: _busy || item.quantity <= 1
                    ? null
                    : () => _change(
                        _book.edit(
                          item.id,
                          (i) => i.copy(quantity: i.quantity - 1),
                        ),
                      ),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              IconButton(
                tooltip: '${workflowTr(context, '数量')} +',
                onPressed: _busy || item.quantity >= 20
                    ? null
                    : () => _change(
                        _book.edit(
                          item.id,
                          (i) => i.copy(quantity: i.quantity + 1),
                        ),
                      ),
                icon: const Icon(Icons.add_circle_outline),
              ),
              Text('${workflowTr(context, '最低数量')} ${item.minimum}'),
              if (!item.active)
                Chip(
                  avatar: const Icon(Icons.pause_circle_outline, size: 18),
                  label: Text(workflowTr(context, '暂不可用')),
                ),
              if (item.pending)
                Chip(
                  avatar: const Icon(Icons.price_change_outlined, size: 18),
                  label: Text(workflowTr(context, '报价已变化')),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _summary() => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              workflowTr(context, '合计'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _amount(_book.total),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text('v${_book.version} · ${_book.selected.length} / 10'),
            const SizedBox(height: 16),
            Text(workflowTr(context, '样例点数，不涉及支付')),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _busy ? null : () => _change(_book.accept()),
              child: Text(workflowTr(context, '接受当前报价')),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const ValueKey('quote-submit'),
              onPressed: !_book.canSubmit || _busy || _submitting
                  ? null
                  : _submit,
              child: Text(workflowTr(context, '确认样例订单')),
            ),
            if (!_book.canSubmit)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(workflowTr(context, '先处理价格或数量变化')),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(workflowTr(context, _message!)),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => WorkflowShell(
    title: '实时报价确认',
    online: _online,
    busy: _busy || _submitting,
    onRefresh: _busy ? null : _reload,
    body: LayoutBuilder(
      builder: (context, bounds) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final policy in QuotePolicy.values)
                ChoiceChip(
                  label: Text(workflowTr(context, _policies[policy.index])),
                  selected: _book.policy == policy,
                  onSelected: _busy
                      ? null
                      : (_) => _change(_book.withPolicy(policy)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text('${workflowTr(context, '自动更新')} · 5s'),
            value: _auto,
            onChanged: (v) => setState(() => _auto = v),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const ValueKey('quote-tick'),
              onPressed: _busy ? null : () => _change(_book.tick()),
              icon: const Icon(Icons.update),
              label: Text(workflowTr(context, '推进报价')),
            ),
          ),
          const SizedBox(height: 16),
          if (_book.items.isEmpty)
            SizedBox(height: 250, child: WorkflowEmpty(onReload: _reload))
          else if (bounds.maxWidth >= 1000)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (final item in _book.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _item(item),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(width: 300, child: _summary()),
              ],
            )
          else ...[
            for (final item in _book.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _item(item),
              ),
            _summary(),
          ],
        ],
      ),
    ),
  );
}
