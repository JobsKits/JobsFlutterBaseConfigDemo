import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·段落富文本与交互/源码/sample_data.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: '一般的富文本');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: '一般的富文本');
