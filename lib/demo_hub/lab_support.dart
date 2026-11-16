import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import 'lab_strings.dart';

String labTr(BuildContext context, String key) {
  JobsDemoStrings.registerTranslations(labTranslations);
  return tr(context, key);
}

class LabFrame extends StatelessWidget {
  const LabFrame({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(labTr(context, title))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final child in children)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
      ],
    ),
  );
}

Widget labAction(BuildContext context, String title, VoidCallback? action) =>
    FilledButton(onPressed: action, child: Text(labTr(context, title)));
Widget labOutput(BuildContext context, Object? output) => DecoratedBox(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: SelectableText(output?.toString() ?? '—'),
  ),
);
