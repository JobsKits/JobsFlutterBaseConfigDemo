import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·隔离区任务计算/源码/IsolateDemo2.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'IsolateDemo2');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'IsolateDemo2');
