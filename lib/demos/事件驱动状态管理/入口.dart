import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/BLoC（未验证）/CounterBloc.dart';
import 'package:jobs_flutter_base_config/demos/事件驱动状态管理/源码/BLoC.dart' as old;

// 兼容入口保留原 Demo 实现；编辑原文件后可直接运行本文件预览。
void main() => runApp(
  JobsDemoApp(
    title: '事件驱动状态管理',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) =>
    BlocProvider(create: (_) => CounterBloc(), child: const old.CounterPage());
