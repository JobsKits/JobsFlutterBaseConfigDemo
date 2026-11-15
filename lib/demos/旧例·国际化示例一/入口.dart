import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·国际化示例一/源码/intl_international_Demo1.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'intl_international_Demo1',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'intl_international_Demo1',
);
