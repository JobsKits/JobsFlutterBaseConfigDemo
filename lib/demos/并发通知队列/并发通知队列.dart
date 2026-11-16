// 独立运行：flutter run -t "lib/demos/并发通知队列/并发通知队列.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() => runApp(
  const JobsDemoApp(home: ConcurrentNotificationsDemo(), title: '并发通知队列'),
);

class ConcurrentNotificationsDemo extends StatefulWidget {
  const ConcurrentNotificationsDemo({super.key});
  @override
  State<ConcurrentNotificationsDemo> createState() =>
      _ConcurrentNotificationsState();
}

class _ConcurrentNotificationsState extends State<ConcurrentNotificationsDemo> {
  final queue = JobsNotificationQueue();
  final scheduled = <Timer>[];
  int next = 1000;
  @override
  void initState() {
    super.initState();
    restart();
  }

  void stopSchedule() {
    for (final timer in scheduled) {
      timer.cancel();
    }
    scheduled.clear();
  }

  void restart() {
    stopSchedule();
    queue.clear();
    queue.add(const JobsQueuedNotice(id: '111', content: 'key:111'));
    final random = Random(11);
    for (var i = 0; i < 20; i++) {
      final id = '$i';
      scheduled.add(
        Timer(Duration(seconds: 1 + random.nextInt(10)), () {
          queue.add(JobsQueuedNotice(id: id, content: 'key:$id'));
        }),
      );
    }
    scheduled.add(
      Timer(const Duration(seconds: 3), () {
        queue.update('111', 'key:X222');
      }),
    );
  }

  @override
  void dispose() {
    stopSchedule();
    queue.dispose();
    super.dispose();
  }

  Future<void> add() async {
    final text = await uiInput(context, '通知内容');
    if (!mounted || text == null || text.isEmpty) return;
    queue.add(JobsQueuedNotice(id: '${next++}', content: text));
  }

  Future<void> update(String id) async {
    final notices = queue.active.where((e) => e.id == id).toList();
    if (notices.isEmpty) return;
    final text = await uiInput(context, '更新通知', initial: notices.first.content);
    if (mounted && text != null && text.isNotEmpty) queue.update(id, text);
  }

  Widget activeSlot(int slot) {
    final active = queue.active;
    if (slot >= active.length)
      return SizedBox(key: ValueKey('empty-$slot'), height: 72);
    final notice = active[slot];
    return Card(
      key: ValueKey(notice.id),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        onTap: () => update(notice.id),
        title: Text(notice.content),
        subtitle: Text('key: ${notice.id} · 5s'),
        trailing: IconButton(
          tooltip: uiTr(context, '取消'),
          onPressed: () => queue.dismiss(notice.id),
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '并发通知队列'))),
    body: ListenableBuilder(
      listenable: queue,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${uiTr(context, '并发数')}: ${queue.concurrency}'),
          Slider(
            value: queue.concurrency.toDouble(),
            min: 1,
            max: 4,
            divisions: 3,
            onChanged: (value) => queue.concurrency = value.round(),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: add,
                icon: const Icon(Icons.add),
                label: Text(uiTr(context, '添加通知')),
              ),
              OutlinedButton(
                onPressed: restart,
                child: Text(uiTr(context, '重新加载')),
              ),
              TextButton(
                onPressed: () {
                  stopSchedule();
                  queue.clear();
                },
                child: Text(uiTr(context, '清空')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${uiTr(context, '进行中')}: ${queue.active.length} / ${uiTr(context, '排队')}: ${queue.pending.length} / ${uiTr(context, '完成')}: ${queue.completed.length}',
          ),
          const SizedBox(height: 12),
          for (var slot = 0; slot < 4; slot++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: activeSlot(slot),
              ),
            ),
          const Divider(),
          Text(
            uiTr(context, '排队'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (queue.pending.isEmpty)
            uiEmpty(context, add)
          else
            Wrap(
              spacing: 6,
              children: [
                for (final notice in queue.pending)
                  InputChip(
                    label: Text(notice.id),
                    onDeleted: () => queue.dismiss(notice.id),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Text('${uiTr(context, '完成')}: ${queue.completed.join(', ')}'),
        ],
      ),
    ),
  );
}
