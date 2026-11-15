import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·Provider通知与计数/源码/ProviderDemo1.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'ProviderDemo1');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'ProviderDemo1');
