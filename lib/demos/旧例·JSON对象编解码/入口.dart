import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·JSON对象编解码/源码/Json.dart'
    as source;

void main() => launchLegacyStandalone(source.legacyOriginalMain, title: 'Json');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'Json');
