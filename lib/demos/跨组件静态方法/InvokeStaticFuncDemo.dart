// 独立运行：flutter run -t "lib/demos/跨组件静态方法/InvokeStaticFuncDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '跨组件静态方法');

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: const MaterialApp(title: 'CustomScrollView Demo', home: B()),
    );
  }
}

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  static void dd() {
    legacyDebugPrint("sss");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Main Page Bottom Bar')),
      body: const Center(child: LegacyText('Main Page Content')),
    );
  }
}

class B extends StatelessWidget {
  const B({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Another Widget')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _AState.dd();
          },
          child: const LegacyText('Call Static Method'),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => const B();
