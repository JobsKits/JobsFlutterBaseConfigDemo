import 'package:flutter/material.dart';
import 'demo_strings.dart';

class JobsEmptyState extends StatelessWidget {
  const JobsEmptyState({
    super.key,
    required this.title,
    this.message,
    this.action,
    required this.onReload,
  });
  final String title;
  final String? message;
  final Widget? action;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          minHeight: constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 52,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                tr(context, title),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  tr(context, message!),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (action != null) ...[action!, const SizedBox(height: 8)],
              FilledButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: Text(tr(context, '重新加载')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
