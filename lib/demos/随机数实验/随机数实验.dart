// 独立运行：flutter run -t "lib/demos/随机数实验/随机数实验.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/lab_support.dart';

void main() => runApp(const JobsDemoApp(home: RandomLabDemo(), title: '随机数实验'));

class RandomLabDemo extends StatefulWidget {
  const RandomLabDemo({super.key});
  @override
  State<RandomLabDemo> createState() => _State();
}

class _State extends State<RandomLabDemo> {
  final seed = TextEditingController(text: '42');
  final limit = TextEditingController(text: '10');
  bool secure = false;
  List<int> values = [];
  String? error;
  @override
  void dispose() {
    seed.dispose();
    limit.dispose();
    super.dispose();
  }

  void generate() {
    try {
      final bound = int.parse(limit.text);
      if (bound < 1 || bound > 10000)
        throw const FormatException('Range: 1…10000');
      final random = secure ? Random.secure() : Random(int.parse(seed.text));
      setState(() {
        values = List.generate(100, (_) => random.nextInt(bound));
        error = null;
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '随机数实验',
    children: [
      SwitchListTile(
        title: const Text('Random.secure'),
        value: secure,
        onChanged: (v) => setState(() => secure = v),
      ),
      TextField(
        controller: seed,
        decoration: const InputDecoration(labelText: 'Seed'),
        keyboardType: TextInputType.number,
      ),
      TextField(
        controller: limit,
        decoration: const InputDecoration(labelText: '0 ≤ n < bound'),
        keyboardType: TextInputType.number,
      ),
      labAction(context, '生成', generate),
      if (error != null) labOutput(context, error),
      labOutput(context, values.join(', ')),
      if (values.isNotEmpty)
        for (final entry in values.fold<Map<int, int>>({}, (map, n) {
          map[n] = (map[n] ?? 0) + 1;
          return map;
        }).entries)
          Row(
            children: [
              SizedBox(width: 40, child: Text('${entry.key}')),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value / values.length,
                ),
              ),
              SizedBox(width: 40, child: Text('${entry.value}')),
            ],
          ),
    ],
  );
}
