// 独立运行：flutter run -t "lib/demos/运行时配置热更新/运行时配置热更新.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: RuntimePatchDemo(), title: '运行时配置热更新'));

class RuntimePatchDemo extends StatefulWidget {
  const RuntimePatchDemo({super.key});
  @override
  State<RuntimePatchDemo> createState() => _State();
}

class _State extends State<RuntimePatchDemo> {
  final registry = JobsLabPatchRegistry()
    ..register('card', {'title': 'Jobs', 'size': 24.0, 'color': 0xff176653});
  final input = TextEditingController(
    text: '{"title":"Flutter","size":36.0,"color":4281554282}',
  );
  String error = '';
  @override
  void dispose() {
    registry.rollback('card');
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = registry.resolve('card');
    return LabFrame(
      title: '运行时配置热更新',
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          color: Color(values['color'] as int),
          child: Text(
            values['title'] as String,
            style: TextStyle(
              fontSize: values['size'] as double,
              color: Colors.white,
            ),
          ),
        ),
        TextField(
          controller: input,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'JSON patch / card'),
        ),
        Wrap(
          spacing: 8,
          children: [
            labAction(context, '应用', () {
              try {
                registry.apply(
                  'card',
                  Map<String, dynamic>.from(jsonDecode(input.text) as Map),
                );
                setState(() => error = '');
              } catch (e) {
                setState(() => error = e.toString());
              }
            }),
            labAction(
              context,
              '恢复默认',
              () => setState(() => registry.rollback('card')),
            ),
          ],
        ),
        if (error.isNotEmpty) labOutput(context, error),
      ],
    );
  }
}
