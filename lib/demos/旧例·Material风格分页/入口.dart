import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·Material风格分页/源码/Material.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'Material');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Material');
