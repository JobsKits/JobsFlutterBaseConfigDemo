import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·MQTT消息发布订阅二/源码/mqtt_demo2.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'mqtt_demo2');

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: source.legacyOriginalMain, title: 'mqtt_demo2');
