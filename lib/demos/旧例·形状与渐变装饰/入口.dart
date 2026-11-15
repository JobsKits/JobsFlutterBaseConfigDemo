import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·形状与渐变装饰/源码/ShapeDecoration.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'ShapeDecoration');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'ShapeDecoration',
);
