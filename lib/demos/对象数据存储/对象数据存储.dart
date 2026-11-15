import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: ObjectStoreDemo(), title: '对象数据存储'));

class ObjectStoreDemo extends StatefulWidget {
  const ObjectStoreDemo({super.key});
  @override
  State<ObjectStoreDemo> createState() => _State();
}

class _State extends State<ObjectStoreDemo> {
  final store = JobsLabRecordStore('object_store');
  final name = TextEditingController();
  final age = TextEditingController(text:"18");
  final query = TextEditingController();
  List<Map<String, dynamic>> rows = [];
  String? error;
  String? editing;
  @override
  void initState() {
    super.initState();
    unawaited(load());
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    query.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final values = await store.query(contains: query.text);
      if (mounted)
        setState(() {
          rows = values;
          error = null;
        });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) return;
    final years=int.tryParse(age.text);
    if(years==null||years<0){setState(()=>error='Invalid age');return;}
    await store.put(
      editing ?? DateTime.now().microsecondsSinceEpoch.toString(),
      {'name': name.text.trim(),
        'age':years, 'updated': DateTime.now().toIso8601String()},
    );
    name.clear();
    editing = null;
    await load();
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '对象数据存储',
    children: [
      TextField(
        controller: name,
        decoration: InputDecoration(labelText: labTr(context, '内容')),
      ),
      TextField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'Age')),
      Wrap(
        spacing: 8,
        children: [
          labAction(context, '保存', save),
          TextButton(
            onPressed: () {
              name.clear();
              setState(() => editing = null);
            },
            child: Text(labTr(context, '取消')),
          ),
        ],
      ),
      TextField(
        controller: query,
        onChanged: (_) => load(),
        decoration: InputDecoration(labelText: labTr(context, '搜索功能')),
      ),
      if (error != null) labOutput(context, error),
      if (rows.isEmpty)
        JobsEmptyState(title: labTr(context, '无数据'), onReload: load),
      for (final row in rows)
        ListTile(
          title: Text('${row['name']}'),
          subtitle: Text('${row['age']} / ${row['updated']}'),
          selected: editing==row['id'],
          onTap: () => setState(() {
            editing = row['id'] as String;
            name.text = row['name'] as String;
            age.text='${row['age'] ?? 0}';
          }),
          trailing: IconButton(
            tooltip: labTr(context, '删除'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await store.delete(row['id'] as String);
              await load();
            },
          ),
        ),
    ],
  );
}
