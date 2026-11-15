import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·Cupertino风格分页/源码/Cupertino.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'Cupertino');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Cupertino');
