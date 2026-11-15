import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/提示框行为组合/源码/TipsDemo.dart' as old;

// 兼容入口保留原 Demo 实现；编辑原文件后可直接运行本文件预览。
void main() => runApp(
  JobsDemoApp(
    title: '提示框行为组合',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => const old.HomeScreen();
