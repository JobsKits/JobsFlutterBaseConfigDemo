import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: SafeDecodeDemo(), title: '安全模型解码'));

class SafeDecodeDemo extends StatefulWidget {
  const SafeDecodeDemo({super.key});
  @override
  State<SafeDecodeDemo> createState() => _State();
}

class _State extends State<SafeDecodeDemo> {
  final input = TextEditingController(
    text: '{"name":"Jobs","age":"18","enabled":null,"items":[1,"2",null]}',
  );
  String output = '';
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void decode() {
    try {
      final object = jsonDecode(input.text);
      if (object is! Map<String, dynamic>)
        throw const FormatException('JSON root must be an object');
      final name = object['name'] is String ? object['name'] as String : '';
      final age = object['age'] is num
          ? (object['age'] as num).toInt()
          : int.tryParse('${object['age']}') ?? 0;
      final enabled = object['enabled'] == true;
      final items = (object['items'] is List ? object['items'] as List : [])
          .map((e) => int.tryParse('$e'))
          .whereType<int>()
          .toList();
      setState(
        () => output = const JsonEncoder.withIndent('  ').convert({
          'name': name,
          'age': age,
          'enabled': enabled,
          'items': items,
          'fallbacks': {'name': '', 'age': 0, 'enabled': false, 'items': []},
        }),
      );
    } catch (error) {
      setState(() => output = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '安全模型解码',
    children: [
      TextField(
        controller: input,
        minLines: 4,
        maxLines: 10,
        decoration: const InputDecoration(labelText: 'JSON'),
      ),
      labAction(context, '校验', decode),
      labOutput(context, output),
    ],
  );
}
