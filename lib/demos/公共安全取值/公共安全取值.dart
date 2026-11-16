// 独立运行：flutter run -t "lib/demos/公共安全取值/公共安全取值.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_safety_get_value/jobs_safety_get_value.dart';

void main() =>
    runApp(const JobsDemoApp(home: SafeValuePackageDemo(), title: '公共安全取值'));

Widget buildLegacyDemo(BuildContext context) => const SafeValuePackageDemo();

class SafeValuePackageDemo extends StatefulWidget {
  const SafeValuePackageDemo({super.key});
  @override
  State<SafeValuePackageDemo> createState() => _SafeValuePackageDemoState();
}

class _SafeValuePackageDemoState extends State<SafeValuePackageDemo> {
  final source = TextEditingController(
    text: '{"name":"Jobs","age":30,"isVip":true}',
  );
  final keyInput = TextEditingController(text: 'name');
  String result = '';
  String type = 'String';
  void evaluate() {
    try {
      final decoded = jsonDecode(source.text);
      if (decoded is! Map) throw const FormatException('JSON object required');
      final key = keyInput.text;
      final Object value = switch (type) {
        'int' => safeGet<int>(decoded, key, -1)!,
        'bool' => safeGet<bool>(decoded, key, false)!,
        _ => safeGet<String>(decoded, key, '(default)')!,
      };
      setState(() => result = '$value  (${value.runtimeType})');
    } catch (error) {
      setState(() => result = '$error');
    }
  }

  @override
  void dispose() {
    source.dispose();
    keyInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: const Text('公共安全取值')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: source,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'JSON'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: keyInput,
          decoration: const InputDecoration(labelText: 'Key'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final item in ['String', 'int', 'bool'])
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (value) => setState(() => type = value!),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: evaluate, child: Text(tr(context, '运行'))),
        const SizedBox(height: 20),
        SelectableText(result),
      ],
    ),
  );
}
