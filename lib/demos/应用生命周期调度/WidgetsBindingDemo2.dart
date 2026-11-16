// 独立运行：flutter run -t "lib/demos/应用生命周期调度/WidgetsBindingDemo2.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '应用生命周期调度');

void legacyOriginalMain() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(MyAppLifecycleObserver());
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
            title: const LegacyText('Lifecycle Management'),
          ),
          body: const Center(
            child: LegacyText('Check the console for lifecycle events'),
          ),
        ),
      ),
    );
  }
}

class MyAppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    legacyDebugPrint('App lifecycle state changed to $state');
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'WidgetsBindingDemo2');
