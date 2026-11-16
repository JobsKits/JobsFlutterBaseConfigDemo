// 独立运行：flutter run -t "lib/demos/购物车步进/购物车步进.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

void main() =>
    runApp(const JobsDemoApp(home: CartStepperDemo(), title: '购物车步进'));

class CartStepperDemo extends StatefulWidget {
  const CartStepperDemo({super.key});
  @override
  State<CartStepperDemo> createState() => _CartStepperState();
}

class _CartStepperState extends State<CartStepperDemo> {
  List<int> counts = [1, 2, 0];
  @override
  void initState() {
    super.initState();
    UiDemoStore.read('cart', counts).then((v) {
      if (mounted && v is List && v.length == 3)
        setState(
          () => counts = v.map((n) => (n as num).toInt().clamp(0, 99)).toList(),
        );
    });
  }

  void change(int i, int value) {
    setState(() => counts[i] = value.clamp(0, 99));
    UiDemoStore.write('cart', counts).then((result) {
      if (mounted && result is List && result.length == 3)
        setState(
          () => counts = result
              .map((n) => (n as num).toInt().clamp(0, 99))
              .toList(),
        );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '购物车步进'))),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < 3; i++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ['Flutter', 'Dart', 'Jobs'][i],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      IconButton(
                        onPressed: counts[i] == 0
                            ? null
                            : () => change(i, counts[i] - 1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 72,
                        child: TextFormField(
                          key: ValueKey('$i-${counts[i]}'),
                          initialValue: '${counts[i]}',
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onFieldSubmitted: (v) =>
                              change(i, int.tryParse(v) ?? counts[i]),
                        ),
                      ),
                      IconButton(
                        onPressed: counts[i] == 99
                            ? null
                            : () => change(i, counts[i] + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      Text('× ${[12, 8, 5][i]}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          '${uiTr(context, '总计')}: ${counts[0] * 12 + counts[1] * 8 + counts[2] * 5}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(uiTr(context, '本地演示')),
      ],
    ),
  );
}
