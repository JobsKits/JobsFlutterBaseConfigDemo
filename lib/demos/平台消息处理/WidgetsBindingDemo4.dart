// 独立运行：flutter run -t "lib/demos/平台消息处理/WidgetsBindingDemo4.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '平台消息处理');

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
          appBar: JobsDemoAppBar(title: const LegacyText('Platform Messages')),
          body: const PlatformMessageDemo(),
        ),
      ),
    );
  }
}

class PlatformMessageDemo extends StatefulWidget {
  const PlatformMessageDemo({super.key});

  @override
  State<PlatformMessageDemo> createState() => _PlatformMessageDemoState();
}

class _PlatformMessageDemoState extends State<PlatformMessageDemo> {
  static const platform = MethodChannel('com.example.platform/messages');
  String _response = "Waiting for response...";

  @override
  void initState() {
    super.initState();
    _sendMessage();
  }

  Future<void> _sendMessage() async {
    try {
      final String result = await platform.invokeMethod('getPlatformVersion');
      setState(() {
        _response = "Platform version: $result";
      });
    } on PlatformException catch (e) {
      setState(() {
        _response = "Failed to get platform version: ${e.message}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LegacyText(_response, style: const TextStyle(fontSize: 24)),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'WidgetsBindingDemo4');
