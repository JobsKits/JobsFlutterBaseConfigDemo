import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/组合滚动视图/源码/CustomScrollViewDemo.dart'
    as old;

// 兼容入口保留原 Demo 实现；编辑原文件后可直接运行本文件预览。
void main() => runApp(
  JobsDemoApp(
    title: '组合滚动视图',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) =>
    const old.CustomScrollViewDemo();
