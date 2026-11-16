// 独立运行：flutter run -t "lib/demos/多任务计时器/多任务计时器.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: MultiTimerDemo(), title: '多任务计时器'));

class MultiTimerDemo extends StatefulWidget {
  const MultiTimerDemo({super.key});
  @override
  State<MultiTimerDemo> createState() => _State();
}

class _State extends State<MultiTimerDemo> {
  final hub = JobsLabTimerHub();
  StreamSubscription<void>? listener;
  int next = 3;
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 3; i++) {
      hub.create('Timer ${i + 1}', Duration(seconds: (i + 1) * 10));
    }
    listener = hub.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    listener?.cancel();
    hub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '多任务计时器',
    children: [
      Wrap(
        spacing: 8,
        children: [
          labAction(
            context,
            '增加',
            () => hub.create('Timer ${++next}', const Duration(seconds: 30)),
          ),
          labAction(context, '开始', () {
            for (final id in hub.timers.keys) {
              hub.start(id);
            }
          }),
        ],
      ),
      if (hub.timers.isEmpty)
        JobsEmptyState(
          title: '无数据',
          onReload: () =>
              hub.create('Timer ${++next}', const Duration(seconds: 30)),
        ),
      for (final timer in hub.timers.values)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${timer.id}  ${(timer.duration - timer.elapsed).inMilliseconds / 1000} s',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: timer.progress),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => timer.watch.isRunning
                          ? hub.pause(timer.id)
                          : hub.start(timer.id),
                      child: Text(
                        labTr(context, timer.watch.isRunning ? '暂停' : '开始'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => hub.reset(timer.id),
                      child: Text(labTr(context, '恢复默认')),
                    ),
                    IconButton(
                      onPressed: () => hub.remove(timer.id),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: labTr(context, '删除'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
