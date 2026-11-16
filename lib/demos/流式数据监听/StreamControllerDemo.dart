// 独立运行：flutter run -t "lib/demos/流式数据监听/StreamControllerDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '流式数据监听');

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        title: 'Headline Demo',
        theme: ThemeData(
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        home: const StreamDemo(),
      ),
    );
  }
}

class StreamDemo extends StatefulWidget {
  const StreamDemo({super.key});

  @override
  State<StreamDemo> createState() => _StreamDemoState();
}

class _StreamDemoState extends State<StreamDemo> {
  final StreamController<int> _controller = StreamController<int>();

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Stream Demo')),
      body: Center(
        child: StreamBuilder<int>(
          stream: _controller.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return LegacyText('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return LegacyText(
              'Count: ${snapshot.data}',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.sink.add(1);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => const StreamDemo();
