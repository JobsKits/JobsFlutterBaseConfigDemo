// 独立运行：flutter run -t "lib/demos/微应用沙箱/微应用沙箱.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: MicroSandboxDemo(), title: '微应用沙箱'));

class MicroSandboxDemo extends StatefulWidget {
  const MicroSandboxDemo({super.key});
  @override
  State<MicroSandboxDemo> createState() => _State();
}

class _State extends State<MicroSandboxDemo> {
  String app = 'notes';
  final path = TextEditingController(text: 'draft/note.txt');
  final content = TextEditingController(text: 'Jobs');
  String output = '';
  Map<String, String> entries = {};
  JobsLabSandbox get store => JobsLabSandbox('sandbox_$app');
  @override
  void initState() {
    super.initState();
    unawaited(load());
  }

  @override
  void dispose() {
    path.dispose();
    content.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final values = await store.entries();
      if (mounted) setState(() => entries = values);
    } catch (error) {
      if (mounted) setState(() => output = error.toString());
    }
  }

  Future<void> operation(bool write) async {
    try {
      String? result;
      if (write) {
        await store.write(path.text, content.text);
      } else {
        result = await store.read(path.text);
      }
      if (mounted) setState(() => output = write ? 'saved' : '$result');
      await load();
    } catch (error) {
      if (mounted) setState(() => output = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '微应用沙箱',
    children: [
      Wrap(
        spacing: 8,
        children: [
          for (final name in ['notes', 'tasks'])
            ChoiceChip(
              label: Text(name),
              selected: app == name,
              onSelected: (_) async {
                setState(() => app = name);
                await load();
              },
            ),
        ],
      ),
      TextField(
        controller: path,
        decoration: const InputDecoration(labelText: 'relative/path'),
      ),
      TextField(
        controller: content,
        decoration: InputDecoration(labelText: labTr(context, '内容')),
      ),
      Wrap(
        spacing: 8,
        children: [
          labAction(context, '保存', () => operation(true)),
          labAction(context, '读取', () => operation(false)),
          TextButton(
            onPressed: () => setState(() => path.text = '../tasks/private.txt'),
            child: const Text('../tasks/private.txt'),
          ),
        ],
      ),
      labOutput(context, output),
      if (entries.isEmpty) JobsEmptyState(title: '无数据', onReload: load),
      for (final entry in entries.entries)
        ListTile(
          title: Text(entry.key),
          subtitle: Text(entry.value),
          trailing: IconButton(
            tooltip: labTr(context, '删除'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await store.remove(entry.key);
              await load();
            },
          ),
        ),
    ],
  );
}
