// 独立运行：flutter run -t "lib/demos/数字动效/数字动效.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: AnimatedNumberDemo()));

class AnimatedNumberDemo extends StatefulWidget {
  const AnimatedNumberDemo({super.key});
  @override
  State<AnimatedNumberDemo> createState() => _AnimatedNumberDemoState();
}

class _AnimatedNumberDemoState extends State<AnimatedNumberDemo> {
  double _target = 1200;
  double _from = 0;
  void _change(double delta) => setState(() {
    _from = _target;
    _target = (_target + delta).clamp(0, 999999);
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(tr(context, '数字动效'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Text(
          tr(context, '目标数值'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: _from, end: _target),
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () => _change(-138),
              icon: const Icon(Icons.remove),
              label: Text(tr(context, '减少')),
            ),
            FilledButton.icon(
              onPressed: () => _change(138),
              icon: const Icon(Icons.add),
              label: Text(tr(context, '增加')),
            ),
            TextButton(
              onPressed: () => setState(() {
                _from = _target;
                _target = 0;
              }),
              child: Text(tr(context, '恢复默认')),
            ),
          ],
        ),
      ],
    ),
  );
}
