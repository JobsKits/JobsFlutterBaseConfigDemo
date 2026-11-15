import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: SlideUnlockDemo()));

class SlideUnlockDemo extends StatefulWidget {
  const SlideUnlockDemo({super.key});
  @override
  State<SlideUnlockDemo> createState() => _SlideUnlockDemoState();
}

class _SlideUnlockDemoState extends State<SlideUnlockDemo> {
  double _value = 0;
  bool get _unlocked => _value == 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '滑动解锁'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Icon(
          _unlocked ? Icons.lock_open : Icons.lock_outline,
          size: 88,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          tr(context, _unlocked ? '已解锁' : '拖动滑块完成解锁'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 32),
        Semantics(
          label: tr(context, '滑动解锁'),
          child: Slider(
            value: _value,
            onChanged: _unlocked
                ? null
                : (value) => setState(() => _value = value),
            onChangeEnd: (value) =>
                setState(() => _value = value > .94 ? 1 : 0),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => setState(() => _value = 0),
          child: Text(tr(context, '重新锁定')),
        ),
      ],
    ),
  );
}
