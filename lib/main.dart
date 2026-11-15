import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import 'demo_hub/demo_hub_app.dart';
import 'demos/原生与Flutter往返/独立引擎页面.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = JobsDemoSettings();
  await settings.init();
  runApp(DemoHubApp(settings: settings));
}

/// 原生宿主启动的第二个 FlutterEngine，保留独立入口避免 release 树摇移除。
@pragma('vm:entry-point')
Future<void> jobsNativeBridgeEntry() => launchNativeBridgeEntry();
