import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·Riverpod状态管理/源码/Riverpod.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'Riverpod');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Riverpod');
