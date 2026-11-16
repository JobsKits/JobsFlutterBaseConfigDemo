// 独立运行：flutter run -t "lib/demos/通知处理收件箱/通知处理收件箱.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

// Match the Material API exported by the existing demo foundation.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/workflow_strings.dart';
import '../工作流共用/共用视图.dart';
import '../工作流共用/演示数据.dart';
import '通知模型.dart';

void main() => runApp(const JobsDemoApp(home: NotificationInboxDemo()));

class NotificationInboxDemo extends StatefulWidget {
  const NotificationInboxDemo({super.key, this.store});
  final WorkflowStore? store;
  @override
  State<NotificationInboxDemo> createState() => _NotificationInboxDemoState();
}

class _NotificationInboxDemoState extends State<NotificationInboxDemo> {
  late final _store = widget.store ?? WorkflowStore();
  var _board = InboxBoard.sample;
  final _selected = <String>{};
  Map<String, InboxNotice>? _undo;
  String? _repository, _reason, _message;
  var _tab = 0, _request = 0;
  var _busy = false, _online = false, _fail = false;
  List<InboxNotice> get _visible => _board.filter(
    repository: _repository,
    reason: _reason,
    unread: _tab == 0,
    archived: _tab == 2,
  );

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final request = ++_request;
    setState(() => _busy = true);
    final result = await _store.load(
      'workflow-inbox',
      _board.toJson(),
      InboxBoard.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _board = InboxBoard.fromJson(result.value);
      _online = result.online;
      _busy = false;
      _undo = null;
      _selected.clear();
    });
  }

  void _filter(VoidCallback update) => setState(() {
    update();
    _selected.retainAll(_visible.map((i) => i.id));
  });
  Future<void> _apply(Set<String> ids, InboxAction action) async {
    if (_busy || ids.isEmpty) return;
    final request = ++_request;
    final before = {
      for (final i in _board.items)
        if (ids.contains(i.id)) i.id: i,
    };
    final fail = _fail;
    final next = fail ? _board : _board.change(ids, action);
    setState(() {
      _busy = true;
      _message = null;
      _fail = false;
    });
    final result = await _store.save(
      fail ? 'workflow-inbox-failed-attempt' : 'workflow-inbox',
      next.toJson(),
      InboxBoard.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _busy = false;
      if (fail) {
        _message = '操作未完成，原条目已保留';
        return;
      }
      _board = InboxBoard.fromJson(result.value);
      _online = result.online;
      _undo = before;
      _selected.clear();
    });
  }

  Future<void> _restore() async {
    if (_busy || _undo == null) return;
    final request = ++_request;
    final next = _board.restore(_undo!);
    setState(() => _busy = true);
    final result = await _store.save(
      'workflow-inbox',
      next.toJson(),
      InboxBoard.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _board = InboxBoard.fromJson(result.value);
      _online = result.online;
      _busy = false;
      _undo = null;
    });
  }

  @override
  void dispose() {
    _request++;
    if (widget.store == null) _store.close();
    super.dispose();
  }

  Widget _notice(InboxNotice item) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _selected.contains(item.id),
                onChanged: _busy
                    ? null
                    : (v) => setState(() {
                        if (v == true) {
                          _selected.add(item.id);
                        } else {
                          _selected.remove(item.id);
                        }
                      }),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.repository,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        workflowTr(context, item.titleKey),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<InboxAction>(
                enabled: !_busy,
                tooltip: workflowTr(context, '变更'),
                onSelected: (action) => _apply({item.id}, action),
                itemBuilder: (context) => [
                  if (!item.read)
                    PopupMenuItem(
                      value: InboxAction.read,
                      child: Text(workflowTr(context, '标为已读')),
                    ),
                  PopupMenuItem(
                    value: InboxAction.archive,
                    child: Text(
                      workflowTr(context, item.archived ? '恢复' : '归档'),
                    ),
                  ),
                  PopupMenuItem(
                    value: InboxAction.subscription,
                    child: Text(
                      workflowTr(context, item.subscribed ? '取消订阅' : '订阅'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(workflowTr(context, item.reasonKey))),
                Chip(
                  avatar: Icon(item.read ? Icons.done : Icons.circle, size: 14),
                  label: Text(workflowTr(context, item.read ? '已读' : '未读')),
                ),
                Chip(
                  avatar: Icon(
                    item.subscribed
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    size: 16,
                  ),
                  label: Text(
                    workflowTr(context, item.subscribed ? '已订阅' : '未订阅'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final repositories = _board.items.map((i) => i.repository).toSet().toList()
      ..sort();
    return WorkflowShell(
      title: '通知处理收件箱',
      online: _online,
      busy: _busy,
      onRefresh: _busy ? null : _reload,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < 3; i++)
                        ChoiceChip(
                          label: Text(
                            workflowTr(context, ['未读', '全部', '已归档'][i]),
                          ),
                          selected: _tab == i,
                          onSelected: (_) => _filter(() => _tab = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_repository),
                    initialValue: repositories.contains(_repository)
                        ? _repository
                        : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: workflowTr(context, '仓库'),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(workflowTr(context, '全部')),
                      ),
                      for (final repo in repositories)
                        DropdownMenuItem(value: repo, child: Text(repo)),
                    ],
                    onChanged: (v) => _filter(() => _repository = v),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final reason in <String?>[null, '提及', '分配', '关注'])
                        FilterChip(
                          label: Text(workflowTr(context, reason ?? '全部')),
                          selected: _reason == reason,
                          onSelected: (_) => _filter(() => _reason = reason),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _busy || visible.isEmpty
                            ? null
                            : () => setState(() {
                                final ids = visible.map((i) => i.id).toSet();
                                if (_selected.containsAll(ids)) {
                                  _selected.removeAll(ids);
                                } else {
                                  _selected.addAll(ids);
                                }
                              }),
                        child: Text(
                          '${workflowTr(context, '选中可见项')} · ${_selected.length}',
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: _busy || _selected.isEmpty
                            ? null
                            : () => _apply(Set.of(_selected), InboxAction.read),
                        child: Text(workflowTr(context, '标为已读')),
                      ),
                      OutlinedButton(
                        onPressed: _busy || _selected.isEmpty
                            ? null
                            : () => _apply(
                                Set.of(_selected),
                                InboxAction.archive,
                              ),
                        child: Text(
                          workflowTr(context, _tab == 2 ? '恢复' : '归档'),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _busy || _selected.isEmpty
                            ? null
                            : () => _apply(
                                Set.of(_selected),
                                InboxAction.subscription,
                              ),
                        child: Text(workflowTr(context, '切换订阅')),
                      ),
                      TextButton(
                        onPressed: _busy || _undo == null ? null : _restore,
                        child: Text(workflowTr(context, '撤销上次操作')),
                      ),
                      TextButton(
                        onPressed: () => _filter(() {
                          _repository = null;
                          _reason = null;
                        }),
                        child: Text(workflowTr(context, '清除筛选')),
                      ),
                    ],
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _fail,
                    title: Text(workflowTr(context, '模拟本次失败')),
                    onChanged: _busy ? null : (v) => setState(() => _fail = v),
                  ),
                  if (_message != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        workflowTr(context, _message!),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: WorkflowEmpty(onReload: _reload),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _notice(visible[i]),
              ),
            ),
        ],
      ),
    );
  }
}
