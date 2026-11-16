// 独立运行：flutter run -t "lib/demos/运行时类检查/运行时类检查.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: RuntimeClassLabDemo()));

class RuntimeClassLabDemo extends StatefulWidget {
  const RuntimeClassLabDemo({super.key});

  @override
  State<RuntimeClassLabDemo> createState() => _RuntimeClassLabDemoState();
}

class _RuntimeClassLabDemoState extends State<RuntimeClassLabDemo> {
  final state = NativeLabState();
  final name = TextEditingController(
    text: defaultTargetPlatform == TargetPlatform.iOS
        ? 'NSObject'
        : 'android.app.Activity',
  );
  final dynamicName = TextEditingController(text: 'JobsLabRuntimeDemo');
  final patchText = TextEditingController(text: 'Patched by Jobs');
  final registeredNames = <String>{};

  @override
  void dispose() {
    for (final name in registeredNames) {
      unawaited(
        JobsPlatformLab.invoke<void>('runtime.rollback', {
          'name': name,
        }).catchError((_) {}),
      );
    }
    state.dispose();
    name.dispose();
    dynamicName.dispose();
    patchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '运行时类检查',
    state: state,
    children: [
      TextField(
        controller: name,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '类名')),
      ),
      nativeButton(context, state, '检查方法与属性', 'runtime.inspect', {
        'name': name.text,
      }),
      if (defaultTargetPlatform == TargetPlatform.iOS) ...[
        const SizedBox(height: 20),
        TextField(
          controller: dynamicName,
          decoration: const InputDecoration(labelText: 'JobsLabRuntime…'),
        ),
        FilledButton.tonal(
          onPressed: () async {
            final result = await state.run('runtime.define', {
              'name': dynamicName.text.trim(),
              'title': 'Created by Jobs',
            });
            if (result != null && mounted) {
              registeredNames.add(dynamicName.text.trim());
              setState(() => name.text = dynamicName.text.trim());
            }
          },
          child: Text(platformText(context, '动态注册类')),
        ),
        TextField(
          controller: patchText,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: platformText(context, '补丁返回值'),
          ),
        ),
        nativeButton(context, state, '替换方法实现', 'runtime.patch', {
          'name': name.text,
          'title': patchText.text,
        }),
        nativeButton(context, state, '恢复方法实现', 'runtime.rollback', {
          'name': name.text,
        }),
      ],
    ],
  );
}
