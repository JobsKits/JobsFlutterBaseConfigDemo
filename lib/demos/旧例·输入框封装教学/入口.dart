import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·输入框封装教学/源码/JobsTextField.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'JobsTextField');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'JobsTextField');
