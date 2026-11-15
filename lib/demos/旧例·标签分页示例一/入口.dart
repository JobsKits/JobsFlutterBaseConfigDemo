import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·标签分页示例一/源码/HomePage.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'HomePage·101');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'HomePage·101');
