// 独立运行：flutter run -t "lib/demos/代码变更审阅/代码变更审阅.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

// Match the Material API exported by the existing demo foundation.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/workflow_strings.dart';
import '../工作流共用/共用视图.dart';
import '../工作流共用/演示数据.dart';
import '审阅模型.dart';

void main() => runApp(const JobsDemoApp(home: CodeChangeReviewDemo()));

class CodeChangeReviewDemo extends StatefulWidget {
  const CodeChangeReviewDemo({super.key, this.store});
  final WorkflowStore? store;
  @override
  State<CodeChangeReviewDemo> createState() => _CodeChangeReviewDemoState();
}

class _CodeChangeReviewDemoState extends State<CodeChangeReviewDemo> {
  late final _store = widget.store ?? WorkflowStore();
  final _search = TextEditingController();
  var _board = ReviewBoard.sample;
  String? _selected = 'price';
  var _hunks = <DiffHunk>[];
  var _busy = false, _online = false, _parsing = false, _badPatch = false;
  var _request = 0, _selection = 0;

  @override
  void initState() {
    super.initState();
    _hunks = parseUnifiedPatch(_board.files.first.patch);
    _reload();
  }

  Future<void> _reload() async {
    final request = ++_request;
    setState(() => _busy = true);
    final result = await _store.load(
      'workflow-review',
      _board.toJson(),
      ReviewBoard.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _board = ReviewBoard.fromJson(result.value);
      _online = result.online;
      _busy = false;
      if (!_board.files.any((f) => f.id == _selected)) {
        _selected = _board.files.firstOrNull?.id;
      }
    });
    if (_selected != null) _select(_selected!);
  }

  Future<void> _select(String id) async {
    final selection = ++_selection;
    final file = _board.files.where((f) => f.id == id).firstOrNull;
    if (file == null) return;
    setState(() {
      _selected = id;
      _parsing = true;
      _badPatch = false;
    });
    try {
      final hunks = await Future(() => parseUnifiedPatch(file.patch));
      if (!mounted || selection != _selection || _selected != id) return;
      setState(() {
        _hunks = hunks;
        _parsing = false;
      });
    } catch (_) {
      if (!mounted || selection != _selection) return;
      setState(() {
        _badPatch = true;
        _parsing = false;
      });
    }
  }

  Future<void> _toggle(ReviewThread thread) async {
    if (_busy) return;
    final request = ++_request;
    final next = _board.toggle(thread.id);
    setState(() => _busy = true);
    final result = await _store.save(
      'workflow-review',
      next.toJson(),
      ReviewBoard.accepts,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _board = ReviewBoard.fromJson(result.value);
      _online = result.online;
      _busy = false;
    });
    if (_selected != null) _select(_selected!);
  }

  @override
  void dispose() {
    _request++;
    _selection++;
    _search.dispose();
    if (widget.store == null) _store.close();
    super.dispose();
  }

  Widget _files() {
    final files = _board.files
        .where((f) => f.path.toLowerCase().contains(_search.text.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: workflowTr(context, '查找文件'),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: files.isEmpty
              ? WorkflowEmpty(
                  onReload: () {
                    _search.clear();
                    _reload();
                  },
                )
              : ListView(
                  children: [
                    for (final file in files)
                      ListTile(
                        key: ValueKey('file-${file.id}'),
                        selected: _selected == file.id,
                        selectedTileColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        leading: const Icon(Icons.description_outlined),
                        title: Text(file.path, softWrap: true),
                        subtitle: Text(
                          '${workflowTr(context, '未解决')} · ${_board.threads.where((t) => t.fileId == file.id && !t.resolved).length}',
                        ),
                        onTap: () => _select(file.id),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _thread(ReviewThread thread) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ExpansionTile(
        key: ValueKey('thread-${thread.id}'),
        initiallyExpanded: !thread.resolved,
        leading: Icon(
          thread.resolved
              ? Icons.check_circle_outline
              : Icons.chat_bubble_outline,
        ),
        title: Text(workflowTr(context, thread.bodyKey)),
        subtitle: Text(
          workflowTr(context, thread.resolved ? '已解决' : '未解决') +
              (thread.line == null
                  ? ''
                  : ' · ${workflowTr(context, thread.oldSide ? '旧行' : '新行')} ${thread.line}'),
        ),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: ValueKey('resolve-${thread.id}'),
              onPressed: _busy ? null : () => _toggle(thread),
              icon: Icon(thread.resolved ? Icons.refresh : Icons.done),
              label: Text(
                workflowTr(context, thread.resolved ? '重新打开' : '标记解决'),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _line(DiffLine line) {
    final colors = Theme.of(context).colorScheme;
    final addition = line.kind == DiffKind.addition;
    final removal = line.kind == DiffKind.removal;
    final marker = addition
        ? '+'
        : removal
        ? '−'
        : ' ';
    final background = addition
        ? colors.primaryContainer
        : removal
        ? colors.errorContainer
        : colors.surface;
    final foreground = addition
        ? colors.onPrimaryContainer
        : removal
        ? colors.onErrorContainer
        : colors.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label:
              '${workflowTr(context, '旧行')} ${line.oldLine?.toString() ?? '—'}, ${workflowTr(context, '新行')} ${line.newLine?.toString() ?? '—'}',
          child: Container(
            color: background,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    line.oldLine?.toString() ?? '',
                    style: TextStyle(color: foreground),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 34,
                  child: Text(
                    line.newLine?.toString() ?? '',
                    style: TextStyle(color: foreground),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableText(
                    '$marker ${line.text}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: foreground,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final thread in _board.inlineFor(_selected!, line))
          _thread(thread),
      ],
    );
  }

  Widget _diff() {
    if (_board.files.isEmpty || _selected == null) {
      return WorkflowEmpty(onReload: _reload);
    }
    if (_parsing) return const Center(child: CircularProgressIndicator());
    if (_badPatch) return WorkflowEmpty(message: '补丁无法解析', onReload: _reload);
    final file = _board.files.firstWhere((f) => f.id == _selected);
    final outdated = _board.outdatedFor(file.id);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SelectableText(
          file.path,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (_hunks.isEmpty)
          SizedBox(
            height: 240,
            child: WorkflowEmpty(message: '此文件没有文本补丁', onReload: _reload),
          ),
        for (final hunk in _hunks) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SelectableText(
              hunk.header,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          for (final line in hunk.lines) _line(line),
        ],
        if (outdated.isNotEmpty) ...[
          const Divider(height: 32),
          Text(
            workflowTr(context, '过时讨论'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final thread in outdated) _thread(thread),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) => WorkflowShell(
    title: '代码变更审阅',
    online: _online,
    busy: _busy,
    onRefresh: _busy ? null : _reload,
    body: LayoutBuilder(
      builder: (context, bounds) {
        if (bounds.maxWidth >= 900) {
          return Row(
            children: [
              SizedBox(width: 280, child: _files()),
              const VerticalDivider(width: 1),
              Expanded(child: _diff()),
            ],
          );
        }
        return Column(
          children: [
            ExpansionTile(
              title: Text(
                '${workflowTr(context, '文件')} · ${_board.files.length}',
              ),
              children: [SizedBox(height: 240, child: _files())],
            ),
            Expanded(child: _diff()),
          ],
        );
      },
    ),
  );
}
