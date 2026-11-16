// Match the Material API exported by the existing demo foundation.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../demo_hub/workflow_strings.dart';

import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

class WorkflowShell extends StatelessWidget {
  const WorkflowShell({
    super.key,
    required this.title,
    required this.online,
    required this.busy,
    required this.onRefresh,
    required this.body,
  });
  final String title;
  final bool online, busy;
  final VoidCallback? onRefresh;
  final Widget body;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(workflowTr(context, title)),
      actions: [
        IconButton(
          tooltip: workflowTr(context, '刷新'),
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          if (busy && ModalRoute.of(context)?.isCurrent != false)
            const LinearProgressIndicator(minHeight: 2),
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  online ? Icons.cloud_done_outlined : Icons.science_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    workflowTr(context, online ? '服务端已同步' : '本地演示数据'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    ),
  );
}

class WorkflowEmpty extends StatelessWidget {
  const WorkflowEmpty({
    super.key,
    required this.onReload,
    this.message = '暂无结果',
  });
  final VoidCallback onReload;
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 44),
          const SizedBox(height: 12),
          Text(
            workflowTr(context, message),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(workflowTr(context, '更改筛选或重新加载'), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: Text(workflowTr(context, '重新加载')),
          ),
        ],
      ),
    ),
  );
}

Future<bool> workflowConfirm(
  BuildContext context,
  String title,
  String body,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(workflowTr(context, title)),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(workflowTr(context, '取消')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(workflowTr(context, '确认')),
          ),
        ],
      ),
    ) ??
    false;
