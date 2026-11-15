import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·弹性换行与填充对照/源码/Flexible + Expanded.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'Flexible+Expanded',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'Flexible+Expanded',
);
