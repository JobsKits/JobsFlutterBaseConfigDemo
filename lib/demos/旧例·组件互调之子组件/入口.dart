import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·组件互调之子组件/源码/A_Widget.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'A_Widget');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'A_Widget');
