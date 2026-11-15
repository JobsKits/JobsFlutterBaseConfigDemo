import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/自适应分类分页/源码/JobsCategoryPage.dart'
    as old;

void main() => runApp(
  JobsDemoApp(
    title: '自适应分类分页',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const LegacyText('自适应分类分页')),
  body: SafeArea(
    child: old.JobsCategoryPage(
      items: [
        for (final name in ['OC', 'Swift', 'Flutter'])
          old.ActivityBaseBean(
            title: name,
            child: Center(child: LegacyText(name)),
            show: true,
          ),
      ],
      selectedColor: Theme.of(context).colorScheme.primary,
      unselectedColor: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  ),
);
