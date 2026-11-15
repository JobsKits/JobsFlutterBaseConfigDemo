import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·注解与元数据查询/源码/AnnotationDemo.dart'
    as source;

void main() =>
    launchLegacyStandalone(source.legacyOriginalMain, title: 'AnnotationDemo');

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'AnnotationDemo',
);
