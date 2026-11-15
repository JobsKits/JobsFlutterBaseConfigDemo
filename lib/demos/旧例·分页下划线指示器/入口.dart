import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·分页下划线指示器/源码/UnderlineTabIndicator.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'UnderlineTabIndicator',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'UnderlineTabIndicator',
);
