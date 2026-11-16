// 独立运行：flutter run -t "lib/demos/多窗口会话/多窗口会话.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';

void main() => runApp(const JobsDemoApp(home: MultipleSceneLabDemo()));

class MultipleSceneLabDemo extends StatefulWidget {
  const MultipleSceneLabDemo({super.key});
  @override
  State<MultipleSceneLabDemo> createState() => _MultipleSceneLabDemoState();
}

class _MultipleSceneLabDemoState extends State<MultipleSceneLabDemo> {
  final state = NativeLabState('scenes');
  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '多窗口会话',
    state: state,
    children: [
      nativeButton(context, state, '重新加载', 'scenes.list'),
      nativeButton(context, state, '新建窗口', 'scenes.open', {
        'title': 'Jobs Flutter',
      }),
    ],
  );
}
