// 独立运行：flutter run -t "lib/demos/Unity引擎容器/Unity引擎容器.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: UnityEngineLabDemo()));

class UnityEngineLabDemo extends StatefulWidget {
  const UnityEngineLabDemo({super.key});
  @override
  State<UnityEngineLabDemo> createState() => _UnityEngineLabDemoState();
}

class _UnityEngineLabDemoState extends State<UnityEngineLabDemo> {
  final state = NativeLabState();
  final object = TextEditingController(text: 'Main Camera');
  final method = TextEditingController(text: 'OnFlutterMessage');
  final message = TextEditingController(text: 'Jobs Flutter');
  @override
  void dispose() {
    state.dispose();
    object.dispose();
    method.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: 'Unity引擎容器',
    state: state,
    children: [
      nativeButton(context, state, '平台能力', 'unity.status'),
      nativeButton(context, state, '打开Unity', 'unity.open'),
      TextField(
        controller: object,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'GameObject'),
      ),
      TextField(
        controller: method,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'Method'),
      ),
      TextField(
        controller: message,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '内容')),
      ),
      nativeButton(context, state, '发送消息', 'unity.message', {
        'object': object.text,
        'method': method.text,
        'message': message.text,
      }),
    ],
  );
}
