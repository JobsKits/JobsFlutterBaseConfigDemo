import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·隔离区双向消息/源码/IsolateDemo1.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'IsolateDemo1');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'IsolateDemo1');
