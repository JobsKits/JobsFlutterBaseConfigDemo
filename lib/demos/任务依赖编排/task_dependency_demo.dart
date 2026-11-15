import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const JobsDemoApp(home: TaskDependencyDemo()));

class TaskDependencyDemo extends StatefulWidget {
  const TaskDependencyDemo({super.key});

  @override
  State<TaskDependencyDemo> createState() => _TaskDependencyDemoState();
}

class _TaskDependencyDemoState extends State<TaskDependencyDemo> {
  final _states = <String, String>{'A': '等待', 'B': '等待', 'C': '等待', 'D': '等待'};
  final _values = <String, int>{};
  bool _fail = false;
  bool _running = false;
  int _generation = 0;

  bool _current(int generation) => mounted && generation == _generation;

  Future<int> _task(
    String name,
    int generation,
    Future<int> Function() action,
  ) async {
    if (!_current(generation)) throw const _TaskCancelled();
    setState(() => _states[name] = '运行中');
    try {
      for (var index = 0; index < 5; index++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (!_current(generation)) throw const _TaskCancelled();
      }
      final value = await action();
      if (!_current(generation)) throw const _TaskCancelled();
      setState(() {
        _states[name] = '成功';
        _values[name] = value;
      });
      return value;
    } catch (error) {
      if (_current(generation)) setState(() => _states[name] = '失败');
      rethrow;
    }
  }

  Future<void> _start() async {
    if (_running) return;
    final generation = ++_generation;
    final shouldFail = _fail;
    setState(() {
      _running = true;
      _values.clear();
      _states.updateAll((_, _) => '等待');
    });
    try {
      // A、B 并行；C 同时依赖两者；D 只在 C 成功后持久化结果。
      final inputs = await Future.wait([
        _task('A', generation, () async => 21),
        _task('B', generation, () async => 2),
      ]);
      final result = await _task('C', generation, () async {
        if (shouldFail) throw StateError('C');
        return inputs[0] * inputs[1];
      });
      await _task('D', generation, () async {
        if (!_current(generation)) throw const _TaskCancelled();
        final preferences = await SharedPreferences.getInstance();
        if (!_current(generation)) throw const _TaskCancelled();
        if (!await preferences.setString(
          'jobs_demo_task_result',
          jsonEncode({'value': result}),
        )) {
          throw StateError('storage');
        }
        return result;
      });
    } catch (_) {
      if (_current(generation)) {
        setState(() {
          _states.updateAll((_, value) => value == '等待' ? '请先完成前置任务' : value);
        });
      }
    } finally {
      if (_current(generation)) setState(() => _running = false);
    }
  }

  void _cancel() {
    _generation++;
    setState(() {
      _running = false;
      _states.updateAll(
        (_, value) => value == '运行中' || value == '等待' ? '已取消' : value,
      );
    });
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '任务依赖'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'A (21) + B (2) → C (A × B) → D (SharedPreferences)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text('${tr(context, '模拟失败')} · C'),
          value: _fail,
          onChanged: _running ? null : (value) => setState(() => _fail = value),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _running ? null : _start,
              child: Text(tr(context, '开始')),
            ),
            OutlinedButton(
              onPressed: _running ? _cancel : null,
              child: Text(tr(context, '取消')),
            ),
            OutlinedButton(
              onPressed: _running ? null : _start,
              child: Text(tr(context, '重试')),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final entry in _states.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(entry.key)),
                title: Text(tr(context, entry.value)),
                subtitle: _values.containsKey(entry.key)
                    ? Text('${_values[entry.key]}')
                    : null,
                trailing: entry.value == '运行中'
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : null,
              ),
            ),
          ),
      ],
    ),
  );
}

class _TaskCancelled implements Exception {
  const _TaskCancelled();
}
