import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/extra_support.dart';

class DirectionalProgressLabDemo extends StatefulWidget {
  const DirectionalProgressLabDemo({super.key});
  @override
  State<DirectionalProgressLabDemo> createState() => _State();
}

class _State extends State<DirectionalProgressLabDemo> {
  double value = .4;
  int direction = 0;
  @override
  Widget build(BuildContext context) => ExtraFrame(
    title: '四向进度',
    children: [
      Wrap(
        spacing: 8,
        children: [
          for (var i = 0; i < 4; i++)
            ChoiceChip(
              label: Text(['→', '←', '↓', '↑'][i]),
              selected: direction == i,
              onSelected: (_) => setState(() => direction = i),
            ),
        ],
      ),
      Center(
        child: RotatedBox(
          quarterTurns: direction == 0
              ? 0
              : direction == 1
              ? 2
              : direction == 2
              ? 1
              : 3,
          child: SizedBox(
            width: 260,
            height: 32,
            child: LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      Text(
        '${(value * 100).round()}%',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Slider(value: value, onChanged: (v) => setState(() => value = v)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => setState(() => value = (value - .1).clamp(0, 1)),
            icon: const Icon(Icons.remove),
          ),
          IconButton(
            onPressed: () => setState(() => value = (value + .1).clamp(0, 1)),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    ],
  );
}

void main() => runApp(const JobsDemoApp(home: DirectionalProgressLabDemo()));
