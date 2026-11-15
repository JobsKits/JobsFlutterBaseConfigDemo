import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

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
          appBar: AppBar(title: const LegacyText('Event Loop and Scheduling')),
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

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·事件循环与帧调度');
