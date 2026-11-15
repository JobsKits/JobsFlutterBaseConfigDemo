import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·富文本拼接封装/源码/JobsRichText.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'JobsRichText');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'JobsRichText');
