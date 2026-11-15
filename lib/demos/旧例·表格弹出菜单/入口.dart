import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·表格弹出菜单/源码/弹出框@表格.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: '弹出框@表格');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: '弹出框@表格');
