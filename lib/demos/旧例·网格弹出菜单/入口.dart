import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·网格弹出菜单/源码/弹出框@GridView.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: '弹出框@GridView');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: '弹出框@GridView');
