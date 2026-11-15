import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: WidgetDataLabDemo()));

class WidgetDataLabDemo extends StatefulWidget {
  const WidgetDataLabDemo({super.key});
  @override
  State<WidgetDataLabDemo> createState() => _WidgetDataLabDemoState();
}

class _WidgetDataLabDemoState extends State<WidgetDataLabDemo> {
  final state = NativeLabState();
  final text = TextEditingController(text: 'Jobs Flutter');
  @override
  void dispose() {
    state.dispose();
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '小组件共享数据',
    state: state,
    children: [
      TextField(
        controller: text,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '内容')),
      ),
      nativeButton(context, state, '更新小组件', 'widget.write', {
        'text': text.text,
      }),
      nativeButton(context, state, '读取', 'widget.read'),
    ],
  );
}
