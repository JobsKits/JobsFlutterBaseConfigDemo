import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·GetX双向数值绑定/源码/💥GetX的值双向绑定.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'GetX的值双向绑定');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'GetX的值双向绑定');
