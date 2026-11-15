import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/弹性与换行组合/源码/Flexible+Wrap.dart'
    as old;

// 兼容入口保留原 Demo 实现；编辑原文件后可直接运行本文件预览。
void main() => runApp(
  JobsDemoApp(
    title: '弹性与换行组合',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const LegacyText('弹性与换行组合')),
  body: SafeArea(child: const Center(child: old.FlexibleWrapDemo())),
);
