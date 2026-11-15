import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/胶囊按钮切页/源码/JobsSegmentTabs.dart'
    as old;

void main() => runApp(
  JobsDemoApp(
    title: '胶囊按钮切页',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => const old.View();
