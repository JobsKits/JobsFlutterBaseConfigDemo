import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import 'extra_strings.dart';

String extraTr(BuildContext context, String key) {
  JobsDemoStrings.registerTranslations(extraTranslations);
  return tr(context, key);
}

class ExtraFrame extends StatelessWidget {
  const ExtraFrame({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(extraTr(context, title))),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final child in children)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
      ],
    ),
  );
}
