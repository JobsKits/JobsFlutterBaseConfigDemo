// 独立运行：flutter run -t "lib/demos/事件循环与帧调度/WidgetsBindingDemo1.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '事件循环与帧调度');

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Scaffold(
          appBar: JobsDemoAppBar(
            title: const LegacyText('Event Loop and Scheduling'),
          ),
          body: const EventLoopDemo(),
        ),
      ),
    );
  }
}

class EventLoopDemo extends StatefulWidget {
  const EventLoopDemo({super.key});

  @override
  State<EventLoopDemo> createState() => _EventLoopDemoState();
}

class _EventLoopDemoState extends State<EventLoopDemo> {
  String _message = "Tap to start";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _message = "Event received!";
          });
          // Process a heavy task in the next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Simulate a delay
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                _message = "Task completed!";
              });
            });
          });
        },
        child: LegacyText(_message, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'WidgetsBindingDemo1');
