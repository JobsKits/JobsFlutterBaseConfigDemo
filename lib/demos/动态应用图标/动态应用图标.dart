// 独立运行：flutter run -t "lib/demos/动态应用图标/动态应用图标.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: AlternateIconLabDemo()));

class AlternateIconLabDemo extends StatefulWidget {
  const AlternateIconLabDemo({super.key});
  @override
  State<AlternateIconLabDemo> createState() => _AlternateIconLabDemoState();
}

class _AlternateIconLabDemoState extends State<AlternateIconLabDemo> {
  final state = NativeLabState();
  List<String> names = [];
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final value = await state.run('icon.status');
    if (value is Map && mounted) {
      setState(() => names = List<String>.from(value['names'] as List? ?? []));
    }
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '动态应用图标',
    state: state,
    children: [
      TextButton(onPressed: reload, child: Text(platformText(context, '重新加载'))),
      nativeButton(context, state, '恢复默认', 'icon.set', {'name': ''}),
      if (names.isEmpty)
        JobsEmptyState(
          title: platformText(context, '无数据'),
          message: platformText(context, '动态应用图标'),
          onReload: reload,
        ),
      for (final name in names)
        nativeButton(context, state, name, 'icon.set', {'name': name}),
    ],
  );
}
