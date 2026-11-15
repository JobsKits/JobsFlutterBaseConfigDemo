import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·层叠布局教学/源码/Stack.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'Stack');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Stack');
