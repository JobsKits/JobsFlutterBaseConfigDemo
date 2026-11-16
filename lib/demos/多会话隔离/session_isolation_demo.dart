// 独立运行：flutter run -t "lib/demos/多会话隔离/session_isolation_demo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const JobsDemoApp(home: SessionIsolationDemo()));

class SessionIsolationDemo extends StatefulWidget {
  const SessionIsolationDemo({super.key});

  @override
  State<SessionIsolationDemo> createState() => _SessionIsolationDemoState();
}

class _SessionIsolationDemoState extends State<SessionIsolationDemo> {
  final _input = TextEditingController();
  final _drafts = <String, String>{};
  String _session = 'A';
  bool _busy = true;
  String _status = '';
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _key(String session) => 'jobs_demo_session.$session.note';

  Future<void> _load() async {
    final session = _session;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _status = '';
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted || generation != _generation) return;
      final content =
          _drafts[session] ?? preferences.getString(_key(session)) ?? '';
      setState(() {
        _input.text = content;
        _busy = false;
        _status = '读取';
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _busy = false;
          _status = '失败';
        });
      }
    }
  }

  Future<void> _save() async {
    final session = _session;
    final content = _input.text;
    final generation = ++_generation;
    setState(() => _busy = true);
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(_key(session), content);
      if (!mounted || generation != _generation) return;
      if (saved) _drafts.remove(session);
      setState(() {
        _busy = false;
        _status = saved ? '已保存' : '保存失败';
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _busy = false;
          _status = '保存失败';
        });
      }
    }
  }

  void _switch(String session) {
    _drafts[_session] = _input.text;
    setState(() => _session = session);
    _load();
  }

  @override
  void dispose() {
    _generation++;
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(tr(context, '多会话隔离'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          tr(context, '独立存储'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: ['A', 'B', 'C']
              .map(
                (session) => ChoiceChip(
                  label: Text('${tr(context, '会话')} $session'),
                  selected: session == _session,
                  onSelected: _busy ? null : (_) => _switch(session),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        SelectableText(_key(_session)),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('session-content'),
          enabled: !_busy,
          controller: _input,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(labelText: tr(context, '内容')),
        ),
        const SizedBox(height: 16),
        if (_busy) const LinearProgressIndicator(),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(tr(context, '保存')),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () {
                      _drafts.remove(_session);
                      _load();
                    },
              child: Text(tr(context, '读取')),
            ),
          ],
        ),
        if (_status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Semantics(
              liveRegion: true,
              child: Text(tr(context, _status)),
            ),
          ),
      ],
    ),
  );
}
