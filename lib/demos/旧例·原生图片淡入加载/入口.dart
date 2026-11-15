import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·原生图片淡入加载/源码/FadeInImageDemo(系统原生).dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'FadeInImageDemo(系统原生)',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'FadeInImageDemo(系统原生)',
);
